import SwiftUI

/// Shared dark “labs” surfaces for Get Started, auth, and username onboarding (matches Today tab preview).
enum OnboardingLabsChrome {
    static let panelFill = Color(hex: 0x0A0A0A)
    static let hairline = Color.white.opacity(0.18)
    static let secondaryLabel = Color(hex: 0xA0A0A0)

    static var headlineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white,
                Color(white: 0.88),
                Color(hex: 0xA0A0A0),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var silverIconGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.95), Color(white: 0.58)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var ringGradient: AngularGradient {
        AngularGradient(
            colors: [
                Theme.ColorToken.terracotta,
                Color.black,
                Color.white,
                Color(white: 0.52),
                Theme.ColorToken.terracotta,
            ],
            center: .center,
            angle: .degrees(0)
        )
    }
}

struct OnboardingLabsCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Layout.glassCornerRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(Theme.Layout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(OnboardingLabsChrome.panelFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
            }
    }
}

struct OnboardingDecorChip: View {
    let icon: String
    let bob: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(OnboardingLabsChrome.ringGradient, lineWidth: 6)
                .blur(radius: 8)
                .opacity(0.32)

            Circle()
                .fill(Color.white.opacity(0.05))

            Circle()
                .strokeBorder(OnboardingLabsChrome.ringGradient, lineWidth: 1.5)

            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OnboardingLabsChrome.silverIconGradient)
        }
        .frame(width: 38, height: 38)
        .offset(y: bob)
    }
}
