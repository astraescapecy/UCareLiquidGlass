import Foundation

enum PaywallPlan: String, CaseIterable, Identifiable {
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: return "UCare Plus — Monthly"
        case .yearly: return "UCare Plus — Yearly"
        case .lifetime: return "UCare Lifetime"
        }
    }

    var priceLine: String {
        switch self {
        case .monthly: return "$14.99 / month"
        case .yearly: return "$79.99 / year"
        case .lifetime: return "$249 one-time"
        }
    }

    var subtitle: String {
        switch self {
        case .monthly: return "Flexible. Cancel anytime."
        case .yearly: return "Best value — about 55% off vs monthly."
        case .lifetime: return "For power users who want UCare forever."
        }
    }

    /// App Store Connect product identifiers (add matching IAPs in ASC; use StoreKit config in Xcode for local runs).
    var storeProductID: String {
        switch self {
        case .monthly: return "com.ucare.liquidglass.plus.monthly"
        case .yearly: return "com.ucare.liquidglass.plus.yearly"
        case .lifetime: return "com.ucare.liquidglass.lifetime"
        }
    }
}
