import SwiftUI

struct CalorieRingView: View {
    var progress: CGFloat
    var lineWidth: CGFloat = 18
    var label: String
    var centerTitle: String
    var centerSubtitle: String
    /// Solid white progress arc (e.g. Today “labs” preview). Default keeps the brand gradient.
    var monochromeProgress: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let diameter = max(0, min(geo.size.width, geo.size.height) - lineWidth * 1.5)
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.14), lineWidth: lineWidth)
                    .frame(width: diameter, height: diameter)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        monochromeProgress ? AnyShapeStyle(Color.white) : AnyShapeStyle(Theme.ctaGradient),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? .easeInOut(duration: 0.35) : .spring(response: 0.55, dampingFraction: 0.78), value: progress)

                VStack(spacing: 3) {
                    Text(centerTitle)
                        .font(Theme.Typography.title())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                    Text(centerSubtitle)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .lineLimit(1)
                    if !label.isEmpty {
                        Text(label)
                            .font(Theme.Typography.footnote())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                            .padding(.top, 3)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(width: diameter * 0.72)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        if label.isEmpty { return "\(centerTitle), \(centerSubtitle)" }
        return "\(centerTitle), \(centerSubtitle). \(label)"
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
