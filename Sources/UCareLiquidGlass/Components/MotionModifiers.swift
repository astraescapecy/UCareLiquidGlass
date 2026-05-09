import SwiftUI

struct ScrollAwareScale<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let midY = proxy.frame(in: .global).midY
            let screenMid = UIScreen.main.bounds.midY
            let distance = abs(midY - screenMid)
            let normalized = max(0, min(1, distance / screenMid))
            let scale = reduceMotion ? 1.0 : (1.0 - normalized * 0.03)
            content()
                .scaleEffect(scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 1)
    }
}

extension View {
    func subtleScrollScale() -> some View {
        ScrollAwareScale {
            self
        }
    }
}
