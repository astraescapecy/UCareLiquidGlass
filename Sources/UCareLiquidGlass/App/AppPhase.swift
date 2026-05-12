import Foundation

/// High-level routing for full-screen phases.
enum AppPhase: Equatable {
    case splash
    case getStarted
    case auth
    case usernameSetup
    case questionnaire
    case paywall
    case subscriptionCongrats
    case analysis
    case reveal
    case main
}
