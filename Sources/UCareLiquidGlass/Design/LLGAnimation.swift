import SwiftUI

enum LLGAnimation {
    static func screenSpring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.72)
    }

    static func entrance(delay: Double = 0, reduceMotion: Bool) -> Animation {
        let base = reduceMotion ? Animation.easeInOut(duration: 0.2) : Animation.spring(response: 0.45, dampingFraction: 0.74)
        return base.delay(delay)
    }

    static func buttonPress(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.3, dampingFraction: 0.76)
    }

    static func softFade(reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.18) : .easeInOut(duration: 0.28)
    }

    // Backward-compatible aliases for existing views.
    static func primarySpring(reduceMotion: Bool) -> Animation { screenSpring(reduceMotion: reduceMotion) }
    static func gentleSpring(reduceMotion: Bool) -> Animation { screenSpring(reduceMotion: reduceMotion) }
}

extension View {
    func animatedIfNeeded(_ enabled: Bool, _ animation: Animation, value: some Equatable) -> some View {
        if enabled {
            return AnyView(self.animation(animation, value: value))
        }
        return AnyView(self)
    }
}
