import SwiftUI

/// Orbital “constellation” hero — silver / white on black (matches Today labs chrome; minimal warm accent).
struct WelcomeOrbitalHeroView: View {
    var compact: Bool = false

    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct OrbitNode: Identifiable {
        let id: String
        let systemImage: String
        let orbitRadius: CGFloat
        let secondsPerRev: Double
        let clockwise: Bool
        let phaseRadians: Double
        let bobPhase: Double
        let gradient: [Color]
        let size: CGFloat
    }

    private let rings: [CGFloat] = [48, 76, 104, 132]

    /// Monochrome silver / white chips — no orange orbit glow.
    private let nodes: [OrbitNode] = [
        OrbitNode(id: "water", systemImage: "drop.fill", orbitRadius: 52, secondsPerRev: 22, clockwise: true, phaseRadians: 0.0, bobPhase: 0.0, gradient: [Color.white.opacity(0.92), Color(white: 0.52)], size: 36),
        OrbitNode(id: "leaf", systemImage: "leaf.fill", orbitRadius: 52, secondsPerRev: 22, clockwise: false, phaseRadians: 2.35, bobPhase: 1.1, gradient: [Color(white: 0.78), Color(white: 0.45)], size: 34),
        OrbitNode(id: "moon", systemImage: "moon.stars.fill", orbitRadius: 78, secondsPerRev: 34, clockwise: false, phaseRadians: 0.8, bobPhase: 2.4, gradient: [Color.white.opacity(0.88), Color(white: 0.58)], size: 36),
        OrbitNode(id: "wind", systemImage: "wind", orbitRadius: 78, secondsPerRev: 34, clockwise: true, phaseRadians: 3.6, bobPhase: 0.6, gradient: [Color(white: 0.42), Color(white: 0.68)], size: 32),
        OrbitNode(id: "spark", systemImage: "sparkles", orbitRadius: 104, secondsPerRev: 48, clockwise: true, phaseRadians: 1.2, bobPhase: 3.2, gradient: [Color.white, Color(white: 0.62)], size: 38),
        OrbitNode(id: "heart", systemImage: "heart.fill", orbitRadius: 104, secondsPerRev: 48, clockwise: false, phaseRadians: 4.5, bobPhase: 1.9, gradient: [Color(white: 0.72), Color(white: 0.48)], size: 34),
        OrbitNode(id: "face", systemImage: "face.smiling.fill", orbitRadius: 128, secondsPerRev: 62, clockwise: true, phaseRadians: 5.1, bobPhase: 4.0, gradient: [Color(white: 0.85), Color(white: 0.55)], size: 36),
        OrbitNode(id: "flame", systemImage: "flame.fill", orbitRadius: 128, secondsPerRev: 62, clockwise: false, phaseRadians: 2.0, bobPhase: 2.7, gradient: [Color(white: 0.88), Color(white: 0.5)], size: 32),
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.2 : 1.0 / 45.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let centerYRatio: CGFloat = compact ? 0.5 : 0.52
                let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * centerYRatio)
                let driftX = reduceMotion ? 0 : CGFloat(parallax.roll * 10)
                let driftY = reduceMotion ? 0 : CGFloat(parallax.pitch * -8)
                let breathe = reduceMotion ? 1.0 : 0.92 + 0.08 * sin(t * 1.15)

                ZStack {
                    ForEach(Array(rings.enumerated()), id: \.offset) { _, r in
                        let pulse = reduceMotion ? 0.09 : 0.07 + 0.04 * sin(t * 0.9 + Double(r) * 0.08)
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.05 + pulse * 0.28),
                                        Color(white: 0.5).opacity(0.06 + pulse * 0.2),
                                        Color.white.opacity(0.025),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: r * 2 * breathe, height: r * 2 * breathe)
                            .position(x: center.x + driftX * 0.15, y: center.y + driftY * 0.12)
                            .blur(radius: 0.2)
                    }

                    ForEach(nodes) { node in
                        let omega = (2 * Double.pi / node.secondsPerRev) * (node.clockwise ? 1 : -1)
                        let angle = reduceMotion ? node.phaseRadians : node.phaseRadians + t * omega
                        let x = CGFloat(cos(angle)) * node.orbitRadius + driftX * 0.08
                        let y = CGFloat(sin(angle)) * node.orbitRadius + driftY * 0.08
                        orbitChip(node: node, time: t)
                            .position(x: center.x + x, y: center.y + y)
                    }

                    centerGem(time: t, at: CGPoint(x: center.x + driftX * 0.06, y: center.y + driftY * 0.05))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(compact ? 0.84 : 1, anchor: .center)
            }
        }
        .frame(height: compact ? 240 : 300)
        .clipped()
        .accessibilityHidden(true)
    }

    private func orbitChip(node: OrbitNode, time: TimeInterval) -> some View {
        let bob = reduceMotion ? 0 : sin(time * 2.4 + node.bobPhase) * 2.5
        return ZStack {
            Circle()
                .fill(.ultraThinMaterial)
            Circle()
                .stroke(Theme.ColorToken.glassStroke, lineWidth: 1)
            Image(systemName: node.systemImage)
                .font(.system(size: node.size * 0.42, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LinearGradient(colors: node.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
        .frame(width: node.size, height: node.size)
        .shadow(color: Color.white.opacity(0.12), radius: reduceMotion ? 3 : 5 + CGFloat(sin(time * 2)) * 1.5)
        .shadow(color: Color.black.opacity(0.45), radius: 4, y: 2)
        .offset(y: bob)
    }

    private func centerGem(time: TimeInterval, at center: CGPoint) -> some View {
        let pulse = reduceMotion ? 1.0 : 0.94 + 0.06 * sin(time * 2.8)
        let glow = reduceMotion ? 12.0 : 14 + 5 * sin(time * 2.2)
        return ZStack {
            Text("U")
                .font(.system(size: compact ? 48 : 40, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(white: 0.82),
                            Color(white: 0.58),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.white.opacity(0.35), radius: glow * 0.45)
                .shadow(color: Color(white: 0.4).opacity(0.2), radius: glow * 0.9)
        }
        .scaleEffect(pulse)
        .position(center)
        .accessibilityLabel("UCare")
    }
}
