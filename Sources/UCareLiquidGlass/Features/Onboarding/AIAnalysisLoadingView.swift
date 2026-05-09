import SwiftUI

struct AIAnalysisLoadingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0
    @State private var pulse = false
    @State private var messageIndex = 0
    @State private var entered = false
    private let messages = [
        "Analyzing your bio-signature…",
        "Mapping odor, skin, sleep, and confidence levers…",
        "Building your 7-day protocol stack…",
        "Tuning reminders to your real schedule…",
        "Almost ready to show your plan…",
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    appState.phase = .paywall
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(.thinMaterial))
                }
                .buttonStyle(GlassCapsuleButtonStyle())
                Spacer()
            }
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
            ZStack {
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 8).frame(width: 140, height: 140)
                Circle().trim(from: 0.1, to: 0.78).stroke(Theme.ctaGradient, style: .init(lineWidth: 8, lineCap: .round))
                    .frame(width: 140, height: 140).rotationEffect(.degrees(rotation))
                Text("UCare AI").foregroundStyle(Theme.ColorToken.textPrimary)
            }
            .scaleEffect(pulse ? 1.03 : 0.97)
            Text(messages[messageIndex]).foregroundStyle(Theme.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .opacity(entered ? 1 : 0)
        .scaleEffect(entered ? 1 : 0.98)
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { entered = true }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { rotation = 360 }
            let pulseAnim = (reduceMotion ? Animation.easeInOut(duration: 1.5) : Animation.easeInOut(duration: 0.9)).repeatForever()
            withAnimation(pulseAnim) { pulse.toggle() }
            for i in 1..<messages.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 1.5)) { messageIndex = i }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { appState.showReveal() }
        }
    }
}
