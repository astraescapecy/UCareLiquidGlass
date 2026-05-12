import SwiftUI

struct SubscriptionCongratsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false
    /// Changing `id` re-triggers `MicroConfettiBurstView` for staggered bursts matching the field.
    @State private var burstWave = 0

    var body: some View {
        ZStack {
            CelebrationConfettiFieldView()
                .ignoresSafeArea()

            ShimmerParticlesOverlay()
                .ignoresSafeArea()
                .opacity(0.85)

            VStack(spacing: 18) {
                ZStack {
                    MicroConfettiBurstView()
                        .id(burstWave)
                    MicroConfettiBurstView()
                        .id(burstWave + 1000)
                        .scaleEffect(1.15)
                        .opacity(0.65)

                    Image(systemName: "seal.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(Theme.ctaGradient)
                        .shadow(color: Theme.ColorToken.glowWarm.opacity(0.6), radius: 18, y: 8)
                }
                .frame(height: 140)
                .padding(.top, 20)

                Text("You’re in.")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                Text("Congrats — UCare Plus is active. Your protocol, Glow-Up Score, and full daily stack are unlocked. Small rituals compound; you just made the easier path the default.")
                    .font(Theme.Typography.body())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer(minLength: 12)

                GradientCTAButton(title: "Begin your protocol") {
                    appState.dismissSubscriptionCongrats()
                }
                .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .onAppear {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
                appeared = true
            }
            guard !reduceMotion else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                burstWave &+= 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.88) {
                burstWave &+= 1
            }
        }
    }
}
