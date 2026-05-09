import Foundation
import UIKit

/// On-device weekly Progress selfies (Phase 3). Stored under Application Support — not synced.
enum WeeklyProgressPhotoStore {
    private static var directoryURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("UCare/WeeklyPhotos", isDirectory: true)
    }

    private static func fileURL(forMonday monday: Date) -> URL {
        let id = WeeklyCheckInEntry.weekId(for: WeeklyCheckInEntry.mondayWeekStart(containing: monday))
        return directoryURL.appendingPathComponent("\(id).jpg", isDirectory: false)
    }

    static func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    /// Saves JPEG for the Monday-start week containing `date` (replaces existing).
    static func saveJPEG(_ data: Data, weekContaining date: Date) throws {
        try ensureDirectory()
        let monday = WeeklyCheckInEntry.mondayWeekStart(containing: date)
        try data.write(to: fileURL(forMonday: monday), options: .atomic)
    }

    static func loadJPEGData(weekMonday monday: Date) -> Data? {
        let url = fileURL(forMonday: monday)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    static func delete(weekMonday monday: Date) {
        try? FileManager.default.removeItem(at: fileURL(forMonday: monday))
    }

    /// Newest-first Monday dates that have a saved photo.
    static func weekMondaysWithPhotos(limit: Int = 52) -> [Date] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }
        let cal = Calendar.current
        var mondays: [Date] = []
        for url in urls where url.pathExtension.lowercased() == "jpg" {
            let name = url.deletingPathExtension().lastPathComponent
            guard name.hasPrefix("w_"),
                  let monday = parseWeekId(name) else { continue }
            mondays.append(cal.startOfDay(for: monday))
        }
        return Array(mondays.sorted { $0 > $1 }.prefix(limit))
    }

    private static func parseWeekId(_ name: String) -> Date? {
        // w_YYYY-MM-DD
        let parts = name.dropFirst(2).split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2])
        else { return nil }
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal.date(from: DateComponents(year: y, month: m, day: d))
    }

    static func clearAll() {
        try? FileManager.default.removeItem(at: directoryURL)
    }
}
