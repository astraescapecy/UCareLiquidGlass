import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var logoRevealed = false
    @State private var contentOpacity: Double = 1

    var body: some View {
        ZStack {
            ShimmerParticlesOverlay()

            VStack(spacing: 16) {
                Text("UCare")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                    .shadow(color: Theme.ColorToken.glowOuter, radius: logoRevealed ? 18 : 2)
                    .scaleEffect(logoRevealed ? 1 : (reduceMotion ? 1 : 0.78))
                    .opacity(logoRevealed ? 1 : (reduceMotion ? 1 : 0))

                Text("Your body is the project. UCare is the program.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .opacity(logoRevealed ? 1 : 0)
            }
            .padding(.bottom, 40)
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(LLGAnimation.primarySpring(reduceMotion: reduceMotion)) {
                logoRevealed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: reduceMotion ? 0.25 : 0.45)) {
                    contentOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.28 : 0.48)) {
                    appState.completeSplash()
                    contentOpacity = 1
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
