import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Layout.glassCornerRadius
    var material: Material = .thinMaterial
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(Theme.Layout.cardPadding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.ColorToken.glowOuter.opacity(0.18), lineWidth: 0.5)
                    .blur(radius: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 24, y: 14)
    }
}

struct GlassCapsuleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? (reduceMotion ? 1.0 : 0.96) : 1.0)
            .animation(LLGAnimation.buttonPress(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}
