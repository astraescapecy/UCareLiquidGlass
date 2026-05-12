import SwiftUI

struct QuestionnaireFlowView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let totalSteps = 5

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                stepBody
                    .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                    .padding(.bottom, 110)
                    .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 4), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -2))
            }
            .ucareScrollOnMesh()
        }
        .safeAreaInset(edge: .bottom) { controls }
        .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: appState.questionnaire.step)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    if appState.questionnaire.step > 0 {
                        appState.questionnaire.step -= 1
                    } else if appState.isRetakeProgramFlow {
                        appState.cancelProgramRetake()
                    } else {
                        appState.phase = .auth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.92))
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(OnboardingLabsChrome.panelFill)
                                .overlay { Circle().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1) }
                        }
                }
                .buttonStyle(GlassCapsuleButtonStyle())
                Spacer()
                Text("Step \(appState.questionnaire.step + 1) of \(totalSteps)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 5)
                GeometryReader { geo in
                    let p = CGFloat(appState.questionnaire.step + 1) / CGFloat(totalSteps)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Theme.ColorToken.terracotta.opacity(0.85),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * p), height: 5)
                }
                .frame(height: 5)
            }
            .frame(height: 5)
        }
        .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var stepBody: some View {
        Group {
            switch appState.questionnaire.step {
            case 0: stepWhyHere
            case 1: stepBaseline
            case 2: stepGlowUpDate
            case 3: stepPhotos
            default: stepNotifications
            }
        }
        .transition(reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
        .id(appState.questionnaire.step)
    }

    private var stepWhyHere: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Why are you here?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                .fixedSize(horizontal: false, vertical: true)
            Text("Pick everything that matters — we’ll blend it into one protocol.")
                .font(Theme.Typography.subheadline())
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(UCareFocus.allCases) { focus in
                    let on = appState.questionnaire.careGoals.contains(focus)
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                            if on { appState.questionnaire.careGoals.remove(focus) } else { appState.questionnaire.careGoals.insert(focus) }
                        }
                    } label: {
                        QuestionnaireGoalTileLabel(focus: focus, isSelected: on)
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                }
            }
        }
    }

    private var stepBaseline: some View {
        OnboardingLabsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Body & lifestyle baseline")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingLabsChrome.headlineGradient)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Gender")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    Picker("Gender", selection: $appState.questionnaire.sex) {
                        ForEach(BiologicalSex.allCases) { s in
                            Text(s.displayTitle).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Color.white.opacity(0.85))
                }

                Stepper("Age: \(appState.questionnaire.age)", value: $appState.questionnaire.age, in: 18 ... 80)
                    .foregroundStyle(Color.white.opacity(0.92))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Diet style")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    Picker("Diet style", selection: $appState.questionnaire.dietStyle) {
                        ForEach(DietStyle.allCases) { d in
                            Text(d.title).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Color.white.opacity(0.85))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Allergies or sensitivities")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    labsMultilineField(placeholder: "Peanuts, fragrance, etc.", text: $appState.questionnaire.allergiesText, lines: 2 ... 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Current routine (honest snapshot)")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    labsMultilineField(placeholder: "Morning rush? Night owl? Be real.", text: $appState.questionnaire.routineNotes, lines: 2 ... 5)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Problem areas you want handled")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    labsMultilineField(placeholder: "Breath after coffee, scalp itch…", text: $appState.questionnaire.problemAreasText, lines: 2 ... 5)
                }
            }
        }
    }

    private var stepGlowUpDate: some View {
        OnboardingLabsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Glow-up countdown")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                Text("Wedding, trip, first date — optional. We’ll bias intensity, not shame you.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    .lineSpacing(3)
                Toggle("I have a target date", isOn: $appState.questionnaire.wantsGlowUpTarget)
                    .tint(Color.white.opacity(0.9))
                if appState.questionnaire.wantsGlowUpTarget {
                    DatePicker("Target date", selection: $appState.questionnaire.glowUpTargetDate, displayedComponents: .date)
                        .foregroundStyle(Color.white.opacity(0.92))
                        .tint(Color.white.opacity(0.85))
                }
            }
        }
    }

    private var stepPhotos: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optional starting photos")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(OnboardingLabsChrome.headlineGradient)
            Text("Face, hair, and skin — private, on-device in this MVP build (no cloud sync yet). Encrypted storage ships before we enable sync.")
                .font(Theme.Typography.caption())
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                .lineSpacing(3)

            OnboardingLabsCard(cornerRadius: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle("Face baseline (weekly Progress)", isOn: $appState.questionnaire.optedInFacePhoto)
                        .tint(Color.white.opacity(0.9))
                    Toggle("Hair / scalp baseline", isOn: $appState.questionnaire.optedInHairPhoto)
                        .tint(Color.white.opacity(0.9))
                    Toggle("Skin close-up baseline", isOn: $appState.questionnaire.optedInSkinPhoto)
                        .tint(Color.white.opacity(0.9))
                }
            }

            Button("Skip photos for now") {
                appState.questionnaire.skippedPhotoStep = true
                appState.questionnaire.optedInFacePhoto = false
                appState.questionnaire.optedInHairPhoto = false
                appState.questionnaire.optedInSkinPhoto = false
            }
            .font(Theme.Typography.subheadline())
            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            .frame(maxWidth: .infinity)
        }
    }

    private var stepNotifications: some View {
        OnboardingLabsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Reminders you actually want")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                Text("System permission comes next in a build with push — for now we save your preferences.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    .lineSpacing(3)
                Toggle("Water rhythm reminders", isOn: $appState.questionnaire.wantsWaterReminders)
                    .tint(Color.white.opacity(0.9))
                Toggle("Morning routine nudge", isOn: $appState.questionnaire.wantsMorningRoutineNudge)
                    .tint(Color.white.opacity(0.9))
                Toggle("Evening skincare nudge", isOn: $appState.questionnaire.wantsEveningSkincareNudge)
                    .tint(Color.white.opacity(0.9))
                Toggle("Bedtime wind-down", isOn: $appState.questionnaire.wantsBedtimeWindDown)
                    .tint(Color.white.opacity(0.9))
            }
        }
    }

    private func labsMultilineField(placeholder: String, text: Binding<String>, lines: ClosedRange<Int>) -> some View {
        TextField(placeholder, text: text, axis: .vertical)
            .lineLimit(lines)
            .padding(14)
            .foregroundStyle(Color.white.opacity(0.95))
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                    }
            }
    }

    private var controls: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(OnboardingLabsChrome.hairline)
                .frame(height: 1)
            questionnairePrimaryCTA
                .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                .padding(.vertical, 12)
        }
        .background(OnboardingLabsChrome.panelFill.opacity(0.98))
    }

    private var questionnairePrimaryCTA: some View {
        Button {
            if appState.questionnaire.step == totalSteps - 1 {
                if appState.isRetakeProgramFlow {
                    appState.startAnalysis()
                } else {
                    appState.phase = .paywall
                }
            } else {
                appState.questionnaire.step += 1
            }
            appState.persistQuestionnaire()
        } label: {
            HStack(spacing: 10) {
                Text(primaryCTATitle)
                    .font(Theme.Typography.headline())
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(Color.black.opacity(canContinue ? 1 : 0.45))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .fill(Color.white.opacity(canContinue ? 1 : 0.35))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
        .disabled(!canContinue)
    }

    private var canContinue: Bool {
        switch appState.questionnaire.step {
        case 0: return !appState.questionnaire.careGoals.isEmpty
        default: return true
        }
    }

    private var primaryCTATitle: String {
        if appState.questionnaire.step == totalSteps - 1 {
            return appState.isRetakeProgramFlow ? "Rebuild protocol" : "Continue to unlock"
        }
        return "Next"
    }
}

private struct QuestionnaireGoalTileLabel: View {
    let focus: UCareFocus
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: focus.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconForeground)
            Text(focus.title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.white.opacity(isSelected ? 0.98 : 0.82))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(OnboardingLabsChrome.panelFill)
        }
        .overlay { borderShape }
        .shadow(color: isSelected ? Theme.ColorToken.usernameAvailable.opacity(0.28) : .clear, radius: 16, y: 6)
        .scaleEffect(isSelected ? 1.02 : 1)
    }

    private var iconForeground: AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(OnboardingLabsChrome.silverIconGradient)
        } else {
            AnyShapeStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.85))
        }
    }

    @ViewBuilder
    private var borderShape: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(OnboardingLabsChrome.ringGradient, lineWidth: 2)
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
        }
    }
}
