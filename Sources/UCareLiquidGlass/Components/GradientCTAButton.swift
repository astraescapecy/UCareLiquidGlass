import SwiftUI

struct GradientCTAButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.headline())
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .fill(Theme.ctaGradient)
                        .opacity(isEnabled ? 1 : 0.35)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
        .disabled(!isEnabled)
        .accessibilityHint(isEnabled ? "" : "Complete required fields to continue.")
    }
}
