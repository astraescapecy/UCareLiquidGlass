import Foundation

// MVP privacy posture: protocol + check-ins + per-day completions live in UserDefaults; no ads SDKs. Weekly Progress selfies live as JPEGs under Application Support (Phase 3) until encrypted sync ships.

final class OnboardingPersistence {
    private enum Key {
        static let sawWelcome = "ucare.sawWelcome"
        static let profileJSON = "ucare.profile"
        static let draftJSON = "ucare.draft"
        static let username = "ucare.username"
        static let completionPrefix = "ucare.program.done."
        static let weeklyCheckIns = "ucare.weeklyCheckIns.v1"
        static let achievementPrefix = "ucare.ach."
        static let subscriptionCongratsDismissed = "ucare.subscriptionCongratsDismissed"
        /// Set when a verified purchase sends the user to `.analysis` (no profile yet); consumed in `finalizeOnboarding` so congrats still show if entitlements lag.
        static let pendingPostOnboardingCongrats = "ucare.pendingPostOnboardingCongrats"
        // Legacy keys (pre UCare spec alignment)
        static let legacySawWelcome = "youcare.sawWelcome"
        static let legacyProfileJSON = "youcare.profile"
        static let legacyDraftJSON = "youcare.questionnaireDraft"
        static let legacyUsername = "youcare.username"
        static let legacyCompletionPrefix = "youcare.program.done."
    }

    private let defaults = UserDefaults.standard

    init() {
        migrateLegacyKeysIfNeeded()
    }

    private func migrateLegacyKeysIfNeeded() {
        if !defaults.bool(forKey: Key.sawWelcome), defaults.bool(forKey: Key.legacySawWelcome) {
            defaults.set(defaults.bool(forKey: Key.legacySawWelcome), forKey: Key.sawWelcome)
        }
        if defaults.data(forKey: Key.profileJSON) == nil, let d = defaults.data(forKey: Key.legacyProfileJSON) {
            defaults.set(d, forKey: Key.profileJSON)
        }
        if defaults.data(forKey: Key.draftJSON) == nil, let d = defaults.data(forKey: Key.legacyDraftJSON) {
            defaults.set(d, forKey: Key.draftJSON)
        }
        if (defaults.string(forKey: Key.username) ?? "").isEmpty, let u = defaults.string(forKey: Key.legacyUsername), !u.isEmpty {
            defaults.set(u, forKey: Key.username)
        }
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Key.legacyCompletionPrefix) {
            let suffix = key.dropFirst(Key.legacyCompletionPrefix.count)
            let newKey = Key.completionPrefix + suffix
            if defaults.data(forKey: newKey) == nil, let data = defaults.data(forKey: key) {
                defaults.set(data, forKey: newKey)
            }
        }
    }

    var sawWelcome: Bool {
        get { defaults.bool(forKey: Key.sawWelcome) }
        set { defaults.set(newValue, forKey: Key.sawWelcome) }
    }

    var username: String {
        get { defaults.string(forKey: Key.username) ?? "" }
        set { defaults.set(newValue, forKey: Key.username) }
    }

    /// After the user dismisses the post-subscribe congrats sheet, repeat **restore** skips it until subscription lapses (see `refreshEntitlementsFromStore`).
    var subscriptionCongratsDismissed: Bool {
        get { defaults.bool(forKey: Key.subscriptionCongratsDismissed) }
        set { defaults.set(newValue, forKey: Key.subscriptionCongratsDismissed) }
    }

    var pendingPostOnboardingCongrats: Bool {
        get { defaults.bool(forKey: Key.pendingPostOnboardingCongrats) }
        set { defaults.set(newValue, forKey: Key.pendingPostOnboardingCongrats) }
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Key.profileJSON)
        }
    }

    func loadProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Key.profileJSON) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    func saveDraft(_ draft: QuestionnaireDraft) {
        if let data = try? JSONEncoder().encode(draft) {
            defaults.set(data, forKey: Key.draftJSON)
        }
    }

    func loadDraft() -> QuestionnaireDraft? {
        guard let data = defaults.data(forKey: Key.draftJSON) else { return nil }
        return try? JSONDecoder().decode(QuestionnaireDraft.self, from: data)
    }

    func clearAll() {
        [
            Key.sawWelcome, Key.profileJSON, Key.draftJSON, Key.username, Key.weeklyCheckIns,
            Key.subscriptionCongratsDismissed, Key.pendingPostOnboardingCongrats,
            Key.legacySawWelcome, Key.legacyProfileJSON, Key.legacyDraftJSON, Key.legacyUsername,
        ].forEach(defaults.removeObject(forKey:))
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Key.completionPrefix) || key.hasPrefix(Key.legacyCompletionPrefix) {
            defaults.removeObject(forKey: key)
        }
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Key.achievementPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    func loadWeeklyCheckIns() -> [WeeklyCheckInEntry] {
        guard let data = defaults.data(forKey: Key.weeklyCheckIns) else { return [] }
        return (try? JSONDecoder().decode([WeeklyCheckInEntry].self, from: data)) ?? []
    }

    func saveWeeklyCheckIns(_ entries: [WeeklyCheckInEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: Key.weeklyCheckIns)
        }
    }

    func achievementFlag(_ name: String) -> Bool {
        defaults.bool(forKey: Key.achievementPrefix + name)
    }

    func setAchievementFlag(_ name: String, _ value: Bool) {
        defaults.set(value, forKey: Key.achievementPrefix + name)
    }

    private func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    func loadCompletedStepIDs(for date: Date = .now) -> Set<String> {
        let key = Key.completionPrefix + dayKey(date)
        guard let data = defaults.data(forKey: key), let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return Set(arr)
    }

    func saveCompletedStepIDs(_ ids: Set<String>, for date: Date = .now) {
        let key = Key.completionPrefix + dayKey(date)
        if let data = try? JSONEncoder().encode(Array(ids)) {
            defaults.set(data, forKey: key)
        }
    }

    /// Days that have at least one completed step id stored (newest first).
    func completionDaySummaries() -> [(date: Date, count: Int)] {
        var rows: [(date: Date, count: Int)] = []
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Key.completionPrefix) {
            let suffix = String(key.dropFirst(Key.completionPrefix.count))
            guard suffix.count == 8,
                  let y = Int(suffix.prefix(4)),
                  let m = Int(suffix.dropFirst(4).prefix(2)),
                  let d = Int(suffix.suffix(2)),
                  let date = Calendar.current.date(from: DateComponents(year: y, month: m, day: d))
            else { continue }
            guard let data = defaults.data(forKey: key),
                  let arr = try? JSONDecoder().decode([String].self, from: data),
                  !arr.isEmpty
            else { continue }
            rows.append((date: date, count: arr.count))
        }
        return rows.sorted { $0.date > $1.date }
    }

    /// Every stored completion day with the raw step id list (newest day first).
    func allCompletionDaysWithStepIds() -> [(date: Date, stepIds: [String])] {
        var rows: [(date: Date, stepIds: [String])] = []
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Key.completionPrefix) {
            let suffix = String(key.dropFirst(Key.completionPrefix.count))
            guard suffix.count == 8,
                  let y = Int(suffix.prefix(4)),
                  let m = Int(suffix.dropFirst(4).prefix(2)),
                  let d = Int(suffix.suffix(2)),
                  let date = Calendar.current.date(from: DateComponents(year: y, month: m, day: d))
            else { continue }
            guard let data = defaults.data(forKey: key),
                  let arr = try? JSONDecoder().decode([String].self, from: data),
                  !arr.isEmpty
            else { continue }
            rows.append((date: date, stepIds: arr))
        }
        return rows.sorted { $0.date > $1.date }
    }
}
