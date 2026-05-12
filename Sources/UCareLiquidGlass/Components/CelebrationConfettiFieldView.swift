import SwiftUI

/// Ambient confetti using the same palette as `MicroConfettiBurstView` — slow drift for celebration screens.
struct CelebrationConfettiFieldView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let palette: [Color] = [
        Theme.ColorToken.accentTerracotta,
        Theme.ColorToken.accentSage,
        Theme.ColorToken.accentSand,
        Theme.ColorToken.accentWarm,
        Theme.ColorToken.warmWhite.opacity(0.88),
    ]

    var body: some View {
        Group {
            if reduceMotion {
                Color.clear
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 24.0, paused: false)) { timeline in
                    GeometryReader { geo in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        ZStack {
                            ForEach(0..<40, id: \.self) { i in
                                confettiPiece(index: i, t: t, in: geo.size)
                            }
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .blendMode(.plusLighter)
    }

    private func confettiPiece(index i: Int, t: TimeInterval, in size: CGSize) -> some View {
        let colors = Self.palette
        let seed = Double(i) * 1.618 + 0.37
        let phase = t * (0.35 + Double(i % 7) * 0.04)
        let x = CGFloat((sin(seed * 3.1 + phase * 0.6) + 1) / 2) * size.width
        let y = CGFloat(fmod(Double(i) * 37 + phase * 44, Double(size.height + 80))) - 40
        let w = CGFloat(3 + (i % 5))
        let h = CGFloat(2 + (i % 4))
        let rot = sin(seed + phase) * 28
        let opacity = 0.12 + 0.18 * abs(sin(phase * 0.9 + seed))
        return RoundedRectangle(cornerRadius: 1, style: .continuous)
            .fill(colors[i % colors.count].opacity(opacity))
            .frame(width: w, height: h)
            .rotationEffect(.degrees(rot))
            .position(x: x, y: y)
    }
}
