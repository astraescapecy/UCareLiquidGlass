import SwiftUI

/// Short burst of particles when a Today step is marked complete (Phase 2).
struct MicroConfettiBurstView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst = false

    private let colors: [Color] = [
        Theme.ColorToken.accentTerracotta,
        Theme.ColorToken.accentSage,
        Theme.ColorToken.accentSand,
        Theme.ColorToken.warmWhite.opacity(0.9),
    ]

    var body: some View {
        Group {
            if !reduceMotion {
                ZStack {
                    ForEach(0..<22, id: \.self) { i in
                        let base = Double(i) / 22 * Double.pi * 2 + 0.2
                        let radius: CGFloat = 52 + CGFloat(i % 7) * 9
                        Circle()
                            .fill(colors[i % colors.count])
                            .frame(width: CGFloat(4 + i % 4), height: CGFloat(4 + i % 4))
                            .offset(
                                x: burst ? CGFloat(cos(base)) * radius : 0,
                                y: burst ? CGFloat(sin(base)) * radius * 0.88 : 0
                            )
                            .opacity(burst ? 0 : 1)
                    }
                }
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.58)) {
                        burst = true
                    }
                }
            }
        }
    }
}
