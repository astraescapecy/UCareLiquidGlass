import SwiftUI

/// Phase 1 stub — replaced in Phase 3 with Glow-Up Score, charts, check-ins, etc.
struct ProgressPlaceholderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                Text("Your trend line lives here — adherence, how you feel in your skin, streaks.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Glow-Up Score", systemImage: "sparkles")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: a 0–100 score and 7-day chart will land in Phase 3.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Weekly check-in", systemImage: "square.and.pencil")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: quick sliders for skin, energy, sleep, confidence, and more.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Discover", systemImage: "books.vertical.fill")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Placeholder: protocols, ingredients, and mini-courses — curated to your goals.")
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
