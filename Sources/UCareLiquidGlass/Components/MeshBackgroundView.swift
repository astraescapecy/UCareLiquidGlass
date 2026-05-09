import SwiftUI

struct MeshBackgroundView: View {
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 10.0 : 1.0 / 30.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            mesh(at: t)
        }
        .ignoresSafeArea()
    }

    private func mesh(at t: TimeInterval) -> some View {
        let shiftX = reduceMotion ? 0 : CGFloat(parallax.roll * 8)
        let shiftY = reduceMotion ? 0 : CGFloat(parallax.pitch * 8)
        let slow = reduceMotion ? 0 : t * 0.04
        let wobble = sin(slow)

        return ZStack {
            Theme.paperGradient

            RadialGradient(
                colors: [
                    Theme.ColorToken.sage.opacity(0.18 + 0.04 * wobble),
                    .clear,
                ],
                center: UnitPoint(x: 0.18 + shiftX / 240, y: 0.22 + CGFloat(sin(slow * 0.6)) * 0.04),
                startRadius: 20,
                endRadius: 380
            )
            .blendMode(.softLight)

            RadialGradient(
                colors: [
                    Theme.ColorToken.terracotta.opacity(0.14 + 0.03 * sin(slow * 0.85)),
                    .clear,
                ],
                center: UnitPoint(x: 0.88 + CGFloat(cos(slow * 0.5)) * 0.05, y: 0.78 + shiftY / 300),
                startRadius: 30,
                endRadius: 440
            )
            .blendMode(.plusLighter)

            RadialGradient(
                colors: [
                    Theme.ColorToken.sand.opacity(0.12),
                    .clear,
                ],
                center: UnitPoint(x: 0.55 + shiftX / 280, y: 0.42 + 0.03 * cos(slow * 0.45)),
                startRadius: 40,
                endRadius: 500
            )
            .blendMode(.softLight)
        }
    }
}
