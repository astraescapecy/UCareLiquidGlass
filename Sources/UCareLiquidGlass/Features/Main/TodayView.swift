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
        ZStack {
            TodayPageLabsBackground()
                .ignoresSafeArea()

            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        weekStrip

                        completionHero

                        if let gentle = missedDayGentleLine {
                            Text(gentle)
                                .font(Theme.Typography.caption())
                                .foregroundStyle(TodayPageLabs.secondaryLabel)
                                .lineSpacing(4)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(TodayPageLabs.elevated)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(TodayPageLabs.hairline, lineWidth: 1)
                                        }
                                }
                        }

                        Text(mainListTitle)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .fixedSize(horizontal: false, vertical: true)

                        if !appState.hasActiveSubscription {
                            TodayPageLabsCard(cornerRadius: 16) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Free preview")
                                        .font(Theme.Typography.headline())
                                        .foregroundStyle(Color.white)
                                    Text("You’re seeing your Day‑1 stack. Unlock Plus for the full rotating protocol, deeper Glow‑Up Score, and photo timeline.")
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(TodayPageLabs.secondaryLabel)
                                        .lineSpacing(4)
                                    Button {
                                        appState.openPaywall()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("View plans")
                                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        }
                                        .foregroundStyle(TodayPageLabs.onLight)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Capsule().fill(Color.white))
                                    }
                                    .buttonStyle(GlassCapsuleButtonStyle())
                                }
                            }
                        }

                        if !stepsForSelectedDay.isEmpty {
                            ForEach(DaySegment.orderedForToday) { segment in
                                let segSteps = stepsForSelectedDay.filter { $0.segment == segment }
                                if !segSteps.isEmpty {
                                    TodayPageLabsCard(cornerRadius: 18) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("\(segment.emoji) \(segment.title)")
                                                .font(Theme.Typography.subheadline())
                                                .foregroundStyle(TodayPageLabs.secondaryLabel)
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
                                .foregroundStyle(TodayPageLabs.secondaryLabel)
                        }
                    }
                    .padding(.top, 8)
                    .padding(Theme.Layout.contentHorizontalPadding)
                    .padding(.bottom, 28)
                    .opacity(entered ? 1 : 0)
                    .offset(y: entered ? 0 : 16)
                    .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: entered)
                    .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appState.completedStepIDs)
                }
                .ucareScrollOnMesh()

                if let burst = confettiTrigger {
                    MicroConfettiBurstView()
                        .id(burst)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .padding(.top, 72)
                        .allowsHitTesting(false)
                }
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
        .ucareScrollOnMesh()
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
                    .foregroundStyle(isSel ? Color.black.opacity(0.45) : TodayPageLabs.secondaryLabel)
                Text(day, format: .dateTime.day())
                    .font(Theme.Typography.headline())
                    .foregroundStyle(isSel ? Color.black : Color.white.opacity(0.92))
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        done
                            ? (isSel ? Color.black : Color.white)
                            : (isSel ? Color.black.opacity(0.35) : TodayPageLabs.secondaryLabel.opacity(0.7))
                    )
            }
            .frame(width: 58, height: 76)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSel ? AnyShapeStyle(Color.white) : AnyShapeStyle(TodayPageLabs.pillSecondaryFill))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSel ? Color.black.opacity(0.08) : TodayPageLabs.hairlineMuted, lineWidth: 1)
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

    private var mainListTitle: String {
        Calendar.current.isDateInToday(selectedDate) ? "Today's to do list" : "To-do list"
    }

    private var missedDayGentleLine: String? {
        let cal = Calendar.current
        guard !cal.isDateInToday(selectedDate) else { return nil }
        if appState.completionFraction(on: selectedDate) == 0 {
            return "Yesterday’s gone — today’s yours. No guilt, just the next right step."
        }
        return nil
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
        TodayPageLabsCard(cornerRadius: Theme.Layout.glassCornerRadius) {
            VStack(spacing: 16) {
                CalorieRingView(
                    progress: completionProgress,
                    lineWidth: 13,
                    label: "",
                    centerTitle: "\(completedForSelected)/\(max(1, totalSteps))",
                    centerSubtitle: "steps done",
                    monochromeProgress: true
                )
                .frame(maxWidth: .infinity)
                .frame(height: 168)

                Text(completionLine)
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(TodayPageLabs.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
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
                            .foregroundStyle(Color.white.opacity(0.85))
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title)
                                .font(Theme.Typography.headline())
                                .foregroundStyle(Color.white)
                                .multilineTextAlignment(.leading)
                            if let sec = step.estimatedSeconds {
                                Label(durationLabel(seconds: sec), systemImage: "timer")
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(TodayPageLabs.secondaryLabel)
                            } else {
                                Label("No timer", systemImage: "hand.tap")
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(TodayPageLabs.secondaryLabel)
                            }
                            Text(step.details)
                                .font(Theme.Typography.caption())
                                .foregroundStyle(TodayPageLabs.secondaryLabel)
                                .lineSpacing(3)
                                .multilineTextAlignment(.leading)
                            Text("Tap for guided step")
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Color.white.opacity(0.92))
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
                        .foregroundStyle(done ? Color.white : TodayPageLabs.secondaryLabel.opacity(0.75))
                        .symbolEffect(.bounce, value: done)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(done ? "Mark step incomplete" : "Mark step complete")
            }

            if !step.scienceBlurb.isEmpty {
                Button {
                    if expanded { expandedScience.remove(step.id) } else { expandedScience.insert(step.id) }
                } label: {
                    HStack(spacing: 6) {
                        Text("Why it works")
                            .font(Theme.Typography.caption())
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    }
                    .foregroundStyle(Color.white.opacity(0.88))
                }
                .buttonStyle(.plain)
                if expanded {
                    Text(step.scienceBlurb)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(TodayPageLabs.secondaryLabel)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                Button {
                    guidedStep = step
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("Open guided")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(TodayPageLabs.onLight)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white))
                }
                .buttonStyle(GlassCapsuleButtonStyle())
                .frame(maxWidth: .infinity)
                Button {
                    toggleStepWithConfetti(step.id, on: selectedDate)
                } label: {
                    Text(done ? "Undo" : "Mark complete")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .strokeBorder(TodayPageLabs.hairline, lineWidth: 1)
                                .background(Capsule().fill(TodayPageLabs.pillSecondaryFill))
                        }
                }
                .buttonStyle(GlassCapsuleButtonStyle())
                .frame(maxWidth: .infinity)
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
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
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

// MARK: - Today tab only — minimal landing-style preview (black canvas, white CTAs)

private enum TodayPageLabs {
    static let canvas = Color(hex: 0x000000)
    static let elevated = Color(hex: 0x0A0A0A)
    static let secondaryLabel = Color(hex: 0xA0A0A0)
    static let onLight = Color(hex: 0x000000)
    static let hairline = Color.white.opacity(0.18)
    static let hairlineMuted = Color.white.opacity(0.12)
    static let pillSecondaryFill = Color.white.opacity(0.06)
}

private struct TodayPageLabsBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let m = max(w, h)
            let blur: CGFloat = reduceMotion ? 22 : 52

            ZStack {
                // Crisp base (not blurred) — keeps edges true black.
                LinearGradient(
                    colors: [
                        Color(hex: 0x000000),
                        Color(hex: 0x050506),
                        Color(hex: 0x0C0C0F),
                        Color(hex: 0x020203),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Atmospheric black / white / gray — blurred as one layer.
                ZStack {
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.06),
                            Color(white: 0.55).opacity(0.10),
                            Color.clear,
                        ],
                        center: UnitPoint(x: 0.88, y: -0.02),
                        startRadius: m * 0.02,
                        endRadius: m * 0.72
                    )

                    RadialGradient(
                        colors: [
                            Color(white: 0.42).opacity(0.28),
                            Color(white: 0.18).opacity(0.12),
                            Color.clear,
                        ],
                        center: UnitPoint(x: 0.12, y: 0.92),
                        startRadius: m * 0.04,
                        endRadius: m * 0.68
                    )

                    RadialGradient(
                        colors: [
                            Color(white: 0.30).opacity(0.14),
                            Color.clear,
                        ],
                        center: UnitPoint(x: 0.55, y: 0.38),
                        startRadius: 0,
                        endRadius: m * 0.45
                    )

                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.045),
                            Color(white: 0.65).opacity(0.09),
                            Color.white.opacity(0.04),
                            Color.clear,
                        ],
                        startPoint: UnitPoint(x: -0.05, y: 0.35),
                        endPoint: UnitPoint(x: 1.05, y: 0.62)
                    )
                    .rotationEffect(.degrees(-10))
                }
                .blur(radius: blur)
                .opacity(reduceMotion ? 0.75 : 1)

                // Light vignette (sharp) — depth without washing text.
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.42),
                        Color.clear,
                        Color.black.opacity(0.55),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.85)
            }
            .frame(width: w, height: h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TodayPageLabs.canvas)
        .allowsHitTesting(false)
    }
}

private struct TodayPageLabsCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Layout.glassCornerRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(Theme.Layout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(TodayPageLabs.elevated)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(TodayPageLabs.hairline, lineWidth: 1)
            }
    }
}
