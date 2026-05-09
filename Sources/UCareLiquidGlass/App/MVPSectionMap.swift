import Foundation

/// Audit aid: spec §8-style MVP checklist → primary surface + persistence hook.
enum MVPSectionMap {
    static let rows: [(id: String, requirement: String, surface: String)] = [
        ("1", "Welcome / first-run", "GetStartedView · `sawWelcome`"),
        ("2", "Account hand-off", "Auth · `username`, `SignUpDraft`"),
        ("3", "Goals + baseline questionnaire", "QuestionnaireFlowView · `QuestionnaireDraft`"),
        ("4", "Optional photos (intent)", "Questionnaire step 3 · profile opt-in flags"),
        ("5", "Notifications + reminders", "Questionnaire reminders · `UserProfile`"),
        ("6", "AI load + program preview", "Analysis + PlanRevealView · `AppProgramServices`"),
        ("7", "Paywall + StoreKit", "PaywallView · `Product`, entitlements, Day‑1 gate in Today"),
        ("8", "Today stack + completion", "TodayView · per-day `completion` keys"),
        ("9", "Progress score + check-ins", "ProgressOverviewView · `weeklyCheckIns`"),
        ("10", "Profile lifecycle", "ProfileOverviewView · export JSON, history, retake, delete"),
    ]
}
