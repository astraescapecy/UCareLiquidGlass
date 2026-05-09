import Combine
import CoreMotion
import SwiftUI

final class ParallaxMotion: ObservableObject {
    @Published var pitch: CGFloat = 0
    @Published var roll: CGFloat = 0

    private let manager = CMMotionManager()
    private var isRunning = false

    init() {
        start()
    }

    deinit {
        // NSObject cleanup; stop on main synchronously if needed
        manager.stopDeviceMotionUpdates()
    }

    func start() {
        guard !isRunning, manager.isDeviceMotionAvailable else { return }
        isRunning = true
        manager.deviceMotionUpdateInterval = 1 / 40
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let motion = data else { return }
            // Small clamped values feel better on phone in hand.
            let p = CGFloat(motion.attitude.pitch)
            let r = CGFloat(motion.attitude.roll)
            self.pitch = max(-1, min(1, p))
            self.roll = max(-1, min(1, r))
        }
    }
}
