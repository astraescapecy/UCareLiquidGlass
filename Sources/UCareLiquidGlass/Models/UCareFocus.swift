import Foundation

/// Multi-select onboarding intents from the UCare product spec (Section 3).
enum UCareFocus: String, Codable, CaseIterable, Identifiable, Hashable {
    case smellBetterNaturally
    case tasteBetterIntimateOral
    case betterSkinClearAcne
    case healthierHair
    case fresherBreathOralHealth
    case drinkMoreWaterHydration
    case sexualWellnessBed
    case moreConfidenceBody
    case sleepBetter
    case betterGutLessBloat
    case glowUpBeforeDate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smellBetterNaturally: return "Smell better naturally"
        case .tasteBetterIntimateOral: return "Taste better (intimate / oral)"
        case .betterSkinClearAcne: return "Better skin / clear acne"
        case .healthierHair: return "Healthier, fuller hair"
        case .fresherBreathOralHealth: return "Fresher breath / oral health"
        case .drinkMoreWaterHydration: return "Drink more water / hydration"
        case .sexualWellnessBed: return "Be better in bed / sexual wellness"
        case .moreConfidenceBody: return "More confidence in my body"
        case .sleepBetter: return "Sleep better"
        case .betterGutLessBloat: return "Better gut / less bloating"
        case .glowUpBeforeDate: return "Glow-up before a specific date"
        }
    }

    var subtitle: String {
        switch self {
        case .smellBetterNaturally: return "Dial down everyday odor with habits, not harsh cover-ups."
        case .tasteBetterIntimateOral: return "Oral + whole-body habits partners notice."
        case .betterSkinClearAcne: return "Barrier-friendly routines that respect your skin."
        case .healthierHair: return "Scalp-first care for shine and density over time."
        case .fresherBreathOralHealth: return "Tongue, teeth, gums — the full stack."
        case .drinkMoreWaterHydration: return "Steady hydration changes breath, skin, and energy."
        case .sexualWellnessBed: return "Tasteful protocols for confidence and connection."
        case .moreConfidenceBody: return "Small wins that stack into how you carry yourself."
        case .sleepBetter: return "Wind-down rituals that make mornings easier."
        case .betterGutLessBloat: return "Fiber, rhythm, and gentle digestion habits."
        case .glowUpBeforeDate: return "We’ll bias the plan toward visible wins by your date."
        }
    }

    var icon: String {
        switch self {
        case .smellBetterNaturally: return "wind"
        case .tasteBetterIntimateOral: return "heart.text.square"
        case .betterSkinClearAcne: return "sparkles"
        case .healthierHair: return "scissors"
        case .fresherBreathOralHealth: return "mouth"
        case .drinkMoreWaterHydration: return "drop.fill"
        case .sexualWellnessBed: return "flame"
        case .moreConfidenceBody: return "figure.stand"
        case .sleepBetter: return "moon.zzz.fill"
        case .betterGutLessBloat: return "leaf.fill"
        case .glowUpBeforeDate: return "calendar"
        }
    }
}
