import Foundation

enum TDEECalculator {
    static func calculate(
        sex: BiologicalSex,
        age: Int,
        heightCm: Double,
        weightKg: Double,
        activity: ActivityLevel,
        goal: MainGoal
    ) -> (calories: Int, protein: Int, carbs: Int, fat: Int) {
        let bmr: Double = {
            switch sex {
            case .male: return (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
            case .female: return (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
            case .nonBinary, .other: return (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 78
            }
        }()

        let tdee = bmr * activity.multiplier
        let adjusted: Double = {
            switch goal {
            case .loseWeight: return tdee - 500
            case .buildMuscle: return tdee + 300
            default: return tdee
            }
        }()

        let calories = max(1200, Int(adjusted.rounded()))
        let protein = Int((weightKg * 2).rounded())
        let fat = Int(((Double(calories) * 0.25) / 9).rounded())
        let carbs = Int(((Double(calories) - (Double(protein) * 4) - (Double(fat) * 9)) / 4).rounded())
        return (calories, max(50, protein), max(50, carbs), max(20, fat))
    }
}
