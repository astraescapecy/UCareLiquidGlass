import SwiftUI

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

struct ProfileOverviewView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var profileVisible = false
    @State private var showHistory = false
    @State private var showHelp = false
    @State private var exportDocument: ExportDocument?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("Your body is the project. UCare is the program.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                if let p = appState.userProfile {
                    GlassCard {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Theme.ctaGradient.opacity(0.55))
                                .frame(width: 56, height: 56)
                                .overlay {
                                    Text(initials(for: p.fullName))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(Theme.ColorToken.textPrimary)
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(p.fullName).foregroundStyle(Theme.ColorToken.textPrimary).font(Theme.Typography.headline())
                                Text(p.email).foregroundStyle(Theme.ColorToken.textSecondary).font(Theme.Typography.caption())
                            }
                            Spacer()
                        }
                    }

                    GlassCard { info("Member since", p.memberSince.formatted(date: .abbreviated, time: .omitted)) }
                    GlassCard { info("UCare ID", "@\(p.username)") }
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your goals")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Text(p.careGoals.map(\.title).joined(separator: " · "))
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassCard { info("Diet style", p.dietStyle.title) }
                    GlassCard { info("Subscription", appState.hasActiveSubscription ? "UCare Plus active" : "Not subscribed") }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Program")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
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
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reminders (saved)")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Toggle("Water rhythm", isOn: reminderBinding(\.wantsWaterReminders))
                                .tint(Theme.ColorToken.accentTerracotta)
                            Toggle("Morning routine", isOn: reminderBinding(\.wantsMorningNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                            Toggle("Evening skincare", isOn: reminderBinding(\.wantsEveningNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                            Toggle("Bedtime wind-down", isOn: reminderBinding(\.wantsBedtimeNudge))
                                .tint(Theme.ColorToken.accentTerracotta)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("History & data")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Button("Step completion history") { showHistory = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Button("Export my data (JSON)") { prepareExport() }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Refer & help")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy & data")
                                .font(Theme.Typography.headline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Text("Photos, intimate notes, and cycle data will be encrypted at rest before cloud sync ships. This build keeps protocol data on-device.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                        }
                    }

                    GradientCTAButton(title: appState.hasActiveSubscription ? "Manage subscription" : "Upgrade to Plus") {
                        appState.openPaywall()
                    }

                    GradientCTAButton(title: "Log out") {
                        showLogoutConfirm = true
                    }

                    Button("Delete local account", role: .destructive) {
                        showDeleteConfirm = true
                    }
                    .font(Theme.Typography.caption())
                    .padding(.top, 4)
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .opacity(profileVisible ? 1 : 0)
            .offset(y: profileVisible ? 0 : 12)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: profileVisible)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appState.userProfile?.username ?? "")
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { profileVisible = true }
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
            Text("Removes profile, completions, check-ins, and subscription flags stored locally. This does not cancel App Store subscriptions — do that in Settings → Subscriptions.")
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

    private func info(_ key: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key).font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
            Text(value).foregroundStyle(Theme.ColorToken.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}
