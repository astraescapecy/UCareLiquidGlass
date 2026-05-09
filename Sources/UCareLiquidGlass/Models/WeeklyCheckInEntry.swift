import Foundation

/// One weekly self-rating snapshot (Phase 3 — 1…5 sliders).
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
    /// Desire / sex drive this week (older saves default to 3).
    var sexDrive: Int
    var sleepQuality: Int
    var gutComfort: Int
    var intimateConfidence: Int

    var id: String {
        Self.weekId(for: weekStart)
    }

    enum CodingKeys: String, CodingKey {
        case weekStart, recordedAt
        case skinClarity, breathFreshness, bodyOdorConfidence, hairScalp, energy, mood
        case sexDrive, sleepQuality, gutComfort, intimateConfidence
    }

    init(
        weekStart: Date,
        recordedAt: Date,
        skinClarity: Int,
        breathFreshness: Int,
        bodyOdorConfidence: Int,
        hairScalp: Int,
        energy: Int,
        mood: Int,
        sexDrive: Int,
        sleepQuality: Int,
        gutComfort: Int,
        intimateConfidence: Int
    ) {
        self.weekStart = weekStart
        self.recordedAt = recordedAt
        self.skinClarity = Self.clampRating(skinClarity)
        self.breathFreshness = Self.clampRating(breathFreshness)
        self.bodyOdorConfidence = Self.clampRating(bodyOdorConfidence)
        self.hairScalp = Self.clampRating(hairScalp)
        self.energy = Self.clampRating(energy)
        self.mood = Self.clampRating(mood)
        self.sexDrive = Self.clampRating(sexDrive)
        self.sleepQuality = Self.clampRating(sleepQuality)
        self.gutComfort = Self.clampRating(gutComfort)
        self.intimateConfidence = Self.clampRating(intimateConfidence)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weekStart = try c.decode(Date.self, forKey: .weekStart)
        recordedAt = try c.decode(Date.self, forKey: .recordedAt)
        skinClarity = try c.decode(Int.self, forKey: .skinClarity)
        breathFreshness = try c.decode(Int.self, forKey: .breathFreshness)
        bodyOdorConfidence = try c.decode(Int.self, forKey: .bodyOdorConfidence)
        hairScalp = try c.decode(Int.self, forKey: .hairScalp)
        energy = try c.decode(Int.self, forKey: .energy)
        mood = try c.decode(Int.self, forKey: .mood)
        sexDrive = Self.clampRating(try c.decodeIfPresent(Int.self, forKey: .sexDrive) ?? 3)
        sleepQuality = try c.decode(Int.self, forKey: .sleepQuality)
        gutComfort = try c.decode(Int.self, forKey: .gutComfort)
        intimateConfidence = try c.decode(Int.self, forKey: .intimateConfidence)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(weekStart, forKey: .weekStart)
        try c.encode(recordedAt, forKey: .recordedAt)
        try c.encode(skinClarity, forKey: .skinClarity)
        try c.encode(breathFreshness, forKey: .breathFreshness)
        try c.encode(bodyOdorConfidence, forKey: .bodyOdorConfidence)
        try c.encode(hairScalp, forKey: .hairScalp)
        try c.encode(energy, forKey: .energy)
        try c.encode(mood, forKey: .mood)
        try c.encode(sexDrive, forKey: .sexDrive)
        try c.encode(sleepQuality, forKey: .sleepQuality)
        try c.encode(gutComfort, forKey: .gutComfort)
        try c.encode(intimateConfidence, forKey: .intimateConfidence)
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
            energy, mood, sexDrive, sleepQuality, gutComfort, intimateConfidence,
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
