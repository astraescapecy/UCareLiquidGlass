import Charts
import PhotosUI
import SwiftUI
import UIKit

private struct GlowTrendSample: Identifiable {
    let date: Date
    let score: Int
    var id: Date { date }
}

private struct ComparePhotoPayload: Identifiable {
    let id = UUID()
    let beforeMonday: Date
    let afterMonday: Date
}

/// Phase 3 — Progress: Glow-Up Score + chart, weekly check-in, streaks & achievements grid, photo timeline, Discover (JSON).
struct ProgressOverviewView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showWeeklyCheckIn = false
    @State private var showDiscover = false
    @State private var comparePayload: ComparePhotoPayload?
    @State private var pickerItem: PhotosPickerItem?
    @State private var photoVersion = 0

    private var trendSamples: [GlowTrendSample] {
        appState.glowScoreTrendLast7Days().map { GlowTrendSample(date: $0.date, score: $0.score) }
    }

    private let achievementColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("Glow-Up Score, your mirror check-in, streaks, photos, and Discover — built from what you actually do.")
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
                        Text("Blends last-7-day routine adherence, hydration steps you finish, this week’s self-ratings when you log them, and your streak. Missing a check-in doesn’t punish you.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                        Text("Hydration signal: \(Int(appState.hydrationAdherenceLast7Days() * 100))% of water-tagged steps completed (last 7 days).")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("7-day trend")
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Chart(trendSamples) { sample in
                            AreaMark(
                                x: .value("Day", sample.date),
                                y: .value("Score", sample.score)
                            )
                            .foregroundStyle(Theme.ctaGradient.opacity(0.22))
                            LineMark(
                                x: .value("Day", sample.date),
                                y: .value("Score", sample.score)
                            )
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        }
                        .chartYScale(domain: 0...100)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                    .foregroundStyle(Color.white.opacity(0.08))
                                AxisValueLabel {
                                    if let d = value.as(Date.self) {
                                        Text(d, format: .dateTime.weekday(.narrow))
                                            .font(Theme.Typography.caption())
                                            .foregroundStyle(Theme.ColorToken.textTertiary)
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 200)
                    }
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
                        Text("Skin, breath, body odor, hair, energy, mood, sex drive, sleep, gut, intimate confidence — 1 (rough) to 5 (great).")
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
                            sparkRow("Sex drive", values: chronological.map(\.sexDrive))
                            sparkRow("Hair", values: chronological.map(\.hairScalp))
                            sparkRow("Energy", values: chronological.map(\.energy))
                            sparkRow("Sleep", values: chronological.map(\.sleepQuality))
                            sparkRow("Gut", values: chronological.map(\.gutComfort))
                            sparkRow("Intimate", values: chronological.map(\.intimateConfidence))
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("Achievements")
                        .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                    LazyVGrid(columns: achievementColumns, spacing: 12) {
                        ForEach(appState.achievementRows(), id: \.id) { row in
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: row.icon)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(row.unlocked ? Theme.ColorToken.accentSage : Theme.ColorToken.textTertiary)
                                    Text(row.title)
                                        .font(Theme.Typography.subheadline())
                                        .foregroundStyle(row.unlocked ? Theme.ColorToken.textPrimary : Theme.ColorToken.textTertiary)
                                        .lineLimit(2)
                                    Text(row.detail)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                        .lineLimit(4)
                                    if row.unlocked {
                                        HStack {
                                            Spacer(minLength: 0)
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Theme.ColorToken.success)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photo timeline")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Weekly selfie for your Progress lane — on device only. Swipe compare uses your oldest and newest saved week.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)

                        PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                            Label("Add this week’s photo", systemImage: "camera.fill")
                                .font(Theme.Typography.subheadline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.ctaGradient.opacity(0.45)))
                        }
                        .buttonStyle(GlassCapsuleButtonStyle())
                        .onChange(of: pickerItem) { _, newItem in
                            Task { await importWeeklyPhoto(from: newItem) }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(recentWeekMondays, id: \.self) { monday in
                                    weekThumb(monday)
                                }
                            }
                        }

                        if WeeklyProgressPhotoStore.weekMondaysWithPhotos().count >= 2 {
                            Button("Swipe compare (oldest vs newest)") {
                                let weeks = WeeklyProgressPhotoStore.weekMondaysWithPhotos()
                                comparePayload = ComparePhotoPayload(
                                    beforeMonday: weeks.last!,
                                    afterMonday: weeks.first!
                                )
                            }
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        }

                        if let p = appState.userProfile {
                            let lines: [String] = [
                                p.optedInFacePhoto ? "Face baseline · on" : nil,
                                p.optedInHairPhoto ? "Hair baseline · on" : nil,
                                p.optedInSkinPhoto ? "Skin baseline · on" : nil,
                            ].compactMap(\.self)
                            if !lines.isEmpty {
                                ForEach(lines, id: \.self) { line in
                                    Text(line)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.ColorToken.textTertiary)
                                }
                            }
                        }
                    }
                }
                .id(photoVersion)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Discover")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Protocols, ingredient guides, mini-courses — loaded from bundled JSON.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                        Button("Open Discover") { showDiscover = true }
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coming next")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text("Apple Health sleep + water sync (Phase 8), cloud backup, and encrypted photo storage.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appState.routineStreakDays())
            .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: appState.weeklyCheckIns.count)
            .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: photoVersion)
        }
        .sheet(isPresented: $showWeeklyCheckIn) {
            WeeklyCheckInSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showDiscover) {
            DiscoverLibraryView()
        }
        .sheet(item: $comparePayload) { payload in
            ProgressPhotoCompareSheet(beforeMonday: payload.beforeMonday, afterMonday: payload.afterMonday)
        }
    }

    private var recentWeekMondays: [Date] {
        let cal = Calendar.current
        let this = WeeklyCheckInEntry.mondayWeekStart(containing: .now)
        return (0..<8).compactMap { cal.date(byAdding: .weekOfYear, value: -$0, to: this) }
    }

    @ViewBuilder
    private func weekThumb(_ monday: Date) -> some View {
        let label = monday.formatted(.dateTime.month(.abbreviated).day())
        VStack(spacing: 6) {
            if let data = WeeklyProgressPhotoStore.loadJPEGData(weekMonday: monday),
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1)
                    }
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 72, height: 72)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(Theme.ColorToken.textTertiary)
                    }
            }
            Text(label)
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textTertiary)
        }
    }

    private func importWeeklyPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            guard let ui = UIImage(data: data), let jpg = ui.jpegData(compressionQuality: 0.78) else { return }
            try WeeklyProgressPhotoStore.saveJPEG(jpg, weekContaining: .now)
            await MainActor.run {
                photoVersion += 1
                pickerItem = nil
            }
        } catch {
            await MainActor.run { pickerItem = nil }
        }
    }

    private func sparkRow(_ title: String, values: [Int]) -> some View {
        HStack(alignment: .bottom, spacing: 6) {
            Text(title)
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textSecondary)
                .frame(width: 72, alignment: .leading)
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
}
