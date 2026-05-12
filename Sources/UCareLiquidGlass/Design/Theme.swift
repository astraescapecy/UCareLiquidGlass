import SwiftUI

enum Theme {
    enum ColorToken {
        /// Glossy dark — pure black with lifted charcoal for depth.
        static let backgroundBase = Color(hex: 0x000000)
        static let backgroundAlt = Color(hex: 0x0A0A0C)
        static let surfaceGlass = Color(hex: 0x141418)

        /// Silver / steel for secondary chrome (legacy names: sage).
        static let sand = Color(hex: 0xF2F4F8)
        static let sage = Color(hex: 0xC8CED9)
        static let sageMuted = Color(hex: 0x4A505C)

        /// Primary “fire” accent (legacy `terracotta` = mid flame for single-color uses).
        static let terracotta = Color(hex: 0xFF8A00)
        static let terracottaDeep = Color(hex: 0x8B1538)

        static let warmWhite = Color(hex: 0xF8F9FC)

        static let textPrimary = Color(hex: 0xFFFFFF).opacity(0.96)
        static let textSecondary = Color(hex: 0xE4E8EF).opacity(0.55)
        static let textTertiary = Color(hex: 0xB8C0CC).opacity(0.42)

        static let glassStroke = Color.white.opacity(0.16)
        static let glassStrokeFocus = Color.white.opacity(0.38)

        /// Username / status (neon green vs deep red, per spec).
        static let usernameAvailable = Color(hex: 0x39FF88)
        static let usernameTaken = Color(hex: 0xC62828)

        static let success = Color(hex: 0x39FF88)
        static let error = Color(hex: 0xE53935)

        static let shimmerParticle = Color.white.opacity(0.2)

        /// Warm rim / glow (iridescent edge).
        static let glowWarm = Color(hex: 0xFF6B00).opacity(0.38)

        static let accentWarm = Color(hex: 0xFFD60A)

        static let glowOuter = glowWarm
        static let ctaSlate = sage
        static let ctaIndigo = terracottaDeep

        static let accentSage = sage
        static let accentTerracotta = terracotta
        static let accentSand = sand
    }

    enum Typography {
        static func largeTitle() -> Font { .system(.largeTitle, design: .rounded, weight: .bold) }
        static func title() -> Font { .system(.title, design: .rounded, weight: .bold) }
        static func title2() -> Font { .system(.title2, design: .rounded, weight: .semibold) }
        static func headline() -> Font { .system(.headline, design: .rounded, weight: .semibold) }
        static func body() -> Font { .system(.body, design: .rounded, weight: .regular) }
        static func subheadline() -> Font { .system(.subheadline, design: .rounded, weight: .regular) }
        static func footnote() -> Font { .system(.footnote, design: .rounded, weight: .medium) }
        static func caption() -> Font { .system(.caption, design: .rounded, weight: .medium) }
    }

    enum Layout {
        static let glassCornerRadius: CGFloat = 22
        static let fieldCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 18
        static let contentHorizontalPadding: CGFloat = 22
        static let tabBarHeight: CGFloat = 62
        static let floatingButtonSize: CGFloat = 58
    }

    /// Primary CTA — deep red → orange → yellow (liquid / iridescent edge).
    static let ctaGradient = LinearGradient(
        colors: [
            ColorToken.terracottaDeep,
            Color(hex: 0xFF4500),
            ColorToken.terracotta,
            ColorToken.accentWarm,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sageGradient = LinearGradient(
        colors: [ColorToken.sageMuted, ColorToken.sage],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let paperGradient = LinearGradient(
        colors: [ColorToken.backgroundAlt, ColorToken.backgroundBase],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension View {
    /// Hides the system scroll view fill so `MeshBackgroundView` in `RootView` stays visible behind lists and scroll content.
    func ucareScrollOnMesh() -> some View {
        scrollContentBackground(.hidden)
    }
}
