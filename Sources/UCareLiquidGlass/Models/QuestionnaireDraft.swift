import Foundation

/// In-progress onboarding answers (UCare spec §3–6).
struct QuestionnaireDraft: Codable, Equatable {
    var step: Int = 0

    // Step 0 — Why are you here? (multi-select)
    var careGoals: Set<UCareFocus> = []

    // Step 1 — Body & lifestyle baseline
    var sex: BiologicalSex = .female
    var age: Int = 24
    var dietStyle: DietStyle = .omnivore
    var allergiesText: String = ""
    var routineNotes: String = ""
    var problemAreasText: String = ""

    // Step 2 — Glow-up target date (optional)
    var wantsGlowUpTarget: Bool = false
    var glowUpTargetDate: Date = .now

    // Step 3 — Optional starting photos (intent only in MVP; no image storage yet)
    var optedInFacePhoto: Bool = false
    var optedInHairPhoto: Bool = false
    var optedInSkinPhoto: Bool = false
    var skippedPhotoStep: Bool = false

    // Step 4 — Notification preferences (local toggles; system permission wired later)
    var wantsWaterReminders: Bool = true
    var wantsMorningRoutineNudge: Bool = true
    var wantsEveningSkincareNudge: Bool = true
    var wantsBedtimeWindDown: Bool = true

    // Legacy fields (kept for Codable migration from older builds)
    var goal: MainGoal?
    var heightUnit: HeightUnit = .cm
    var heightValue: Double = 165
    var weightUnit: WeightUnit = .kg
    var weightValue: Double = 65
    var targetWeight: Double = 60
    var timeline: TimelinePace = .moderate
    var activity: ActivityLevel?
    var diet: Set<DietPreference> = []

    func heightCm() -> Double {
        switch heightUnit {
        case .cm: return heightValue
        case .ft: return heightValue * 30.48
        }
    }

    func weightKg() -> Double {
        switch weightUnit {
        case .kg: return weightValue
        case .lbs: return weightValue * 0.453592
        }
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        step = try c.decodeIfPresent(Int.self, forKey: .step) ?? 0
        careGoals = try c.decodeIfPresent(Set<UCareFocus>.self, forKey: .careGoals) ?? []
        sex = try c.decodeIfPresent(BiologicalSex.self, forKey: .sex) ?? .female
        age = try c.decodeIfPresent(Int.self, forKey: .age) ?? 24
        dietStyle = try c.decodeIfPresent(DietStyle.self, forKey: .dietStyle) ?? .omnivore
        allergiesText = try c.decodeIfPresent(String.self, forKey: .allergiesText) ?? ""
        routineNotes = try c.decodeIfPresent(String.self, forKey: .routineNotes) ?? ""
        problemAreasText = try c.decodeIfPresent(String.self, forKey: .problemAreasText) ?? ""
        wantsGlowUpTarget = try c.decodeIfPresent(Bool.self, forKey: .wantsGlowUpTarget) ?? false
        glowUpTargetDate = try c.decodeIfPresent(Date.self, forKey: .glowUpTargetDate) ?? .now
        optedInFacePhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInFacePhoto) ?? false
        optedInHairPhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInHairPhoto) ?? false
        optedInSkinPhoto = try c.decodeIfPresent(Bool.self, forKey: .optedInSkinPhoto) ?? false
        skippedPhotoStep = try c.decodeIfPresent(Bool.self, forKey: .skippedPhotoStep) ?? false
        wantsWaterReminders = try c.decodeIfPresent(Bool.self, forKey: .wantsWaterReminders) ?? true
        wantsMorningRoutineNudge = try c.decodeIfPresent(Bool.self, forKey: .wantsMorningRoutineNudge) ?? true
        wantsEveningSkincareNudge = try c.decodeIfPresent(Bool.self, forKey: .wantsEveningSkincareNudge) ?? true
        wantsBedtimeWindDown = try c.decodeIfPresent(Bool.self, forKey: .wantsBedtimeWindDown) ?? true

        goal = try c.decodeIfPresent(MainGoal.self, forKey: .goal)
        heightUnit = try c.decodeIfPresent(HeightUnit.self, forKey: .heightUnit) ?? .cm
        heightValue = try c.decodeIfPresent(Double.self, forKey: .heightValue) ?? 165
        weightUnit = try c.decodeIfPresent(WeightUnit.self, forKey: .weightUnit) ?? .kg
        weightValue = try c.decodeIfPresent(Double.self, forKey: .weightValue) ?? 65
        targetWeight = try c.decodeIfPresent(Double.self, forKey: .targetWeight) ?? 60
        timeline = try c.decodeIfPresent(TimelinePace.self, forKey: .timeline) ?? .moderate
        activity = try c.decodeIfPresent(ActivityLevel.self, forKey: .activity)
        diet = try c.decodeIfPresent(Set<DietPreference>.self, forKey: .diet) ?? []

        if careGoals.isEmpty, let g = goal {
            careGoals = Set(UserProfile.migratedCareGoals(from: g))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(step, forKey: .step)
        try c.encode(careGoals, forKey: .careGoals)
        try c.encode(sex, forKey: .sex)
        try c.encode(age, forKey: .age)
        try c.encode(dietStyle, forKey: .dietStyle)
        try c.encode(allergiesText, forKey: .allergiesText)
        try c.encode(routineNotes, forKey: .routineNotes)
        try c.encode(problemAreasText, forKey: .problemAreasText)
        try c.encode(wantsGlowUpTarget, forKey: .wantsGlowUpTarget)
        try c.encode(glowUpTargetDate, forKey: .glowUpTargetDate)
        try c.encode(optedInFacePhoto, forKey: .optedInFacePhoto)
        try c.encode(optedInHairPhoto, forKey: .optedInHairPhoto)
        try c.encode(optedInSkinPhoto, forKey: .optedInSkinPhoto)
        try c.encode(skippedPhotoStep, forKey: .skippedPhotoStep)
        try c.encode(wantsWaterReminders, forKey: .wantsWaterReminders)
        try c.encode(wantsMorningRoutineNudge, forKey: .wantsMorningRoutineNudge)
        try c.encode(wantsEveningSkincareNudge, forKey: .wantsEveningSkincareNudge)
        try c.encode(wantsBedtimeWindDown, forKey: .wantsBedtimeWindDown)
        try c.encodeIfPresent(goal, forKey: .goal)
        try c.encode(heightUnit, forKey: .heightUnit)
        try c.encode(heightValue, forKey: .heightValue)
        try c.encode(weightUnit, forKey: .weightUnit)
        try c.encode(weightValue, forKey: .weightValue)
        try c.encode(targetWeight, forKey: .targetWeight)
        try c.encode(timeline, forKey: .timeline)
        try c.encodeIfPresent(activity, forKey: .activity)
        try c.encode(diet, forKey: .diet)
    }

    private enum CodingKeys: String, CodingKey {
        case step, careGoals, sex, age, dietStyle, allergiesText, routineNotes, problemAreasText
        case wantsGlowUpTarget, glowUpTargetDate
        case optedInFacePhoto, optedInHairPhoto, optedInSkinPhoto, skippedPhotoStep
        case wantsWaterReminders, wantsMorningRoutineNudge, wantsEveningSkincareNudge, wantsBedtimeWindDown
        case goal, heightUnit, heightValue, weightUnit, weightValue, targetWeight, timeline, activity, diet
    }
}
