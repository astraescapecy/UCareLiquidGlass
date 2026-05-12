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
                    .foregroundStyle(OnboardingLabsChrome.headlineGradient)

                Text("Your space — name, plan, reminders, and data on your terms.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    .lineSpacing(3)

                OnboardingLabsCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Account", systemImage: "person.crop.circle")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text("Placeholder: photo, name, member since, and sign-out.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    }
                }

                OnboardingLabsCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Plan & reminders", systemImage: "bell.badge")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text("Placeholder: edit goals, re-run onboarding, granular notification times.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    }
                }

                OnboardingLabsCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Privacy & data", systemImage: "lock.shield")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text("Placeholder: subscription management, export, delete local data, history.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    }
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .padding(.bottom, 28)
            .opacity(entered ? 1 : 0)
            .offset(y: entered ? 0 : 12)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: entered)
        }
        .ucareScrollOnMesh()
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) {
                entered = true
            }
        }
    }
}
