import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false

    private let highlights: [(icon: String, title: String, detail: String)] = [
        ("wind", "Smell, taste, presence", "Protocols for breath, body odor, skin, hair, sleep, and confidence — outside the gym."),
        ("leaf.fill", "Science, not vibes", "Every habit includes a honest “why it works” line — we cite limits, not fairy tales."),
        ("sparkles", "AI-built for you", "Your multi-select goals become a chronological daily stack with timers and streaks."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Become someone people want to be near.")
                        .font(Theme.Typography.largeTitle())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("UCare is the subscription self-care app for skin, hair, breath, hydration, sleep, gut comfort, intimate confidence, and the small rituals that compound.")
                        .font(Theme.Typography.body())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
                .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 10), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -8))

                VStack(spacing: 14) {
                    ForEach(Array(highlights.enumerated()), id: \.offset) { index, item in
                        GlassCard {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Theme.ctaGradient)
                                    .frame(width: 36, height: 36)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.white.opacity(0.06))
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(Theme.Typography.headline())
                                        .foregroundStyle(Theme.ColorToken.textPrimary)
                                    Text(item.detail)
                                        .font(Theme.Typography.subheadline())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(LLGAnimation.entrance(delay: Double(index) * (reduceMotion ? 0 : 0.08), reduceMotion: reduceMotion), value: appeared)
                    }
                }

                VStack(spacing: 14) {
                    GradientCTAButton(title: "Get started") {
                        appState.markWelcomeSeen()
                    }

                    Button {
                        appState.completeAuth()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Already have an account?")
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                        }
                        .font(Theme.Typography.subheadline())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 8) }
        .onAppear {
            appeared = true
        }
    }
}
