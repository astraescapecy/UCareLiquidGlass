import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false
    @State private var selectedDate: Date = .now
    @State private var expandedScience: Set<String> = []
    @State private var guidedStep: ProgramStep?
    @State private var showDayComplete = false
    @State private var confettiTrigger: UUID?
    @AppStorage("ucare.lastDayCompleteBanner") private var lastDayCompleteKey: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    weekStrip

                    completionHero

                    if let gentle = missedDayGentleLine {
                    Text(gentle)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.accentSand)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                    }

                    Text("Hey, \(firstName)")
                    .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textSecondary)

                    Text(headerTitle)
                    .font(Theme.Typography.largeTitle())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                    Text(subheaderDateLine)
                    .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textSecondary)

                    if !appState.hasActiveSubscription {
                    GlassCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Free preview")
                                .font(Theme.Typography.headline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                            Text("You’re seeing your Day‑1 stack. Unlock Plus for the full rotating protocol, deeper Glow‑Up Score, and photo timeline.")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                            Button("View plans") { appState.openPaywall() }
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        }
                        }
                    }

                    Text("Today’s stack")
                    .font(Theme.Typography.headline())
                        .foregroundStyle(Theme.ColorToken.textPrimary)

                    if !stepsForSelectedDay.isEmpty {
                    ForEach(DaySegment.orderedForToday) { segment in
                        let segSteps = stepsForSelectedDay.filter { $0.segment == segment }
                        if !segSteps.isEmpty {
                            GlassCard(cornerRadius: 18) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(segment.emoji) \(segment.title)")
                                        .font(Theme.Typography.subheadline())
                                        .foregroundStyle(Theme.ColorToken.textSecondary)
                                    ForEach(segSteps) { step in
                                        stepCard(step)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                } else if appState.userProfile == nil {
                    Text("Complete onboarding to see your stack.")
                        .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                }
            }
            .padding(Theme.Layout.contentHorizontalPadding)
            .padding(.bottom, 28)
            .opacity(entered ? 1 : 0)
            .offset(y: entered ? 0 : 16)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: entered)
            .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appState.completedStepIDs)
            }

            if let burst = confettiTrigger {
                MicroConfettiBurstView()
                    .id(burst)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .padding(.top, 72)
                    .allowsHitTesting(false)
            }
        }
        .sheet(item: $guidedStep) { step in
            GuidedStepView(step: step) {
                toggleStepWithConfetti(step.id, on: selectedDate)
                guidedStep = nil
                checkDayCompleteCelebration()
            }
        }
        .fullScreenCover(isPresented: $showDayComplete) {
            dayCompleteOverlay
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) {
                entered = true
            }
        }
        .onChange(of: appState.completedStepIDs) { _, _ in
            checkDayCompleteCelebration()
        }
    }

    /// Marks a step complete / incomplete; fires micro-confetti when transitioning to done (Phase 2).
    private func toggleStepWithConfetti(_ stepID: String, on date: Date) {
        let wasDone = appState.isStepDone(stepID, on: date)
        appState.toggleStep(stepID, on: date)
        let nowDone = appState.isStepDone(stepID, on: date)
        if !wasDone, nowDone {
            playStepConfetti()
        }
    }

    private func playStepConfetti() {
        let id = UUID()
        confettiTrigger = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if confettiTrigger == id {
                confettiTrigger = nil
            }
        }
    }

    private var weekStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(weekDates, id: \.self) { day in
                    weekCell(day)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func weekCell(_ day: Date) -> some View {
        let cal = Calendar.current
        let isSel = cal.isDate(day, inSameDayAs: selectedDate)
        let done = appState.completionFraction(on: day) >= 0.999
        return Button {
            selectedDate = day
        } label: {
            VStack(spacing: 6) {
                Text(day.formatted(.dateTime.weekday(.abbreviated)))
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                Text(day, format: .dateTime.day())
                    .font(Theme.Typography.headline())
                    .foregroundStyle(isSel ? Theme.ColorToken.textPrimary : Theme.ColorToken.textSecondary)
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(done ? Theme.ColorToken.success : Theme.ColorToken.textTertiary)
            }
            .frame(width: 58, height: 76)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSel ? AnyShapeStyle(Theme.ctaGradient.opacity(0.35)) : AnyShapeStyle(Color.white.opacity(0.06)))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSel ? Theme.ColorToken.glassStrokeFocus : Theme.ColorToken.glassStroke, lineWidth: 1)
            }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private var weekDates: [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private var headerTitle: String {
        Calendar.current.isDateInToday(selectedDate) ? "Today" : "Your day"
    }

    private var subheaderDateLine: String {
        selectedDate.formatted(.dateTime.weekday(.wide).month().day())
    }

    private var missedDayGentleLine: String? {
        let cal = Calendar.current
        guard !cal.isDateInToday(selectedDate) else { return nil }
        if appState.completionFraction(on: selectedDate) == 0 {
            return "Yesterday’s gone — today’s yours. No guilt, just the next right step."
        }
        return nil
    }

    private var firstName: String {
        if let full = appState.userProfile?.fullName.split(separator: " ").first.map(String.init), !full.isEmpty {
            return full
        }
        return appState.signUpDraft.fullName.split(separator: " ").first.map(String.init) ?? "there"
    }

    private var stepsForSelectedDay: [ProgramStep] {
        appState.visibleProgramSteps(on: selectedDate)
    }

    private var totalSteps: Int { stepsForSelectedDay.count }
    private var completedForSelected: Int {
        stepsForSelectedDay.filter { appState.isStepDone($0.id, on: selectedDate) }.count
    }

    private var completionProgress: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return CGFloat(completedForSelected) / CGFloat(totalSteps)
    }

    private var completionLine: String {
        if completedForSelected == totalSteps, totalSteps > 0 { return "Day complete — you showed up for yourself." }
        if completedForSelected == 0 { return "Pick one step. Momentum loves a small start." }
        return "\(totalSteps - completedForSelected) step\(totalSteps - completedForSelected == 1 ? "" : "s") left."
    }

    private var completionHero: some View {
        GlassCard {
            VStack(spacing: 10) {
                CalorieRingView(
                    progress: completionProgress,
                    lineWidth: 12,
                    label: completionLine,
                    centerTitle: "\(completedForSelected)/\(max(1, totalSteps))",
                    centerSubtitle: "steps done"
                )
                .frame(height: 170)
            }
        }
    }

    private func stepCard(_ step: ProgramStep) -> some View {
        let done = appState.isStepDone(step.id, on: selectedDate)
        let expanded = expandedScience.contains(step.id)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    guidedStep = step
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: step.iconSystemName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Theme.ColorToken.accentSage)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title)
                                .font(Theme.Typography.headline())
                                .foregroundStyle(Theme.ColorToken.textPrimary)
                                .multilineTextAlignment(.leading)
                            if let sec = step.estimatedSeconds {
                                Label(durationLabel(seconds: sec), systemImage: "timer")
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textTertiary)
                            } else {
                                Label("No timer", systemImage: "hand.tap")
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textTertiary)
                            }
                            Text(step.details)
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                                .multilineTextAlignment(.leading)
                            Text("Tap for guided step")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.accentTerracotta.opacity(0.85))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button {
                    toggleStepWithConfetti(step.id, on: selectedDate)
                } label: {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(done ? Theme.ColorToken.success : Theme.ColorToken.textTertiary)
                        .symbolEffect(.bounce, value: done)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(done ? "Mark step incomplete" : "Mark step complete")
            }

            if !step.scienceBlurb.isEmpty {
                Button {
                    if expanded { expandedScience.remove(step.id) } else { expandedScience.insert(step.id) }
                } label: {
                    HStack {
                        Text("Why it works")
                            .font(Theme.Typography.caption())
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    }
                    .foregroundStyle(Theme.ColorToken.accentTerracotta)
                }
                .buttonStyle(.plain)
                if expanded {
                    Text(step.scienceBlurb)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                Button {
                    guidedStep = step
                } label: {
                    Text("Open guided")
                        .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.ctaGradient.opacity(0.55)))
                }
                .buttonStyle(GlassCapsuleButtonStyle())
                Button {
                    toggleStepWithConfetti(step.id, on: selectedDate)
                } label: {
                    Text(done ? "Undo" : "Mark complete")
                        .font(Theme.Typography.subheadline())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                        .frame(minWidth: 120)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(GlassCapsuleButtonStyle())
            }
        }
        .padding(.vertical, 6)
    }

    private func durationLabel(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m > 0, s > 0 { return "~\(m)m \(s)s" }
        if m > 0 { return "~\(m)m" }
        return "~\(s)s"
    }

    private var dayCompleteOverlay: some View {
        ZStack {
            Theme.paperGradient.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("Day complete 🎯")
                    .font(Theme.Typography.largeTitle())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("You stacked proof, not perfection. Tomorrow we’ll meet you where you are.")
                    .font(Theme.Typography.subheadline())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                    .padding(.horizontal)
                GradientCTAButton(title: "Nice") {
                    showDayComplete = false
                }
                .padding(.horizontal, 40)
            }
        }
    }

    private func checkDayCompleteCelebration() {
        guard Calendar.current.isDateInToday(selectedDate) else { return }
        guard totalSteps > 0, completedForSelected == totalSteps else { return }
        let key = dayKey(selectedDate)
        guard key != lastDayCompleteKey else { return }
        lastDayCompleteKey = key
        showDayComplete = true
    }

    private func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}
