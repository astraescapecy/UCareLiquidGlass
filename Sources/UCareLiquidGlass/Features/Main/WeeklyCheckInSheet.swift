import SwiftUI

struct WeeklyCheckInSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var skinClarity = 3.0
    @State private var breathFreshness = 3.0
    @State private var bodyOdorConfidence = 3.0
    @State private var hairScalp = 3.0
    @State private var energy = 3.0
    @State private var mood = 3.0
    @State private var sexDrive = 3.0
    @State private var sleepQuality = 3.0
    @State private var gutComfort = 3.0
    @State private var intimateConfidence = 3.0

    private var weekStart: Date { WeeklyCheckInEntry.mondayWeekStart(containing: .now) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly check-in")
                        .font(Theme.Typography.title2())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                    Text("About 60 seconds. 1 = rough week, 5 = noticeably better. Not medical advice — it’s your honest mirror.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            sliderRow("Skin clarity", value: $skinClarity)
                            sliderRow("Breath freshness", value: $breathFreshness)
                            sliderRow("Body odor confidence", value: $bodyOdorConfidence)
                            sliderRow("Hair / scalp", value: $hairScalp)
                            sliderRow("Energy", value: $energy)
                            sliderRow("Mood", value: $mood)
                            sliderRow("Sex drive", value: $sexDrive)
                            sliderRow("Sleep quality", value: $sleepQuality)
                            sliderRow("Gut comfort", value: $gutComfort)
                            sliderRow("Intimate confidence", value: $intimateConfidence)
                        }
                    }
                }
                .padding(Theme.Layout.contentHorizontalPadding)
                .padding(.bottom, 28)
            }
            .background(Theme.paperGradient.opacity(0.001))
            .navigationTitle("This week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let existing = appState.weeklyCheckIns.first(where: {
                Calendar.current.isDate($0.weekStart, inSameDayAs: weekStart)
            }) {
                skinClarity = Double(existing.skinClarity)
                breathFreshness = Double(existing.breathFreshness)
                bodyOdorConfidence = Double(existing.bodyOdorConfidence)
                hairScalp = Double(existing.hairScalp)
                energy = Double(existing.energy)
                mood = Double(existing.mood)
                sexDrive = Double(existing.sexDrive)
                sleepQuality = Double(existing.sleepQuality)
                gutComfort = Double(existing.gutComfort)
                intimateConfidence = Double(existing.intimateConfidence)
            }
        }
    }

    private func sliderRow(_ title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue.rounded()))")
                    .font(Theme.Typography.headline())
                    .foregroundStyle(Theme.ColorToken.accentTerracotta)
                    .monospacedDigit()
            }
            Slider(value: value, in: 1 ... 5, step: 1)
                .tint(Theme.ColorToken.accentTerracotta)
        }
    }

    private func save() {
        let entry = WeeklyCheckInEntry(
            weekStart: weekStart,
            recordedAt: .now,
            skinClarity: WeeklyCheckInEntry.clampRating(Int(skinClarity.rounded())),
            breathFreshness: WeeklyCheckInEntry.clampRating(Int(breathFreshness.rounded())),
            bodyOdorConfidence: WeeklyCheckInEntry.clampRating(Int(bodyOdorConfidence.rounded())),
            hairScalp: WeeklyCheckInEntry.clampRating(Int(hairScalp.rounded())),
            energy: WeeklyCheckInEntry.clampRating(Int(energy.rounded())),
            mood: WeeklyCheckInEntry.clampRating(Int(mood.rounded())),
            sexDrive: WeeklyCheckInEntry.clampRating(Int(sexDrive.rounded())),
            sleepQuality: WeeklyCheckInEntry.clampRating(Int(sleepQuality.rounded())),
            gutComfort: WeeklyCheckInEntry.clampRating(Int(gutComfort.rounded())),
            intimateConfidence: WeeklyCheckInEntry.clampRating(Int(intimateConfidence.rounded()))
        )
        withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
            appState.submitWeeklyCheckIn(entry)
        }
    }
}
