import Foundation

/// High-level routing for full-screen phases.
enum AppPhase: Equatable {
    case splash
    case getStarted
    case auth
    case questionnaire
    case paywall
    case analysis
    case reveal
    case main
}
