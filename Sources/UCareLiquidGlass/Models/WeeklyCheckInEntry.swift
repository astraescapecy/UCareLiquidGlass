import Foundation

/// One weekly self-rating snapshot (spec §6.3 — condensed for a fast check-in).
struct WeeklyCheckInEntry: Codable, Equatable, Identifiable {
    /// Monday-start week (local calendar), normalized to start-of-day.
    var weekStart: Date
    var recordedAt: Date

    /// All scales are 1 (rough) … 5 (great).
    var skinClarity: Int
    var breathFreshness: Int
    var bodyOdorConfidence: Int
    var hairScalp: Int
    var energy: Int
    var mood: Int
    var sleepQuality: Int
    var gutComfort: Int
    var intimateConfidence: Int

    var id: String {
        Self.weekId(for: weekStart)
    }

    static func weekId(for weekStart: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: weekStart)
        return String(format: "w_%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func clampRating(_ v: Int) -> Int { min(5, max(1, v)) }

    /// Normalized average 0 … 1 across all fields.
    var normalizedAverage: Double {
        let fields = [
            skinClarity, breathFreshness, bodyOdorConfidence, hairScalp,
            energy, mood, sleepQuality, gutComfort, intimateConfidence,
        ]
        let sum = fields.reduce(0) { $0 + Self.clampRating($1) }
        return Double(sum) / Double(fields.count * 5)
    }

    /// Local Monday 00:00 for the week containing `date`.
    static func mondayWeekStart(containing date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let anchor = cal.date(from: comps) ?? date
        return cal.startOfDay(for: anchor)
    }
}
