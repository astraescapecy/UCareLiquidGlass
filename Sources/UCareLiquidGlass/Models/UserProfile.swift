import Foundation

struct UserProfile: Codable, Equatable {
    var fullName: String
    var email: String
    var username: String
    var memberSince: Date

    var careGoals: [UCareFocus]
    var sex: BiologicalSex
    var age: Int
    var dietStyle: DietStyle
    var allergiesNote: String
    var routineNote: String
    var problemAreasNote: String
    var glowUpTargetDate: Date?

    var wantsWaterReminders: Bool
    var wantsMorningNudge: Bool
    var wantsEveningNudge: Bool
    var wantsBedtimeNudge: Bool

    var optedInFacePhoto: Bool
    var optedInHairPhoto: Bool
    var optedInSkinPhoto: Bool

    var programSteps: [ProgramStep]

    enum CodingKeys: String, CodingKey {
        case fullName, email, username, memberSince, careGoals, sex, age, dietStyle
        case allergiesNote, routineNote, problemAreasNote, glowUpTargetDate
        case wantsWaterReminders, wantsMorningNudge, wantsEveningNudge, wantsBedtimeNudge
        case optedInFacePhoto, optedInHairPhoto, optedInSkinPhoto, programSteps
        // Legacy (pre–UCare spec)
        case goal, heightCm, weightKg, targetWeightKg, timeline, activityLevel, dietaryPreferences
        case dailyCalories, proteinGrams, carbsGrams, fatGrams
    }

    init(
        fullName: String,
        email: String,
        username: String,
        memberSince: Date = .now,
        careGoals: [UCareFocus],
        sex: BiologicalSex,
        age: Int,
        dietStyle: DietStyle,
        allergiesNote: String,
        routineNote: String,
        problemAreasNote: String,
        glowUpTargetDate: Date?,
        wantsWaterReminders: Bool,
        wantsMorningNudge: Bool,
        wantsEveningNudge: Bool,
        wantsBedtimeNudge: Bool,
        optedInFacePhoto: Bool,
        optedInHairPhoto: Bool,
        optedInSkinPhoto: Bool,
        programSteps: [ProgramStep]
    ) {
        self.fullName = fullName
        self.email = email
        self.username = username
        self.memberSince = memberSince
        self.careGoals = careGoals
        self.sex = sex
        self.age = age
        self.dietStyle = dietStyle
        self.allergiesNote = allergiesNote
        self.routineNote = routineNote
        self.problemAreasNote = problemAreasNote
        self.glowUpTargetDate = glowUpTargetDate
        self.wantsWaterReminders = wantsWaterReminders
        self.wantsMorningNudge = wantsMorningNudge
        self.wantsEveningNudge = wantsEveningNudge
        self.wantsBedtimeNudge = wantsBedtimeNudge
        self.optedInFacePhoto = optedInFacePhoto
        self.optedInHairPhoto = optedInHairPhoto
        self.optedInSkinPhoto = optedInSkinPhoto
        self.programSteps = programSteps
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try c.decode(String.self, forKey: .fullName)
        email = try c.decode(String.self, forKey: .email)
        username = try c.decode(String.self, forKey: .username)
        memberSince = try c.decodeIfPresent(Date.self, forKey: .memberSince) ?? .now

        if let goals = try c.decodeIfPresent([UCareFocus].self, forKey: .careGoals), !goals.isEmpty {
            careGoals = goals
        } else if let legacyGoal = try c.decodeIfPresent(MainGoal.self, forKey: .goal) {
            careGoals = UserProfile.migratedCareGoals(from: legacyGoal)
        } else {
            careGoals = [.moreConfidenceBody]
        }

        sex = try c.decode(BiologicalSex.self, forKey: .sex)
        age = try c.decodeIfPresent(Int.self, forKey: .age) ?? 22
        dietStyle = try c.decodeIfPresent(DietStyle.self, forKey: .dietStyle) ?? .omnivore
        allergiesNote = try c.decodeIfPresent(String.self, forKey: .allergiesNote) ?? ""
        routineNote = try c.decodeIfPresent(String.self, forKey: .routineNote) ?? ""
        problemAreasNote = try c.decodeIfPresent(String.self, forKey: .problemAreasNote) ?? ""
        glowUpTargetDate = try c.decodeIfPresent(Date.self, forKey: .glowUpTargetDate)

        wantsWaterReminders = try c.decodeIfPresent(Bool.self, forKey: .wantsWaterReminders) ?? true
        wantsMorningNudge = try c.decodeIfPresent(Bool.self, forKey: .wantsMorningNudge) ?? true
        wantsEveningNudge = try c.decodeIfPresent(Bool.self, forKey: .wantsEveningNudge) ?? true
        wantsBedtimeNudge = try c.decodeIfPresent(Bool.self, forKey: .wantsBedtimeNudge) ?? true

        optedInFacePhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInFacePhoto) ?? false
        optedInHairPhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInHairPhoto) ?? false
        optedInSkinPhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInSkinPhoto) ?? false

        programSteps = try c.decodeIfPresent([ProgramStep].self, forKey: .programSteps) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(fullName, forKey: .fullName)
        try c.encode(email, forKey: .email)
        try c.encode(username, forKey: .username)
        try c.encode(memberSince, forKey: .memberSince)
        try c.encode(careGoals, forKey: .careGoals)
        try c.encode(sex, forKey: .sex)
        try c.encode(age, forKey: .age)
        try c.encode(dietStyle, forKey: .dietStyle)
        try c.encode(allergiesNote, forKey: .allergiesNote)
        try c.encode(routineNote, forKey: .routineNote)
        try c.encode(problemAreasNote, forKey: .problemAreasNote)
        try c.encodeIfPresent(glowUpTargetDate, forKey: .glowUpTargetDate)
        try c.encode(wantsWaterReminders, forKey: .wantsWaterReminders)
        try c.encode(wantsMorningNudge, forKey: .wantsMorningNudge)
        try c.encode(wantsEveningNudge, forKey: .wantsEveningNudge)
        try c.encode(wantsBedtimeNudge, forKey: .wantsBedtimeNudge)
        try c.encode(optedInFacePhoto, forKey: .optedInFacePhoto)
        try c.encode(optedInHairPhoto, forKey: .optedInHairPhoto)
        try c.encode(optedInSkinPhoto, forKey: .optedInSkinPhoto)
        try c.encode(programSteps, forKey: .programSteps)
    }

    static func migratedCareGoals(from legacy: MainGoal) -> [UCareFocus] {
        switch legacy {
        case .loseWeight, .maintainWeight: return [.betterGutLessBloat, .drinkMoreWaterHydration, .moreConfidenceBody]
        case .buildMuscle: return [.moreConfidenceBody, .drinkMoreWaterHydration]
        case .eatHealthier: return [.betterGutLessBloat, .betterSkinClearAcne]
        case .improveEnergy: return [.sleepBetter, .drinkMoreWaterHydration]
        case .betterHabits: return [.moreConfidenceBody, .sleepBetter]
        }
    }
}

struct ProgramStep: Codable, Equatable, Identifiable, Hashable {
    var id: String
    var title: String
    var details: String
    var segment: DaySegment
    var iconSystemName: String
    var estimatedSeconds: Int?
    var scienceBlurb: String

    enum CodingKeys: String, CodingKey {
        case id, title, details, segment
        case iconSystemName, estimatedSeconds, scienceBlurb
    }

    init(
        id: String,
        title: String,
        details: String,
        segment: DaySegment,
        iconSystemName: String = "sparkles",
        estimatedSeconds: Int? = nil,
        scienceBlurb: String = ""
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.segment = segment
        self.iconSystemName = iconSystemName
        self.estimatedSeconds = estimatedSeconds
        self.scienceBlurb = scienceBlurb
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        details = try c.decode(String.self, forKey: .details)
        segment = try c.decode(DaySegment.self, forKey: .segment)
        iconSystemName = try c.decodeIfPresent(String.self, forKey: .iconSystemName) ?? "sparkles"
        estimatedSeconds = try c.decodeIfPresent(Int.self, forKey: .estimatedSeconds)
        scienceBlurb = try c.decodeIfPresent(String.self, forKey: .scienceBlurb) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(details, forKey: .details)
        try c.encode(segment, forKey: .segment)
        try c.encode(iconSystemName, forKey: .iconSystemName)
        try c.encodeIfPresent(estimatedSeconds, forKey: .estimatedSeconds)
        try c.encode(scienceBlurb, forKey: .scienceBlurb)
    }
}

enum DaySegment: String, Codable, CaseIterable, Identifiable {
    case morning
    case midday
    case evening
    case beforeBed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .evening: return "Evening"
        case .beforeBed: return "Before bed"
        }
    }

    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .midday: return "☀️"
        case .evening: return "🌙"
        case .beforeBed: return "😴"
        }
    }

    static var orderedForToday: [DaySegment] { [.morning, .midday, .evening, .beforeBed] }
}
