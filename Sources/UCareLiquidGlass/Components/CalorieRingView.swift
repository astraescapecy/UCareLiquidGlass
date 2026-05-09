import SwiftUI

struct CalorieRingView: View {
    var progress: CGFloat
    var lineWidth: CGFloat = 18
    var label: String
    var centerTitle: String
    var centerSubtitle: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.ctaGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? .easeInOut(duration: 0.35) : .spring(response: 0.55, dampingFraction: 0.78), value: progress)

            VStack(spacing: 4) {
                Text(centerTitle)
                    .font(Theme.Typography.title())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                    .minimumScaleFactor(0.7)
                Text(centerSubtitle)
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                Text(label)
                    .font(Theme.Typography.footnote())
                    .foregroundStyle(Theme.ColorToken.textTertiary)
                    .padding(.top, 4)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(centerTitle), \(centerSubtitle). \(label)")
    }
}

struct MacroPill: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textTertiary)
                Text(value)
                    .font(Theme.Typography.title2())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text(detail)
                    .font(Theme.Typography.footnote())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
