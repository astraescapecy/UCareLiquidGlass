import SwiftUI
import UIKit

/// Phase 1–4 — `TabView`: Today, Progress (Phase 3), Profile (Phase 4); glass tab chrome.
struct MainTabView: View {
    enum Tab: Hashable {
        case today
        case progress
        case profile
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @State private var selectedTab: Tab = .today

    var body: some View {
        ZStack {
            // Extra mesh layer under `TabView` — UIKit tab chrome often paints opaque black above
            // `RootView`’s mesh; this keeps the blurred wallpaper visible on all tabs.
            MeshBackgroundView()
                .environmentObject(parallax)
                .allowsHitTesting(false)

            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max.fill")
                    }
                    .tag(Tab.today)

                ProgressOverviewView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(Tab.progress)

                ProfileOverviewView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(Tab.profile)
            }
            .tint(Theme.ColorToken.terracotta)
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .background(Color.clear)
        }
        .onAppear {
            Self.applyLiquidGlassTabBarAppearance()
            Self.clearTabBarSystemBlackFill()
            Task { await UCareNotificationScheduler.refresh(appState: appState) }
        }
        .onChange(of: selectedTab) { _, _ in
            Self.scheduleTabBarChromeCleanup()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }

    /// Matches the app’s dark glass tab bar (UIKit appearance API).
    private static func applyLiquidGlassTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)

        let accentBlue = UIColor(Theme.ColorToken.terracotta)
        let muted = UIColor(red: 0.65, green: 0.74, blue: 0.88, alpha: 0.38)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = muted
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: muted]
        itemAppearance.selected.iconColor = accentBlue
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: accentBlue]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = accentBlue
        UITabBar.appearance().unselectedItemTintColor = muted
        UITabBar.appearance().isTranslucent = true
    }

    /// SwiftUI’s `TabView` often sits on opaque UIKit containers; clear them so the mesh shows through.
    private static func clearTabBarSystemBlackFill() {
        scheduleTabBarChromeCleanup()
    }

    private static func scheduleTabBarChromeCleanup() {
        for delay in [0.0, 0.08, 0.22, 0.45] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                performTabBarChromeCleanup()
            }
        }
    }

    private static func performTabBarChromeCleanup() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                guard let root = window.rootViewController else { continue }
                window.backgroundColor = .clear
                if let tab = findTabBar(in: root) {
                    tab.view.backgroundColor = .clear
                    tab.children.forEach { $0.view.backgroundColor = .clear }
                    tab.viewControllers?.forEach { $0.view.backgroundColor = .clear }
                }
                clearScrollHostingBackgrounds(in: root.view)
            }
        }
    }

    private static func findTabBar(in controller: UIViewController?) -> UITabBarController? {
        guard let controller else { return nil }
        if let tab = controller as? UITabBarController { return tab }
        for child in controller.children {
            if let tab = findTabBar(in: child) { return tab }
        }
        if let presented = controller.presentedViewController {
            return findTabBar(in: presented)
        }
        return nil
    }

    private static func clearScrollHostingBackgrounds(in view: UIView?) {
        guard let view else { return }
        if let scroll = view as? UIScrollView {
            scroll.backgroundColor = .clear
        } else {
            let name = String(describing: type(of: view))
            if name.contains("SwiftUI"), name.contains("Hosting"), view.bounds.width > 80, view.bounds.height > 80 {
                view.backgroundColor = .clear
            }
        }
        view.subviews.forEach { clearScrollHostingBackgrounds(in: $0) }
    }
}
