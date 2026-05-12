import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            MeshBackgroundView()
                .environmentObject(parallax)

            // Same soft shimmer as splash — keeps every phase on the “blurred gradient” look, not flat black.
            ShimmerParticlesOverlay()

            phaseContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .transition(reduceMotion ? .opacity : phaseTransition)
        }
        .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: appState.phase)
        .onChange(of: appState.phase) { _, newPhase in
            if newPhase == .main {
                Task { await UCareNotificationScheduler.refresh(appState: appState) }
            } else {
                UCareNotificationScheduler.cancelAll()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, appState.phase == .main {
                Task { await UCareNotificationScheduler.refresh(appState: appState) }
                Task { await appState.refreshAppleHealthIfEnabled() }
            }
        }
    }

    private var phaseTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch appState.phase {
        case .splash:
            SplashView()
        case .getStarted:
            GetStartedView()
                .environmentObject(parallax)
        case .auth:
            SignUpView()
                .environmentObject(parallax)
        case .usernameSetup:
            UsernameSetupView()
                .environmentObject(parallax)
        case .questionnaire:
            QuestionnaireFlowView()
                .environmentObject(parallax)
        case .paywall:
            PaywallView()
        case .subscriptionCongrats:
            SubscriptionCongratsView()
        case .analysis:
            AIAnalysisLoadingView()
        case .reveal:
            PlanRevealView()
        case .main:
            MainTabView()
                .transition(.opacity)
        }
    }
}
