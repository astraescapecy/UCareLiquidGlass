import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var appeared = false
    @State private var purchasing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if appState.userProfile == nil {
                        Button {
                            appState.phase = .questionnaire
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(.thinMaterial))
                        }
                        .buttonStyle(GlassCapsuleButtonStyle())
                    }
                    Spacer()
                    if appState.userProfile != nil, appState.hasActiveSubscription {
                        Button("Close") { appState.phase = .main }
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }

                Text("Unlock UCare Plus")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("7-day full access trial — then stay on your protocol with weekly unlocks, Glow-Up Score, and guided steps.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                if let msg = appState.storeStatusMessage, !msg.isEmpty {
                    Text(msg)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.accentSand)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                }

                VStack(spacing: 10) {
                    featureRow("AI-personalized weekly protocol (outside-the-gym self care)")
                    featureRow("Today tab with timers, science blurbs, and streaks")
                    featureRow("Progress tab: Glow-Up Score + before/after roadmap")
                    featureRow("No guilt if you miss a day — we pick you up tomorrow")
                }

                VStack(spacing: 12) {
                    ForEach(PaywallPlan.allCases) { plan in
                        planCard(plan)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)
                            .animation(LLGAnimation.entrance(delay: delay(for: plan), reduceMotion: reduceMotion), value: appeared)
                    }
                }

                GradientCTAButton(title: ctaTitle, isEnabled: !purchasing) {
                    Task {
                        purchasing = true
                        await appState.purchaseFromStore(selectedPlan)
                        purchasing = false
                    }
                }
                Button("Restore Purchases") {
                    Task { await appState.restorePurchases() }
                }
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textSecondary)

                Text("Subscriptions are not medical advice. UCare is for education and habit design. Auto-renews unless canceled. Terms & Privacy apply.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textTertiary)
                    .padding(.top, 4)
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { appeared = true }
        }
        .task {
            await appState.loadStoreProducts()
        }
    }

    private var ctaTitle: String {
        if purchasing { return "Processing…" }
        switch selectedPlan {
        case .monthly: return "Start Plus — Monthly"
        case .yearly: return "Start 7-Day Free Trial"
        case .lifetime: return "Unlock Lifetime"
        }
    }

    private func delay(for plan: PaywallPlan) -> Double {
        switch plan {
        case .monthly: return reduceMotion ? 0 : 0.04
        case .yearly: return reduceMotion ? 0 : 0.09
        case .lifetime: return reduceMotion ? 0 : 0.14
        }
    }

    private func displayPrice(for plan: PaywallPlan) -> String {
        appState.storeProducts.first(where: { $0.id == plan.storeProductID })?.displayPrice ?? plan.priceLine
    }

    private func planCard(_ plan: PaywallPlan) -> some View {
        let on = selectedPlan == plan
        return Button {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) { selectedPlan = plan }
        } label: {
            GlassCard(cornerRadius: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(plan.title).font(Theme.Typography.headline()).foregroundStyle(Theme.ColorToken.textPrimary)
                        Text(displayPrice(for: plan)).font(Theme.Typography.subheadline()).foregroundStyle(Theme.ColorToken.textPrimary)
                        Text(plan.subtitle).font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                    Spacer()
                    Image(systemName: on ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(on ? Theme.ColorToken.success : Theme.ColorToken.textTertiary)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(on ? Theme.ctaGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
            }
            .shadow(color: on ? Theme.ColorToken.glowOuter : .clear, radius: on ? 14 : 0)
            .scaleEffect(on ? 1.01 : 1)
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .foregroundStyle(Theme.ColorToken.accentSage)
            Text(text)
                .font(Theme.Typography.subheadline())
                .foregroundStyle(Theme.ColorToken.textSecondary)
            Spacer()
        }
    }
}
