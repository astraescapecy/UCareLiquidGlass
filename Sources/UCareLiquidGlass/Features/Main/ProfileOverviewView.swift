import PhotosUI
import StoreKit
import SwiftUI
import UIKit

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

/// Phase 4 — Profile: account, goals retake, reminder times, StoreKit manage, export, privacy, per-step history.
struct ProfileOverviewView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showHistory = false
    @State private var showHelp = false
    @State private var showReferFriend = false
    @State private var inviteCardAppeared = false
    @State private var exportDocument: ExportDocument?
    @State private var avatarPickerItem: PhotosPickerItem?
    @State private var avatarVersion = 0
    @State private var manageSubsMessage: String?
    @State private var restoreBusy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profile")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                Text("Your body is the project. UCare is the program.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    .lineSpacing(3)

                if let p = appState.userProfile {
                    // MARK: Account
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Account")
                            HStack(alignment: .top, spacing: 14) {
                                avatarView(for: p)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(p.fullName)
                                        .font(Theme.Typography.title2())
                                        .foregroundStyle(Color.white.opacity(0.98))
                                    Text("Member since \(p.memberSince.formatted(date: .abbreviated, time: .omitted))")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                    Text(p.email)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.85))
                                    Text("@\(p.username)")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.85))
                                    PhotosPicker(selection: $avatarPickerItem, matching: .images, photoLibrary: .shared()) {
                                        Text("Change photo")
                                            .font(Theme.Typography.caption())
                                            .foregroundStyle(Color.white.opacity(0.88))
                                    }
                                    .buttonStyle(.plain)
                                    .onChange(of: avatarPickerItem) { _, newItem in
                                        Task { await importAvatar(from: newItem) }
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .id(avatarVersion)

                    // MARK: Go premium (non-subscribers — green outline + glow)
                    if !appState.hasActiveSubscription {
                        GoPremiumOutlineCard {
                            appState.openPaywall()
                        }
                        .opacity(inviteCardAppeared ? 1 : 0)
                        .offset(y: inviteCardAppeared ? 0 : 14)
                        .animation(LLGAnimation.entrance(delay: 0, reduceMotion: reduceMotion), value: inviteCardAppeared)
                    }

                    // MARK: Invite friends — glowing “pop” card (contrast on dark profile mesh)
                    ReferAFriendPopCard {
                        showReferFriend = true
                    }
                    .opacity(inviteCardAppeared ? 1 : 0)
                    .offset(y: inviteCardAppeared ? 0 : 14)
                    .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.08, reduceMotion: reduceMotion), value: inviteCardAppeared)
                    .onAppear {
                        withAnimation { inviteCardAppeared = true }
                    }

                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Your program")
                            Text(p.careGoals.map(\.title).joined(separator: " · "))
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Color.white.opacity(0.95))
                                .fixedSize(horizontal: false, vertical: true)
                            labsHairlineDivider
                            infoRow("Diet style", p.dietStyle.title)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Edit goals & program")
                            Text("Update your goals and baseline — we’ll rebuild your stack and show a fresh preview.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                .lineSpacing(3)
                            Button {
                                appState.beginProgramRetake()
                            } label: {
                                Text("Re-take questionnaire & regenerate")
                                    .font(Theme.Typography.subheadline())
                                    .foregroundStyle(Color.white.opacity(0.88))
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Reminders
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Reminders & notifications")
                            Toggle("Water rhythm", isOn: reminderBinding(\.wantsWaterReminders))
                                .tint(Color.white.opacity(0.9))
                            if appState.userProfile?.wantsWaterReminders == true {
                                Stepper(value: waterIntervalBinding, in: 60...360, step: 15) {
                                    Text("Water nudge interval: \(appState.userProfile?.waterReminderIntervalMinutes ?? 120) min")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                }
                                .foregroundStyle(Color.white.opacity(0.92))
                            }
                            Toggle("Morning routine", isOn: reminderBinding(\.wantsMorningNudge))
                                .tint(Color.white.opacity(0.9))
                            if appState.userProfile?.wantsMorningNudge == true {
                                DatePicker("Morning time", selection: reminderDateBinding(\.reminderMorningMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Color.white.opacity(0.85))
                                    .foregroundStyle(Color.white.opacity(0.92))
                            }
                            Toggle("Evening skincare", isOn: reminderBinding(\.wantsEveningNudge))
                                .tint(Color.white.opacity(0.9))
                            if appState.userProfile?.wantsEveningNudge == true {
                                DatePicker("Evening time", selection: reminderDateBinding(\.reminderEveningMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Color.white.opacity(0.85))
                                    .foregroundStyle(Color.white.opacity(0.92))
                            }
                            Toggle("Bedtime wind-down", isOn: reminderBinding(\.wantsBedtimeNudge))
                                .tint(Color.white.opacity(0.9))
                            if appState.userProfile?.wantsBedtimeNudge == true {
                                DatePicker("Bedtime", selection: reminderDateBinding(\.reminderBedtimeMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Color.white.opacity(0.85))
                                    .foregroundStyle(Color.white.opacity(0.92))
                            }
                            Text("UCare schedules local reminders from these times — no ads, no marketing.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.9))
                            Button {
                                openSystemSettings()
                            } label: {
                                Label("Open Settings (notifications & Health)", systemImage: "gearshape")
                                    .font(Theme.Typography.caption())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.white.opacity(0.82))
                        }
                    }

                    // MARK: Apple Health
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Apple Health")
                            Toggle(isOn: Binding(
                                get: { appState.userProfile?.syncAppleHealthEnabled ?? false },
                                set: { v in Task { await appState.setAppleHealthBlendEnabled(v) } }
                            )) {
                                Text("Blend water & sleep into Glow-Up")
                                    .font(Theme.Typography.subheadline())
                                    .foregroundStyle(Color.white.opacity(0.95))
                            }
                            .disabled(appState.healthKitBusy)
                            .tint(Color.white.opacity(0.9))
                            Text("Read-only on this device. UCare never uploads Health data.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.9))
                            if let b = appState.healthKitBanner, !b.isEmpty {
                                Text(b)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Color.white.opacity(0.88))
                            }
                        }
                    }

                    // MARK: Subscription
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Subscription")
                            Text(appState.hasActiveSubscription ? "UCare Plus is active on this device." : "You’re on the free tier — Day 1 stack only until you subscribe.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                .lineSpacing(3)
                            Button {
                                Task { await openManageSubscriptions() }
                            } label: {
                                Label("Manage in App Store", systemImage: "creditcard")
                                    .font(Theme.Typography.subheadline())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.white.opacity(0.88))
                            if let manageSubsMessage {
                                Text(manageSubsMessage)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.9))
                            }
                            Button {
                                Task { await restorePurchasesTapped() }
                            } label: {
                                HStack {
                                    if restoreBusy { ProgressView().scaleEffect(0.85).tint(.white) }
                                    Text("Restore purchases")
                                        .font(Theme.Typography.subheadline())
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.white.opacity(0.95))
                            .disabled(restoreBusy)
                            if let s = appState.storeStatusMessage, !s.isEmpty {
                                Text(s)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.9))
                            }
                            if !appState.hasActiveSubscription {
                                labsFilledCTA(title: "Upgrade to Plus") {
                                    appState.openPaywall()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: History & data
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("History & data")
                            Button("Every completed step") { showHistory = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Color.white.opacity(0.92))
                            Button("Export my data (JSON)") { prepareExport() }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Color.white.opacity(0.92))
                        }
                    }

                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Help")
                            Button("Help & FAQ") { showHelp = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Color.white.opacity(0.92))
                        }
                    }

                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Privacy & media")
                            Text("Protocol, check-ins, and completions stay on this device. Photos you add in Progress or here are JPEGs in Application Support until encrypted sync ships.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                .lineSpacing(3)
                            Button("Remove profile photo", role: .destructive) {
                                ProfileAvatarStore.clear()
                                avatarVersion += 1
                            }
                            .font(Theme.Typography.subheadline())
                            Button("Delete all weekly Progress photos") {
                                WeeklyProgressPhotoStore.clearAll()
                            }
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Color.white.opacity(0.82))
                        }
                    }

                    // MARK: Session
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionLabel("Session")
                            Text("Log out clears this device’s UCare data and returns you to sign-in. It does not cancel App Store subscriptions — use Manage in App Store above.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.9))
                                .lineSpacing(3)
                            labsFilledCTA(title: "Log out") {
                                showLogoutConfirm = true
                            }
                            Button("Delete local account", role: .destructive) {
                                showDeleteConfirm = true
                            }
                            .font(Theme.Typography.subheadline())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    OnboardingLabsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Profile unavailable")
                            Text("We couldn’t load your saved profile. You can sign out and sign back in, or remove everything stored on this device.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                                .lineSpacing(3)
                            labsFilledCTA(title: "Log out & clear device") {
                                showLogoutConfirm = true
                            }
                            Button("Delete local account only", role: .destructive) {
                                showDeleteConfirm = true
                            }
                            .font(Theme.Typography.subheadline())
                        }
                    }
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .padding(.bottom, 28)
            .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 3), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -2))
        }
        .ucareScrollOnMesh()
        .sheet(isPresented: $showHistory) {
            StepHistoryView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showHelp) {
            HelpFAQView()
        }
        .sheet(isPresented: $showReferFriend) {
            ReferFriendView()
                .environmentObject(appState)
                .environmentObject(parallax)
        }
        .sheet(item: $exportDocument) { doc in
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Export ready")
                        .font(Theme.Typography.title2())
                        .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                    ShareLink(item: doc.url, preview: SharePreview("UCare export", image: Image(systemName: "doc.text"))) {
                        Label("Share JSON", systemImage: "square.and.arrow.up")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                                    .fill(Color.white)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                            }
                    }
                    Button("Done") { exportDocument = nil }
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                }
                .padding()
                .navigationTitle("Export")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .confirmationDialog("Log out of UCare?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                appState.logout()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You’ll return to sign in. Local data for this device will be cleared.")
        }
        .confirmationDialog("Delete everything on this device?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete local account", role: .destructive) {
                appState.deleteLocalAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Removes profile, completions, check-ins, photos, avatar, and subscription flags stored locally. This does not cancel App Store subscriptions — use Manage in App Store or Settings → Subscriptions.")
        }
    }

    private var labsHairlineDivider: some View {
        Rectangle()
            .fill(OnboardingLabsChrome.hairline)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private func labsFilledCTA(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.headline())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .fill(Color.white)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            .tracking(0.5)
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key).font(Theme.Typography.caption()).foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.88))
            Text(value).font(Theme.Typography.subheadline()).foregroundStyle(Color.white.opacity(0.95))
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    @MainActor
    private func restorePurchasesTapped() async {
        restoreBusy = true
        defer { restoreBusy = false }
        await appState.restorePurchases()
    }

    @ViewBuilder
    private func avatarView(for p: UserProfile) -> some View {
        if let data = ProfileAvatarStore.loadJPEGData(), let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                }
        } else {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 72, height: 72)
                .overlay {
                    Circle().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                }
                .overlay {
                    Text(initials(for: p.fullName))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                }
        }
    }

    private func importAvatar(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            guard let ui = UIImage(data: data), let jpg = ui.jpegData(compressionQuality: 0.82) else { return }
            try ProfileAvatarStore.saveJPEG(jpg)
            await MainActor.run {
                avatarVersion += 1
                avatarPickerItem = nil
            }
        } catch {
            await MainActor.run { avatarPickerItem = nil }
        }
    }

    @MainActor
    private func openManageSubscriptions() async {
        manageSubsMessage = nil
        do {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
                manageSubsMessage = "Couldn’t open App Store sheet."
                return
            }
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            manageSubsMessage = error.localizedDescription
        }
    }

    private func prepareExport() {
        guard let data = appState.exportPayloadJSON() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ucare-export-\(Int(Date().timeIntervalSince1970)).json")
        do {
            try data.write(to: url)
            exportDocument = ExportDocument(url: url)
        } catch { }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let chars = parts.prefix(2).compactMap { $0.first }
        return chars.isEmpty ? "U" : String(chars)
    }

    private func reminderBinding(_ keyPath: WritableKeyPath<UserProfile, Bool>) -> Binding<Bool> {
        Binding(
            get: { appState.userProfile?[keyPath: keyPath] ?? false },
            set: { newValue in
                appState.updateProfile { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private var waterIntervalBinding: Binding<Int> {
        Binding(
            get: { appState.userProfile?.waterReminderIntervalMinutes ?? 120 },
            set: { newValue in
                appState.updateProfile { $0.waterReminderIntervalMinutes = min(360, max(60, newValue)) }
            }
        )
    }

    private func reminderDateBinding(_ keyPath: WritableKeyPath<UserProfile, Int>) -> Binding<Date> {
        Binding(
            get: {
                let m = appState.userProfile?[keyPath: keyPath] ?? 0
                let clamped = min(1439, max(0, m))
                return Calendar.current.date(bySettingHour: clamped / 60, minute: clamped % 60, second: 0, of: Date()) ?? .now
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                let mins = min(1439, max(0, (c.hour ?? 0) * 60 + (c.minute ?? 0)))
                appState.updateProfile { $0[keyPath: keyPath] = mins }
            }
        )
    }
}

// MARK: - Go premium (profile — green outline + glow for free tier)

private struct GoPremiumOutlineCard: View {
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var accent: Color { Theme.ColorToken.success }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(OnboardingLabsChrome.panelFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [accent, accent.opacity(0.55), accent.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                    .shadow(color: accent.opacity(reduceMotion ? 0.22 : 0.45), radius: reduceMotion ? 10 : 20, y: 6)
                    .shadow(color: accent.opacity(0.16), radius: 4, y: 0)
                    .shadow(color: Color.black.opacity(0.35), radius: 14, y: 10)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Plus")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(0.9)
                        .textCase(.uppercase)
                        .foregroundStyle(accent.opacity(0.92))

                    Text("Go premium")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Unlock the full protocol — every day, full stack, deeper guidance. Tap to see plans.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(accent)
                            .frame(width: 46, height: 46)
                            .background {
                                Circle()
                                    .fill(accent.opacity(0.14))
                                    .overlay {
                                        Circle()
                                            .strokeBorder(accent.opacity(0.45), lineWidth: 1)
                                    }
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("UCare Plus")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                            Text("View plans & subscribe")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.white.opacity(0.95))
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(accent.opacity(0.65))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                            }
                    }
                }
                .padding(22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }
}

// MARK: - Refer a friend (profile — high-energy “pop” card)

private struct ReferAFriendPopCard: View {
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var glowGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: 0xE85A12),
                Color(hex: 0xF59E2B),
                Color(hex: 0xFFD9A8),
                Color(hex: 0xF0EBE7),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(glowGradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.45), Color.clear],
                                    center: UnitPoint(x: 0.22, y: 0.08),
                                    startRadius: 4,
                                    endRadius: 240
                                )
                            )
                            .blendMode(.screen)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.38), lineWidth: 1)
                    }
                    .shadow(color: Color(hex: 0xFF6B00).opacity(reduceMotion ? 0.2 : 0.42), radius: reduceMotion ? 8 : 28, y: 12)
                    .shadow(color: Color.black.opacity(0.3), radius: 12, y: 10)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Invite friends")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(0.9)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.black.opacity(0.42))

                    Text("Refer a friend and earn $10")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Earn $10 per friend that subscribes with your promo code — tap for your code, share sheet, and details.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.78))
                            .frame(width: 46, height: 46)
                            .background {
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .overlay {
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                                    }
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Promo & share")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.black.opacity(0.45))
                            Text("Open referral hub")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.black.opacity(0.84))
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.38))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.42), lineWidth: 1)
                            }
                    }
                }
                .padding(22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }
}
