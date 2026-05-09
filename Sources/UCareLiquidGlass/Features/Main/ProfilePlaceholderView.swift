import SwiftUI

/// Phase 1 stub — replaced in Phase 4 with account, goals, notifications, export, etc.
struct ProfilePlaceholderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profile")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                Text("Your space — name, plan, reminders, and data on your terms.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Account", systemImage: "person.crop.circle")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: photo, name, member since, and sign-out.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Plan & reminders", systemImage: "bell.badge")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: edit goals, re-run onboarding, granular notification times.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Privacy & data", systemImage: "lock.shield")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: subscription management, export, delete local data, history.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .padding(.bottom, 28)
            .opacity(entered ? 1 : 0)
            .offset(y: entered ? 0 : 12)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: entered)
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) {
                entered = true
            }
        }
    }
}
