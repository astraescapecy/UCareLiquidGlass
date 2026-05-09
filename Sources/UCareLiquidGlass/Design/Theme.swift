import SwiftUI

enum Theme {
    enum ColorToken {
        /// Deep warm paper — Aesop-adjacent, not neon wellness.
        static let backgroundBase = Color(hex: 0x1A1814)
        static let backgroundAlt = Color(hex: 0x221E19)
        static let surfaceGlass = Color(hex: 0x2A2620)
        static let sand = Color(hex: 0xC4B8A5)
        static let sage = Color(hex: 0x8B9A7E)
        static let sageMuted = Color(hex: 0x5F6B55)
        static let terracotta = Color(hex: 0xB86B52)
        static let terracottaDeep = Color(hex: 0x8E4A3A)
        static let warmWhite = Color(hex: 0xF5F0E8)
        static let textPrimary = Color(hex: 0xF5F0E8).opacity(0.95)
        static let textSecondary = Color(hex: 0xF5F0E8).opacity(0.55)
        static let textTertiary = Color(hex: 0xF5F0E8).opacity(0.38)
        static let glassStroke = Color.white.opacity(0.12)
        static let glassStrokeFocus = Color.white.opacity(0.22)
        static let success = Color(hex: 0x6B9B7A)
        static let error = Color(hex: 0xC45C4A)
        static let shimmerParticle = Color.white.opacity(0.18)
        static let glowWarm = Color(hex: 0xB86B52).opacity(0.35)

        /// Backward-compatible names used across glass / selection UI.
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

    static let ctaGradient = LinearGradient(
        colors: [ColorToken.terracottaDeep, ColorToken.terracotta],
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
