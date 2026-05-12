import Foundation

/// On-device username rules + demo “taken” set (no server in MVP).
enum UCareUsernameAvailability {
    private static let reserved: Set<String> = [
        "ucare", "admin", "support", "help", "system", "root", "null", "api", "staff", "moderator",
        "official", "team", "about", "legal", "privacy", "terms", "billing", "noreply",
    ]

    /// Obvious picks that read as “taken” in the UI demo.
    private static let demoTaken: Set<String> = [
        "test", "user", "member", "apple", "google", "iphone", "android", "guest", "demo",
        "name", "username", "here", "taken", "nobody", "someone",
    ]

    static func normalized(_ raw: String) -> String {
        raw.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" }
    }

    /// `nil` means OK; otherwise a short reason for the UI.
    static func validationReason(for raw: String) -> String? {
        let n = normalized(raw)
        if n.count < 3 { return "Use at least 3 characters" }
        if n.count > 14 { return "Max 14 characters" }
        if !n.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) { return "Letters, numbers, underscore only" }
        if reserved.contains(n) { return "Reserved" }
        if demoTaken.contains(n) { return "Taken" }
        return nil
    }

    static func isAvailable(_ raw: String) -> Bool {
        validationReason(for: raw) == nil
    }
}
