import SwiftUI

struct PlanRevealView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringProgress: CGFloat = 0
    @State private var animatedSteps = 0
    @State private var revealVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Button {
                        if appState.isRetakeProgramFlow {
                            appState.backToQuestionnaireFromReveal()
                        } else {
                            appState.phase = .paywall
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.thinMaterial))
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                    Spacer()
                }
                Text("Your protocol is ready, \(firstName)")
                    .font(Theme.Typography.title())
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                GlassCard {
                    CalorieRingView(
                        progress: ringProgress,
                        lineWidth: 18,
                        label: "Daily completion target",
                        centerTitle: "\(animatedSteps)",
                        centerSubtitle: "guided steps today"
                    )
                    .frame(height: 240)
                }

                if let profile {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Program preview")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            ForEach(profile.programSteps.prefix(4)) { step in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: step.iconSystemName)
                                        .foregroundStyle(Theme.ColorToken.accentSage)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(step.title).foregroundStyle(Theme.ColorToken.textPrimary)
                                        Text(step.details).font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Text(motivation)
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                GradientCTAButton(title: appState.isRetakeProgramFlow ? "Save updated program" : "Enter UCare") {
                    appState.finalizeOnboarding()
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .opacity(revealVisible ? 1 : 0)
            .scaleEffect(revealVisible ? 1 : 0.98)
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { revealVisible = true }
            ringProgress = 0
            animatedSteps = 0
            let target = profile?.programSteps.count ?? 0
            withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .easeInOut(duration: 1.2)) { ringProgress = 1 }
            for step in 1...20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(step) * 0.04)) {
                    animatedSteps = Int(Double(target) * Double(step) / 20.0)
                }
            }
        }
    }

    private var profile: UserProfile? { appState.previewProfile() }
    private var firstName: String { appState.signUpDraft.fullName.split(separator: " ").first.map(String.init) ?? "there" }
    private var motivation: String {
        guard profile != nil else { return "You're set. Keep it steady this week." }
        return "Miss a day? Yesterday's gone — today's yours. We never guilt-trip; we adjust."
    }
}
