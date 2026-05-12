import SwiftUI

/// Cal-style “friends around the logo” hero with UCare’s black / electric-blue glass vibe.
struct ReferFriendOrbitalHeroView: View {
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Buddy: Identifiable {
        let id: Int
        let angle: Double
        let radius: CGFloat
        let size: CGFloat
        let colors: [Color]
        let bobPhase: Double
        let wobblePhase: Double
    }

    private let buddies: [Buddy] = [
        Buddy(id: 0, angle: 0.15, radius: 76, size: 40, colors: [Color(hex: 0x2F5F8F), Color(hex: 0x153A5C)], bobPhase: 0.0, wobblePhase: 0.2),
        Buddy(id: 1, angle: 1.25, radius: 84, size: 38, colors: [Color(hex: 0x1E6B8A), Color(hex: 0x0D3D52)], bobPhase: 0.9, wobblePhase: 1.1),
        Buddy(id: 2, angle: 2.1, radius: 70, size: 36, colors: [Color(hex: 0x3A7CA5), Color(hex: 0x1A4A6E)], bobPhase: 1.6, wobblePhase: 0.5),
        Buddy(id: 3, angle: 3.0, radius: 92, size: 42, colors: [Color(hex: 0x2F8FFF), Color(hex: 0x003D82)], bobPhase: 2.2, wobblePhase: 1.8),
        Buddy(id: 4, angle: 4.0, radius: 78, size: 36, colors: [Color(hex: 0x5B6BB8), Color(hex: 0x323D7A)], bobPhase: 3.0, wobblePhase: 2.4),
        Buddy(id: 5, angle: 5.2, radius: 88, size: 40, colors: [Color(hex: 0xFF9F0A), Color(hex: 0xC76A00)], bobPhase: 2.6, wobblePhase: 0.9),
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 1.0 / 50.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                let driftX = reduceMotion ? 0 : CGFloat(parallax.roll * 12)
                let driftY = reduceMotion ? 0 : CGFloat(parallax.pitch * -10)
                let hubPulse = reduceMotion ? 1.0 : 0.94 + 0.06 * sin(t * 2.5)

                ZStack {
                    ForEach(buddies) { b in
                        let wobble = reduceMotion ? 0 : sin(t * 1.9 + b.wobblePhase) * 5
                        let bob = reduceMotion ? 0 : sin(t * 2.3 + b.bobPhase) * 4
                        let r = b.radius + wobble
                        let ang = b.angle + (reduceMotion ? 0 : t * 0.06 * (b.id % 2 == 0 ? 1 : -1))
                        let x = CGFloat(cos(ang)) * r + driftX * 0.1
                        let y = CGFloat(sin(ang)) * r + driftY * 0.08 + bob
                        buddyCircle(colors: b.colors, time: t, index: b.id)
                            .frame(width: b.size, height: b.size)
                            .position(x: center.x + x, y: center.y + y)
                    }

                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 88 * hubPulse, height: 88 * hubPulse)
                            .overlay {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Theme.ColorToken.warmWhite.opacity(0.35),
                                                Theme.ColorToken.sage.opacity(0.25),
                                                Theme.ColorToken.terracotta.opacity(0.2),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            }
                            .shadow(color: Theme.ColorToken.glowWarm.opacity(0.45), radius: reduceMotion ? 10 : 14 + 4 * sin(t * 2.2))

                        Image(systemName: "sparkle")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.ColorToken.sand, Theme.ColorToken.terracotta, Theme.ColorToken.sage],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(hubPulse)
                    }
                    .position(x: center.x + driftX * 0.05, y: center.y + driftY * 0.04)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private func buddyCircle(colors: [Color], time: TimeInterval, index: Int) -> some View {
        let innerPulse = reduceMotion ? 1.0 : 0.96 + 0.04 * sin(time * 2.8 + Double(index) * 0.4)
        return ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.92))
                .scaleEffect(innerPulse)
        }
        .overlay {
            Circle()
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: colors.last.map { $0.opacity(0.35) } ?? Color.clear, radius: 8, y: 4)
    }
}
