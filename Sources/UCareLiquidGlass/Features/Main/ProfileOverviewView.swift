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
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showHistory = false
    @State private var showHelp = false
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
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("Your body is the project. UCare is the program.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                if let p = appState.userProfile {
                    // MARK: Account
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Account")
                            HStack(alignment: .top, spacing: 14) {
                                avatarView(for: p)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(p.fullName)
                                        .font(Theme.Typography.title2())
                                        .foregroundStyle(Theme.ColorToken.textPrimary)
                                    Text("Member since \(p.memberSince.formatted(date: .abbreviated, time: .omitted))")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                    Text(p.email)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textTertiary)
                                    Text("@\(p.username)")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textTertiary)
                                    PhotosPicker(selection: $avatarPickerItem, matching: .images, photoLibrary: .shared()) {
                                        Text("Change photo")
                                            .font(Theme.Typography.caption())
                                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
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

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Your program")
                            Text(p.careGoals.map(\.title).joined(separator: " · "))
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Divider().opacity(0.2)
                            infoRow("Diet style", p.dietStyle.title)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Edit goals & program")
                            Text("Update your goals and baseline — we’ll rebuild your stack and show a fresh preview.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Button {
                                appState.beginProgramRetake()
                            } label: {
                                Text("Re-take questionnaire & regenerate")
                                    .font(Theme.Typography.subheadline())
                                    .foregroundStyle(Theme.ColorToken.accentTerracotta)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Reminders
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Reminders & notifications")
                            Toggle("Water rhythm", isOn: reminderBinding(\.wantsWaterReminders))
                                .tint(Theme.ColorToken.accentTerracotta)
                            if appState.userProfile?.wantsWaterReminders == true {
                                Stepper(value: waterIntervalBinding, in: 60...360, step: 15) {
                                    Text("Water nudge interval: \(appState.userProfile?.waterReminderIntervalMinutes ?? 120) min")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                }
                            }
                            Toggle("Morning routine", isOn: reminderBinding(\.wantsMorningNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                            if appState.userProfile?.wantsMorningNudge == true {
                                DatePicker("Morning time", selection: reminderDateBinding(\.reminderMorningMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Theme.ColorToken.accentTerracotta)
                            }
                            Toggle("Evening skincare", isOn: reminderBinding(\.wantsEveningNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                            if appState.userProfile?.wantsEveningNudge == true {
                                DatePicker("Evening time", selection: reminderDateBinding(\.reminderEveningMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Theme.ColorToken.accentTerracotta)
                            }
                            Toggle("Bedtime wind-down", isOn: reminderBinding(\.wantsBedtimeNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                            if appState.userProfile?.wantsBedtimeNudge == true {
                                DatePicker("Bedtime", selection: reminderDateBinding(\.reminderBedtimeMinutes), displayedComponents: .hourAndMinute)
                                    .tint(Theme.ColorToken.accentTerracotta)
                            }
                            Text("UCare schedules local reminders from these times — no ads, no marketing.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textTertiary)
                            Button {
                                openSystemSettings()
                            } label: {
                                Label("Open Settings (notifications & Health)", systemImage: "gearshape")
                                    .font(Theme.Typography.caption())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        }
                    }

                    // MARK: Apple Health
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Apple Health")
                            Toggle(isOn: Binding(
                                get: { appState.userProfile?.syncAppleHealthEnabled ?? false },
                                set: { v in Task { await appState.setAppleHealthBlendEnabled(v) } }
                            )) {
                                Text("Blend water & sleep into Glow-Up")
                                    .font(Theme.Typography.subheadline())
                            }
                            .disabled(appState.healthKitBusy)
                            .tint(Theme.ColorToken.accentTerracotta)
                            Text("Read-only on this device. UCare never uploads Health data.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textTertiary)
                            if let b = appState.healthKitBanner, !b.isEmpty {
                                Text(b)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.accentTerracotta)
                            }
                        }
                    }

                    // MARK: Subscription
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Subscription")
                            Text(appState.hasActiveSubscription ? "UCare Plus is active on this device." : "You’re on the free tier — Day 1 stack only until you subscribe.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Button {
                                Task { await openManageSubscriptions() }
                            } label: {
                                Label("Manage in App Store", systemImage: "creditcard")
                                    .font(Theme.Typography.subheadline())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                            if let manageSubsMessage {
                                Text(manageSubsMessage)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textTertiary)
                            }
                            Button {
                                Task { await restorePurchasesTapped() }
                            } label: {
                                HStack {
                                    if restoreBusy { ProgressView().scaleEffect(0.85) }
                                    Text("Restore purchases")
                                        .font(Theme.Typography.subheadline())
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .disabled(restoreBusy)
                            if let s = appState.storeStatusMessage, !s.isEmpty {
                                Text(s)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textTertiary)
                            }
                            if !appState.hasActiveSubscription {
                                GradientCTAButton(title: "Upgrade to Plus") {
                                    appState.openPaywall()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: History & data
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("History & data")
                            Button("Every completed step") { showHistory = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Button("Export my data (JSON)") { prepareExport() }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Refer & help")
                            ShareLink(item: URL(string: "https://apps.apple.com/app/ucare")!, subject: Text("Try UCare"), message: Text("Your body is the project — UCare is the program.")) {
                                Label("Refer a friend", systemImage: "person.2.fill")
                                    .font(Theme.Typography.subheadline())
                                    .foregroundStyle(Theme.ColorToken.textPrimary)
                            }
                            Button("Help & FAQ") { showHelp = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionLabel("Privacy & media")
                            Text("Protocol, check-ins, and completions stay on this device. Photos you add in Progress or here are JPEGs in Application Support until encrypted sync ships.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Button("Remove profile photo", role: .destructive) {
                                ProfileAvatarStore.clear()
                                avatarVersion += 1
                            }
                            .font(Theme.Typography.subheadline())
                            Button("Delete all weekly Progress photos") {
                                WeeklyProgressPhotoStore.clearAll()
                            }
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        }
                    }

                    // MARK: Session
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionLabel("Session")
                            Text("Log out clears this device’s UCare data and returns you to sign-in. It does not cancel App Store subscriptions — use Manage in App Store above.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textTertiary)
                            GradientCTAButton(title: "Log out") {
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
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Profile unavailable")
                            Text("We couldn’t load your saved profile. You can sign out and sign back in, or remove everything stored on this device.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            GradientCTAButton(title: "Log out & clear device") {
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
        }
        .sheet(isPresented: $showHistory) {
            StepHistoryView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showHelp) {
            HelpFAQView()
        }
        .sheet(item: $exportDocument) { doc in
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Export ready")
                        .font(Theme.Typography.title2())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                    ShareLink(item: doc.url, preview: SharePreview("UCare export", image: Image(systemName: "doc.text"))) {
                        Label("Share JSON", systemImage: "square.and.arrow.up")
                            .font(Theme.Typography.headline())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.ctaGradient.opacity(0.5)))
                    }
                    Button("Done") { exportDocument = nil }
                        .foregroundStyle(Theme.ColorToken.textSecondary)
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

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(Theme.Typography.caption())
            .foregroundStyle(Theme.ColorToken.textSecondary)
            .tracking(0.6)
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key).font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textTertiary)
            Text(value).font(Theme.Typography.subheadline()).foregroundStyle(Theme.ColorToken.textPrimary)
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
                    Circle().strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1)
                }
        } else {
            Circle()
                .fill(Theme.ctaGradient.opacity(0.55))
                .frame(width: 72, height: 72)
                .overlay {
                    Text(initials(for: p.fullName))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.ColorToken.textPrimary)
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
