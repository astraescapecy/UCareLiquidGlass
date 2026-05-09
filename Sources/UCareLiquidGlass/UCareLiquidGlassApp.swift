import SwiftUI

@main
struct UCareLiquidGlassApp: App {
    @AppStorage("ucare.onboardingComplete") private var onboardingComplete = false
    @StateObject private var appState = AppState()
    @StateObject private var motion = ParallaxMotion()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(motion)
                .preferredColorScheme(.dark)
                .onChange(of: appState.phase) { _, newPhase in
                    onboardingComplete = (newPhase == .main)
                }
        }
    }
}
