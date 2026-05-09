import SwiftUI
import UIKit

/// Phase 1 shell: native three-tab `TabView` (Today · Progress · Profile) with liquid-glass tab chrome.
/// Today hosts the routine checklist; Progress/Profile reuse the richer views already built for later phases.
struct MainTabView: View {
    enum Tab: Hashable {
        case today
        case progress
        case profile
    }

    @State private var selectedTab: Tab = .today

    var body: some View {
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
        .tint(Theme.ColorToken.accentTerracotta)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            Self.applyLiquidGlassTabBarAppearance()
        }
    }

    /// Matches the app’s warm glass look on the system tab bar (UIKit appearance API).
    private static func applyLiquidGlassTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Theme.ColorToken.backgroundBase).withAlphaComponent(0.35)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)

        let terracotta = UIColor(red: 184 / 255, green: 107 / 255, blue: 82 / 255, alpha: 1)
        let muted = UIColor(white: 1, alpha: 0.42)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = muted
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: muted]
        itemAppearance.selected.iconColor = terracotta
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: terracotta]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = terracotta
        UITabBar.appearance().unselectedItemTintColor = muted
    }
}
