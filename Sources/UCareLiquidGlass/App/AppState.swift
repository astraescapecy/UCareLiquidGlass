import Combine
import Foundation
import StoreKit
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @AppStorage("ucare.isSubscribed") private var isSubscribed = false
    @Published var phase: AppPhase = .splash
    @Published var signUpDraft = SignUpDraft()
    @Published var questionnaire = QuestionnaireDraft()
    @Published var username: String = ""
    @Published private(set) var userProfile: UserProfile?
    @Published var completedStepIDs: Set<String> = []
    @Published private(set) var weeklyCheckIns: [WeeklyCheckInEntry] = []
    @Published var isRetakeProgramFlow = false
    @Published private(set) var storeProducts: [Product] = []
    @Published var storeStatusMessage: String?

    private let persistence = OnboardingPersistence()

    init() {
        userProfile = persistence.loadProfile()
        questionnaire = persistence.loadDraft() ?? QuestionnaireDraft()
        username = persistence.username
        completedStepIDs = persistence.loadCompletedStepIDs(for: .now)
        weeklyCheckIns = persistence.loadWeeklyCheckIns()
        migrateLegacySubscriptionFlagIfNeeded()
        Task { await listenForTransactions() }
        Task { await refreshEntitlementsFromStore(isRestore: false) }
        Task { await loadStoreProducts() }
    }

    private func migrateLegacySubscriptionFlagIfNeeded() {
        let legacy = UserDefaults.standard.bool(forKey: "youcare.isSubscribed")
        if legacy, !isSubscribed {
            isSubscribed = true
            UserDefaults.standard.removeObject(forKey: "youcare.isSubscribed")
        }
    }

    private func listenForTransactions() async {
        for await verificationResult in Transaction.updates {
            if case .verified(let transaction) = verificationResult {
                await transaction.finish()
                await refreshEntitlementsFromStore(isRestore: false)
            }
        }
    }

    func completeSplash() {
        guard phase == .splash else { return }
        if userProfile != nil {
            phase = isSubscribed ? .main : .paywall
        } else if persistence.sawWelcome {
            phase = .auth
        } else {
            phase = .getStarted
        }
    }

    func markWelcomeSeen() {
        persistence.sawWelcome = true
        phase = .auth
    }

    func completeAuth() {
        persistence.sawWelcome = true
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let raw = signUpDraft.email.split(separator: "@").first.map(String.init) ?? "member"
            let cleaned = raw.filter(\.isLetter).lowercased()
            setUsername(String(cleaned.prefix(14)).isEmpty ? "member" : String(cleaned.prefix(14)))
        }
        phase = .questionnaire
    }

    func setUsername(_ value: String) {
        username = value.lowercased()
        persistence.username = username
    }

    func startAnalysis() {
        phase = .analysis
    }

    func showReveal() {
        phase = .reveal
    }

    /// Re-enter questionnaire on the last step while retaking (from plan reveal back).
    func backToQuestionnaireFromReveal() {
        questionnaire.step = 4
        phase = .questionnaire
        persistQuestionnaire()
    }

    /// Profile → rebuild protocol: prefill questionnaire from current profile, skip paywall.
    func beginProgramRetake() {
        guard let p = userProfile else { return }
        isRetakeProgramFlow = true
        populateQuestionnaire(from: p)
        questionnaire.step = 0
        persistQuestionnaire()
        phase = .questionnaire
    }

    func cancelProgramRetake() {
        isRetakeProgramFlow = false
        if let p = userProfile {
            populateQuestionnaire(from: p)
        }
        questionnaire.step = 0
        phase = .main
    }

    private func populateQuestionnaire(from p: UserProfile) {
        questionnaire.careGoals = Set(p.careGoals)
        questionnaire.sex = p.sex
        questionnaire.age = p.age
        questionnaire.dietStyle = p.dietStyle
        questionnaire.allergiesText = p.allergiesNote
        questionnaire.routineNotes = p.routineNote
        questionnaire.problemAreasText = p.problemAreasNote
        if let g = p.glowUpTargetDate {
            questionnaire.wantsGlowUpTarget = true
            questionnaire.glowUpTargetDate = g
        } else {
            questionnaire.wantsGlowUpTarget = false
        }
        questionnaire.wantsWaterReminders = p.wantsWaterReminders
        questionnaire.wantsMorningRoutineNudge = p.wantsMorningNudge
        questionnaire.wantsEveningSkincareNudge = p.wantsEveningNudge
        questionnaire.wantsBedtimeWindDown = p.wantsBedtimeNudge
        questionnaire.optedInFacePhoto = p.optedInFacePhoto
        questionnaire.optedInHairPhoto = p.optedInHairPhoto
        questionnaire.optedInSkinPhoto = p.optedInSkinPhoto
    }

    func finalizeOnboarding() {
        guard let built = buildProfile() else { return }
        if isRetakeProgramFlow, let existing = userProfile {
            var merged = existing
            merged.careGoals = built.careGoals
            merged.programSteps = built.programSteps
            merged.sex = built.sex
            merged.age = built.age
            merged.dietStyle = built.dietStyle
            merged.allergiesNote = built.allergiesNote
            merged.routineNote = built.routineNote
            merged.problemAreasNote = built.problemAreasNote
            merged.glowUpTargetDate = built.glowUpTargetDate
            merged.wantsWaterReminders = built.wantsWaterReminders
            merged.wantsMorningNudge = built.wantsMorningNudge
            merged.wantsEveningNudge = built.wantsEveningNudge
            merged.wantsBedtimeNudge = built.wantsBedtimeNudge
            merged.optedInFacePhoto = built.optedInFacePhoto
            merged.optedInHairPhoto = built.optedInHairPhoto
            merged.optedInSkinPhoto = built.optedInSkinPhoto
            userProfile = merged
            persistence.saveProfile(merged)
            isRetakeProgramFlow = false
        } else {
            userProfile = built
            persistence.saveProfile(built)
            completedStepIDs = []
            persistence.saveCompletedStepIDs([], for: .now)
        }
        persistence.saveDraft(questionnaire)
        phase = .main
    }

    func previewProfile() -> UserProfile? {
        buildProfile()
    }

    private func buildProfile() -> UserProfile? {
        var focuses = questionnaire.careGoals
        if questionnaire.wantsGlowUpTarget {
            focuses.insert(.glowUpBeforeDate)
        }
        guard !focuses.isEmpty else { return nil }

        let steps = AppProgramServices.generator.makeProgramSteps(for: focuses)
        guard !steps.isEmpty else { return nil }

        let displayName = signUpDraft.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Member"
            : signUpDraft.fullName

        let memberSince = userProfile?.memberSince ?? .now
        return UserProfile(
            fullName: displayName,
            email: signUpDraft.email,
            username: username,
            memberSince: memberSince,
            careGoals: Array(focuses).sorted { $0.rawValue < $1.rawValue },
            sex: questionnaire.sex,
            age: questionnaire.age,
            dietStyle: questionnaire.dietStyle,
            allergiesNote: questionnaire.allergiesText,
            routineNote: questionnaire.routineNotes,
            problemAreasNote: questionnaire.problemAreasText,
            glowUpTargetDate: questionnaire.wantsGlowUpTarget ? questionnaire.glowUpTargetDate : nil,
            wantsWaterReminders: questionnaire.wantsWaterReminders,
            wantsMorningNudge: questionnaire.wantsMorningRoutineNudge,
            wantsEveningNudge: questionnaire.wantsEveningSkincareNudge,
            wantsBedtimeNudge: questionnaire.wantsBedtimeWindDown,
            optedInFacePhoto: questionnaire.optedInFacePhoto,
            optedInHairPhoto: questionnaire.optedInHairPhoto,
            optedInSkinPhoto: questionnaire.optedInSkinPhoto,
            programSteps: steps
        )
    }

    func persistQuestionnaire() {
        persistence.saveDraft(questionnaire)
    }

    func toggleStep(_ id: String, on date: Date = .now) {
        var ids = persistence.loadCompletedStepIDs(for: date)
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        persistence.saveCompletedStepIDs(ids, for: date)
        if Calendar.current.isDateInToday(date) {
            completedStepIDs = ids
        }
        let total = visibleProgramSteps(on: date).count
        if total > 0, ids.count >= total {
            persistence.setAchievementFlag("perfectDayEver", true)
        }
    }

    func isStepDone(_ id: String, on date: Date = .now) -> Bool {
        persistence.loadCompletedStepIDs(for: date).contains(id)
    }

    func completionFraction(on date: Date) -> CGFloat {
        let total = visibleStepsCount(for: date)
        guard total > 0 else { return 0 }
        let done = persistence.loadCompletedStepIDs(for: date).count
        return CGFloat(done) / CGFloat(total)
    }

    func visibleProgramSteps(on date: Date = .now) -> [ProgramStep] {
        guard let all = userProfile?.programSteps, !all.isEmpty else { return [] }
        if hasActiveSubscription { return all }
        return Array(all.prefix(4))
    }

    private func visibleStepsCount(for date: Date) -> Int {
        _ = date
        return visibleProgramSteps(on: date).count
    }

    func completionHistory() -> [(date: Date, count: Int)] {
        persistence.completionDaySummaries()
    }

    func exportPayloadJSON() -> Data? {
        struct Export: Codable {
            let exportedAt: Date
            let profile: UserProfile?
            let weeklyCheckIns: [WeeklyCheckInEntry]
            let completionDayCounts: [String: Int]
        }
        let fmt = ISO8601DateFormatter()
        let dayCounts = Dictionary(uniqueKeysWithValues: persistence.completionDaySummaries().map { (fmt.string(from: $0.date), $0.count) })
        let blob = Export(exportedAt: .now, profile: userProfile, weeklyCheckIns: weeklyCheckIns, completionDayCounts: dayCounts)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? enc.encode(blob)
    }

    func logout() {
        persistence.clearAll()
        WeeklyProgressPhotoStore.clearAll()
        isSubscribed = false
        signUpDraft = .init()
        questionnaire = .init()
        username = ""
        userProfile = nil
        completedStepIDs = []
        weeklyCheckIns = []
        isRetakeProgramFlow = false
        phase = .auth
    }

    func deleteLocalAccount() {
        logout()
    }

    // MARK: - StoreKit

    func loadStoreProducts() async {
        storeStatusMessage = nil
        do {
            let ids = PaywallPlan.allCases.map(\.storeProductID)
            storeProducts = try await Product.products(for: ids)
            if storeProducts.isEmpty {
                storeStatusMessage = "No App Store products returned yet — add IAPs in App Store Connect or attach a StoreKit configuration in the scheme for local testing."
            }
        } catch {
            storeStatusMessage = error.localizedDescription
        }
    }

    func purchaseFromStore(_ plan: PaywallPlan) async {
        storeStatusMessage = nil
        if let product = storeProducts.first(where: { $0.id == plan.storeProductID }) {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        isSubscribed = true
                        if userProfile != nil {
                            phase = .main
                        } else {
                            phase = .analysis
                        }
                    case .unverified:
                        storeStatusMessage = "Purchase could not be verified."
                    }
                case .userCancelled:
                    break
                case .pending:
                    storeStatusMessage = "Purchase pending approval."
                @unknown default:
                    break
                }
            } catch {
                storeStatusMessage = error.localizedDescription
            }
        } else {
            #if DEBUG
            isSubscribed = true
            if userProfile != nil {
                phase = .main
            } else {
                phase = .analysis
            }
            storeStatusMessage = "Demo unlock (Debug): no StoreKit product matched. Configure IAPs or StoreKit config."
            #else
            storeStatusMessage = "This plan isn’t available from the App Store yet."
            #endif
        }
    }

    func restorePurchases() async {
        storeStatusMessage = nil
        do {
            try await AppStore.sync()
        } catch {
            storeStatusMessage = error.localizedDescription
        }
        await refreshEntitlementsFromStore(isRestore: true)
        if isSubscribed, userProfile != nil {
            phase = .main
        }
    }

    private func refreshEntitlementsFromStore(isRestore: Bool) async {
        var active = false
        let allowed = Set(PaywallPlan.allCases.map(\.storeProductID))
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let t) = entitlement, allowed.contains(t.productID) {
                active = true
                break
            }
        }
        if active {
            isSubscribed = true
        } else if isRestore {
            isSubscribed = false
        }
    }

    var hasActiveSubscription: Bool { isSubscribed }

    func openPaywall() {
        phase = .paywall
    }

    func updateProfile(_ mutator: (inout UserProfile) -> Void) {
        guard var p = userProfile else { return }
        mutator(&p)
        userProfile = p
        persistence.saveProfile(p)
    }

    func submitWeeklyCheckIn(_ entry: WeeklyCheckInEntry) {
        var list = weeklyCheckIns.filter { $0.id != entry.id }
        list.append(entry)
        list.sort { $0.weekStart > $1.weekStart }
        weeklyCheckIns = Array(list.prefix(26))
        persistence.saveWeeklyCheckIns(weeklyCheckIns)
    }

    func recentWeeklyCheckIns(max: Int = 8) -> [WeeklyCheckInEntry] {
        Array(weeklyCheckIns.sorted { $0.weekStart > $1.weekStart }.prefix(max))
    }

    func routineStreakDays(reference: Date = .now) -> Int {
        let days = (0..<400).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: reference) }
        var streak = 0
        for day in days {
            if completionFraction(on: day) >= 0.99 { streak += 1 } else { break }
        }
        return streak
    }

    func achievementRows() -> [(id: String, title: String, detail: String, icon: String, unlocked: Bool)] {
        let streak = routineStreakDays()
        let n = weeklyCheckIns.count
        let perfect = persistence.achievementFlag("perfectDayEver")
        return [
            ("stack", "Stack proof", "Completed every visible step for a full day.", "checkmark.seal.fill", perfect),
            ("steady", "Steady rhythm", "3-day completion streak.", "flame", streak >= 3),
            ("week", "Week merged", "7-day completion streak.", "flame.fill", streak >= 7),
            ("mirror", "Self-aware", "Logged your first weekly check-in.", "square.and.pencil", n >= 1),
            ("curve", "Glow curve", "Four weeks of check-ins on file.", "chart.xyaxis.line", n >= 4),
        ]
    }

    func glowScoreTrendLast7Days(reference: Date = .now) -> [(date: Date, score: Int)] {
        let cal = Calendar.current
        let end = cal.startOfDay(for: reference)
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: -6 + $0, to: end) }
        return days.map { ($0, glowUpScore(on: $0)) }
    }

    private func isHydrationStep(_ step: ProgramStep) -> Bool {
        let id = step.id.lowercased()
        if id.contains("hydrat") { return true }
        if id.contains("water") { return true }
        let t = step.title.lowercased()
        return t.contains("hydrat") || (t.contains("water") && !t.contains("face"))
    }

    /// 0…1 average completion of hydration-tagged steps over the last 7 days (1 if none in program).
    func hydrationAdherenceLast7Days(reference: Date = .now) -> CGFloat {
        let cal = Calendar.current
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: cal.startOfDay(for: reference)) }
        var parts: [CGFloat] = []
        for day in days {
            let hyd = visibleProgramSteps(on: day).filter { isHydrationStep($0) }
            guard !hyd.isEmpty else { continue }
            let done = hyd.filter { isStepDone($0.id, on: day) }.count
            parts.append(CGFloat(done) / CGFloat(hyd.count))
        }
        guard !parts.isEmpty else { return 1 }
        return parts.reduce(0, +) / CGFloat(parts.count)
    }

    func glowUpScore(on reference: Date = .now) -> Int {
        let cal = Calendar.current
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: reference) }
        guard !days.isEmpty else { return 0 }
        let adherence = days.map { completionFraction(on: $0) }.reduce(0, +) / CGFloat(days.count)

        let weekStart = WeeklyCheckInEntry.mondayWeekStart(containing: reference)
        let hasThisWeek = weeklyCheckIns.contains { cal.isDate($0.weekStart, inSameDayAs: weekStart) }
        let selfNorm: CGFloat = {
            guard let entry = weeklyCheckIns.first(where: { cal.isDate($0.weekStart, inSameDayAs: weekStart) }) else {
                return adherence
            }
            return CGFloat(entry.normalizedAverage)
        }()

        let hyd = hydrationAdherenceLast7Days(reference: reference)
        let streak = routineStreakDays(reference: reference)
        let streakBoost = min(1, CGFloat(streak) / 10)

        let blended: CGFloat = {
            if hasThisWeek {
                return adherence * 0.38 + selfNorm * 0.32 + hyd * 0.18 + streakBoost * 0.12
            }
            return adherence * 0.62 + hyd * 0.22 + streakBoost * 0.16
        }()

        return min(100, max(0, Int((blended * 100).rounded())))
    }
}
