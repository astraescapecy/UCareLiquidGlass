import SwiftUI

struct ShimmerParticlesOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.35 : 0.12, paused: false)) { ctx in
            Canvas { context, size in
                guard !reduceMotion else { return }
                let t = ctx.date.timeIntervalSinceReferenceDate
                for i in 0 ..< 48 {
                    let ux = (sin(Double(i) * 1.9 + t * 0.38) + 1) / 2
                    let uy = (cos(Double(i) * 1.35 + t * 0.32) + 1) / 2
                    let x = CGFloat(ux) * size.width
                    let y = CGFloat(uy) * size.height
                    let alpha = 0.07 + 0.11 * abs(sin(t * 0.75 + Double(i)))
                    context.opacity = alpha
                    let rect = CGRect(x: x, y: y, width: 2.0, height: 1.2)
                    context.fill(Path(ellipseIn: rect), with: .color(Theme.ColorToken.shimmerParticle))
                }
            }
            .allowsHitTesting(false)
            .blendMode(.plusLighter)
        }
    }
}
