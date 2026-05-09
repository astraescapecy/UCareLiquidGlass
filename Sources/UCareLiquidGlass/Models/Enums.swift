import Foundation

enum MainGoal: String, CaseIterable, Codable, Identifiable {
    case loseWeight
    case maintainWeight
    case buildMuscle
    case eatHealthier
    case improveEnergy
    case betterHabits

    var id: String { rawValue }
    var title: String {
        switch self {
        case .loseWeight: return "Lose weight"
        case .maintainWeight: return "Maintain weight"
        case .buildMuscle: return "Build muscle"
        case .eatHealthier: return "Eat healthier"
        case .improveEnergy: return "Improve energy"
        case .betterHabits: return "Build better habits"
        }
    }
    var icon: String {
        switch self {
        case .loseWeight: return "target"
        case .maintainWeight: return "scalemass"
        case .buildMuscle: return "figure.strengthtraining.traditional"
        case .eatHealthier: return "leaf"
        case .improveEnergy: return "bolt.heart"
        case .betterHabits: return "sparkles"
        }
    }
}

enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case nonBinary
    case other

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .nonBinary: return "Non-binary"
        case .other: return "Prefer not to say"
        }
    }
}

enum DietStyle: String, Codable, CaseIterable, Identifiable {
    case omnivore
    case vegetarian
    case vegan

    var id: String { rawValue }

    var title: String {
        switch self {
        case .omnivore: return "Omnivore"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        }
    }
}

enum TimelinePace: String, Codable, CaseIterable, Identifiable {
    case slow
    case moderate
    case fast
    var id: String { rawValue }
    var title: String {
        switch self {
        case .slow: return "Slow & steady (-0.25kg/week)"
        case .moderate: return "Moderate (-0.5kg/week)"
        case .fast: return "Fast (-1kg/week)"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary
    case light
    case moderate
    case very

    var id: String { rawValue }
    var title: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Lightly active"
        case .moderate: return "Moderately active"
        case .very: return "Very active"
        }
    }
    var subtitle: String {
        switch self {
        case .sedentary: return "Mostly sitting, desk job"
        case .light: return "Light exercise 1–3x/week"
        case .moderate: return "Moderate exercise 3–5x/week"
        case .very: return "Hard training 6–7x/week"
        }
    }
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .very: return 1.725
        }
    }
}

enum HeightUnit: String, Codable, CaseIterable {
    case cm
    case ft
}

enum WeightUnit: String, Codable, CaseIterable {
    case kg
    case lbs
}

enum DietPreference: String, Codable, CaseIterable, Identifiable, Hashable {
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case keto
    case halal
    case noRestriction
    var id: String { rawValue }

    var title: String {
        switch self {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-free"
        case .dairyFree: return "Dairy-free"
        case .keto: return "Keto"
        case .halal: return "Halal"
        case .noRestriction: return "No restriction"
        }
    }
}
