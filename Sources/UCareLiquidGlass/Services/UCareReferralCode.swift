import Foundation

/// Deterministic promo-style code from the member’s username (on-device MVP; no server).
enum UCareReferralCode {
    private static let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")

    static func promoCode(username: String, email: String = "") -> String {
        let seed = normalizedSeed(from: username, email: email)
        var hash: UInt64 = 14_695_981_039_346_656_037
        for b in seed.utf8 {
            hash ^= UInt64(b)
            hash &*= 1099511628211
        }
        if hash == 0 { hash = 1 }
        var h = hash
        var out = ""
        out.reserveCapacity(6)
        for _ in 0..<6 {
            let idx = Int(h % UInt64(alphabet.count))
            out.append(alphabet[idx])
            h /= UInt64(alphabet.count)
            if h == 0 { h = hash &+ 7919 }
        }
        return out
    }

    private static func normalizedSeed(from username: String, email: String) -> String {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !u.isEmpty { return u }
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !e.isEmpty { return e }
        return "ucare"
    }
}
