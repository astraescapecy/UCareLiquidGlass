import Foundation
import UIKit

/// On-device profile photo (Phase 4). JPEG in Application Support — not synced.
enum ProfileAvatarStore {
    private static var fileURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("UCare/profile_avatar.jpg", isDirectory: false)
    }

    static func ensureParent() throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    static func saveJPEG(_ data: Data) throws {
        try ensureParent()
        try data.write(to: fileURL, options: .atomic)
    }

    static func loadJPEGData() -> Data? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try? Data(contentsOf: fileURL)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
