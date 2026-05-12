import SwiftUI
import UIKit

/// Referral hub: animated hero, promo code, share sheet, and “how to earn” — on-device copy only (no referral backend in MVP).
struct ReferFriendView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false
    @State private var copied = false

    private var promoCode: String {
        UCareReferralCode.promoCode(
            username: appState.userProfile?.username ?? appState.username,
            email: appState.userProfile?.email ?? appState.signUpDraft.email
        )
    }

    private var shareMessage: String {
        """
        Join me on UCare — calm routines for skin, sleep, and confidence.

        Use my code: \(promoCode)

        Download: https://apps.apple.com/app/ucare
        """
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackgroundView()
                    .environmentObject(parallax)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ReferFriendOrbitalHeroView()
                            .environmentObject(parallax)
                            .frame(height: 268)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.86)
                            .blur(radius: appeared ? 0 : 2)
                            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appeared)

                        Text("Refer your friend")
                            .font(Theme.Typography.largeTitle())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)
                            .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.06, reduceMotion: reduceMotion), value: appeared)

                        VStack(alignment: .center, spacing: 6) {
                            Text("Empower your friends")
                                .font(Theme.Typography.title2())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Text("& build rituals together")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.12, reduceMotion: reduceMotion), value: appeared)

                        promoBlock
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 26)
                            .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.18, reduceMotion: reduceMotion), value: appeared)

                        shareBlock
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 28)
                            .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.24, reduceMotion: reduceMotion), value: appeared)

                        howToEarnCard
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 32)
                            .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.3, reduceMotion: reduceMotion), value: appeared)

                        Text("Rewards are subject to program terms when UCare referrals go live. Code is generated on this device for sharing today.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(appeared ? 1 : 0)
                            .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.36, reduceMotion: reduceMotion), value: appeared)
                    }
                    .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                    .padding(.bottom, 36)
                }
                .ucareScrollOnMesh()
            }
            .navigationTitle("Refer a friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay { Circle().strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1) }
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private var promoBlock: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your personal promo code")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                HStack(alignment: .center, spacing: 12) {
                    Text(promoCode)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .tracking(2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer(minLength: 8)
                    Button {
                        copyCode()
                    } label: {
                        ZStack {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 18, weight: .semibold))
                                .opacity(copied ? 0 : 1)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Theme.ColorToken.success)
                                .scaleEffect(copied ? 1 : 0.001)
                                .opacity(copied ? 1 : 0)
                        }
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.regularMaterial))
                        .overlay { Circle().strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1) }
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                    .accessibilityLabel(copied ? "Copied" : "Copy promo code")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var shareBlock: some View {
        ShareLink(item: shareMessage, subject: Text("Join me on UCare"), message: Text("Use my code: \(promoCode)")) {
            Text("Share")
                .font(Theme.Typography.headline())
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .fill(Theme.ctaGradient)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private var howToEarnCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text("How to earn")
                        .font(Theme.Typography.headline())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                    ReferFriendCoinBadge()
                    Spacer()
                }

                bulletRow("Share your promo code with friends who’d love calmer body-first routines.")
                bulletRow("Earn $10 per friend when they subscribe with your code — once referral payouts are enabled.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.ctaGradient)
                .padding(.top, 3)
            Text(text)
                .font(Theme.Typography.subheadline())
                .foregroundStyle(Theme.ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func copyCode() {
        UIPasteboard.general.string = promoCode
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
            copied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(LLGAnimation.softFade(reduceMotion: reduceMotion)) {
                copied = false
            }
        }
    }
}

private struct ReferFriendCoinBadge: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.5 : 1.0 / 30.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let deg = reduceMotion ? 0 : sin(t * 2.9) * 14
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.ColorToken.accentWarm, Color(hex: 0xC76A00)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Image(systemName: "dollarsign")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white)
                    .rotationEffect(.degrees(deg))
            }
            .accessibilityHidden(true)
        }
    }
}
