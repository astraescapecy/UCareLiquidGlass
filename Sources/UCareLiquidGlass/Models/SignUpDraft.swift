import Foundation

struct SignUpDraft: Codable, Equatable {
    var fullName: String = ""
    var email: String = ""
    var password: String = ""
}
