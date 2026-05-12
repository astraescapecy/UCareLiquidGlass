import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false

    private let chips: [(icon: String, title: String)] = [
        ("hands.sparkles", "Hygiene"),
        ("figure.mind.and.body", "Self Improvement"),
        ("scalemass.fill", "Balance"),
    ]

    /// White → silver (Today labs headline), not orange.
    private var headlineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white,
                Color(white: 0.88),
                Color(hex: 0xA0A0A0),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var silverAccentGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.95), Color(white: 0.58)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        GeometryReader { geo in
            let bottomPad = max(geo.safeAreaInsets.bottom, 12)
            VStack(spacing: 0) {
                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    WelcomeOrbitalHeroView(compact: true)
                        .environmentObject(parallax)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(appeared ? 1 : 0.92)
                        .opacity(appeared ? 1 : 0)
                        .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appeared)

                    HStack(spacing: 8) {
                        Text("UCare")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Image(systemName: "sparkle")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(silverAccentGradient)
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.04, reduceMotion: reduceMotion), value: appeared)

                    Text("Become someone people want to be near.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(headlineGradient)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                        .lineLimit(4)
                        .padding(.horizontal, 4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)
                        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.06, reduceMotion: reduceMotion), value: appeared)
                }

                Spacer(minLength: 20)

                HStack(spacing: 10) {
                    ForEach(Array(chips.enumerated()), id: \.offset) { index, chip in
                        GetStartedPillarChip(icon: chip.icon, title: chip.title)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                            .animation(LLGAnimation.entrance(delay: Double(index) * (reduceMotion ? 0 : 0.05) + 0.08, reduceMotion: reduceMotion), value: appeared)
                    }
                }
                .padding(.horizontal, 4)

                Spacer(minLength: 8)

                VStack(spacing: 10) {
                    Button {
                        appState.markWelcomeSeen(openSignIn: true)
                    } label: {
                        Text("Get started")
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
                    Button {
                        appState.markWelcomeSeen(openSignIn: false)
                    } label: {
                        HStack(spacing: 6) {
                            Text("New here?")
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Text("Create an account")
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                        }
                        .font(Theme.Typography.subheadline())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, bottomPad)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
                .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.12, reduceMotion: reduceMotion), value: appeared)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
            .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 6), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -4))
        }
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Get started — pillar chips (gradient ring + glow)

private struct GetStartedPillarChip: View {
    let icon: String
    let title: String

    private var ringGradient: AngularGradient {
        AngularGradient(
            colors: [
                Theme.ColorToken.terracotta,
                Color.black,
                Color.white,
                Color(white: 0.52),
                Theme.ColorToken.terracotta,
            ],
            center: .center,
            angle: .degrees(0)
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(ringGradient, lineWidth: 7)
                    .blur(radius: 10)
                    .opacity(0.34)

                Circle()
                    .fill(Color.white.opacity(0.05))

                Circle()
                    .strokeBorder(ringGradient, lineWidth: 2)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(white: 0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(width: 44, height: 44)

            Text(title)
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
