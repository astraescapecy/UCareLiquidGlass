import SwiftUI
import UIKit

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
                .background(Color.clear)
                .onAppear {
                    DispatchQueue.main.async {
                        Self.makeWindowsTransparentForMesh()
                    }
                }
                .onChange(of: appState.phase) { _, newPhase in
                    onboardingComplete = (newPhase == .main)
                }
        }
    }

    /// Lets the blurred mesh show edge-to-edge instead of UIKit’s default black fills behind `TabView` / `ScrollView` / lists.
    private static func makeWindowsTransparentForMesh() {
        if !didConfigureGlobalScrollChrome {
            didConfigureGlobalScrollChrome = true
            UIScrollView.appearance().backgroundColor = .clear
            UITableView.appearance().backgroundColor = .clear
            UICollectionView.appearance().backgroundColor = .clear
        }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.backgroundColor = .clear
            }
        }
    }

    private static var didConfigureGlobalScrollChrome = false
}
