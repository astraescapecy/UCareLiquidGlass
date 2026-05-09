import SwiftUI

struct ProgressOverviewView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showWeeklyCheckIn = false
    @State private var showDiscover = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("The “holy shit, I’m changing” tab — built from what you actually do.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textSecondary)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Glow-Up Score")
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Text("\(appState.glowUpScore())")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Blends your last 7 days of step adherence with this week’s self-ratings when you log a check-in. Missing a check-in doesn’t punish you — we lean on adherence.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(Array(last7Days.enumerated()), id: \.offset) { _, day in
                            let item = appState.completionFraction(on: day)
                            Capsule()
                                .fill(Theme.ctaGradient)
                                .frame(maxWidth: .infinity)
                                .frame(height: max(16, item * 170))
                        }
                    }
                    .frame(height: 190)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Weekly check-in")
                                .font(Theme.Typography.headline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Spacer()
                            Button("Log now") { showWeeklyCheckIn = true }
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        }
                        Text("Skin, breath, odor confidence, hair, energy, mood, sleep, gut, intimate confidence — quick sliders, honest trends.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }

                if !appState.recentWeeklyCheckIns(max: 8).isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trends (recent weeks)")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            let chronological = Array(appState.recentWeeklyCheckIns(max: 8)).reversed()
                            sparkRow("Skin", values: chronological.map(\.skinClarity))
                            sparkRow("Breath", values: chronological.map(\.breathFreshness))
                            sparkRow("Odor", values: chronological.map(\.bodyOdorConfidence))
                            sparkRow("Energy", values: chronological.map(\.energy))
                            sparkRow("Sleep", values: chronological.map(\.sleepQuality))
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Routine streak")
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Text("\(appState.routineStreakDays()) day\(appState.routineStreakDays() == 1 ? "" : "s")")
                            .font(Theme.Typography.title())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text(appState.routineStreakDays() == 0 ? "Finish your stack once — we’ll start counting." : "Missed yesterday? It’s erased. Today still counts.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Achievements")
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        ForEach(appState.achievementRows(), id: \.id) { row in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: row.icon)
                                    .foregroundStyle(row.unlocked ? Theme.ColorToken.accentSage : Theme.ColorToken.textTertiary)
                                    .frame(width: 26)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.title)
                                        .font(Theme.Typography.subheadline())
                                        .foregroundStyle(row.unlocked ? Theme.ColorToken.textPrimary : Theme.ColorToken.textTertiary)
                                    Text(row.detail)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                }
                                Spacer()
                                if row.unlocked {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.ColorToken.success)
                                }
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photo timeline")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Weekly face / hair / skin captures with swipe compare land next. Your opt-ins from onboarding are remembered.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        if let p = appState.userProfile {
                            let lines: [String] = [
                                p.optedInFacePhoto ? "Face baseline · on" : nil,
                                p.optedInHairPhoto ? "Hair baseline · on" : nil,
                                p.optedInSkinPhoto ? "Skin baseline · on" : nil,
                            ].compactMap(\.self)
                            if lines.isEmpty {
                                Text("No baselines opted in — fine to skip until weekly capture ships.")
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textTertiary)
                            } else {
                                ForEach(lines, id: \.self) { line in
                                    Text(line)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                }
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Discover")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Protocols, ingredient guides, mini-courses, and recipes — curated to your goals.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Button("Open Discover preview") { showDiscover = true }
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coming in V1.1")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Apple Health sleep + water sync, full photo pipeline, and deeper AI protocol tuning.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appState.routineStreakDays())
            .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: appState.weeklyCheckIns.count)
        }
        .sheet(isPresented: $showWeeklyCheckIn) {
            WeeklyCheckInSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showDiscover) {
            DiscoverLibraryView()
        }
    }

    private func sparkRow(_ title: String, values: [Int]) -> some View {
        HStack(alignment: .bottom, spacing: 6) {
            Text(title)
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textSecondary)
                .frame(width: 56, alignment: .leading)
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                    let h = CGFloat(WeeklyCheckInEntry.clampRating(v)) / 5.0 * 40 + 4
                    Capsule()
                        .fill(Theme.ctaGradient.opacity(0.85))
                        .frame(width: 7, height: h)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var last7Days: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }.reversed()
    }
}
