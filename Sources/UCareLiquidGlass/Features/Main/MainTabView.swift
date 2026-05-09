import SwiftUI

struct MainTabView: View {
    enum Tab: String, CaseIterable { case today, progress, profile }

    @State private var tab: Tab = .today
    @State private var bounceTab: Tab = .today
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .today: TodayView()
                case .progress: ProgressOverviewView()
                case .profile: ProfileOverviewView()
                }
            }
            .padding(.bottom, Theme.Layout.tabBarHeight + 22)

            HStack(alignment: .center, spacing: 0) {
                sideTab(.today, icon: "sun.max.fill", label: "Today")
                Spacer(minLength: 12)
                centerProgressTab
                Spacer(minLength: 12)
                sideTab(.profile, icon: "person.fill", label: "Profile")
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1)
            }
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
            .padding(.bottom, 10)
        }
    }

    private func sideTab(_ target: Tab, icon: String, label: String) -> some View {
        let on = tab == target
        return Button {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
                tab = target
                bounceTab = target
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                bounceTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .scaleEffect(on ? (bounceTab == target ? 1.12 : 1.06) : 1)
                Text(label)
                    .font(Theme.Typography.caption())
                Circle().fill(on ? Theme.ColorToken.accentTerracotta : Color.clear).frame(width: 5, height: 5)
            }
            .foregroundStyle(on ? Theme.ColorToken.textPrimary : Theme.ColorToken.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private var centerProgressTab: some View {
        let on = tab == .progress
        return Button {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
                tab = .progress
                bounceTab = .progress
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                bounceTab = tab
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.ctaGradient.opacity(on ? 0.95 : 0.55))
                    .frame(width: 58, height: 58)
                    .shadow(color: Theme.ColorToken.glowWarm.opacity(on ? 0.9 : 0.35), radius: on ? 18 : 10, y: 6)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
                    .scaleEffect(on ? (bounceTab == .progress ? 1.08 : 1.02) : 1)
            }
            .accessibilityLabel("Progress")
        }
        .buttonStyle(GlassCapsuleButtonStyle())
        .offset(y: on ? -4 : -2)
    }
}
