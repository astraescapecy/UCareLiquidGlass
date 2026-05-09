import SwiftUI

struct QuestionnaireFlowView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let totalSteps = 5

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView { stepBody.padding(.horizontal, Theme.Layout.contentHorizontalPadding).padding(.bottom, 110) }
        }
        .safeAreaInset(edge: .bottom) { controls }
        .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: appState.questionnaire.step)
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    if appState.questionnaire.step > 0 {
                        appState.questionnaire.step -= 1
                    } else if appState.isRetakeProgramFlow {
                        appState.cancelProgramRetake()
                    } else {
                        appState.phase = .auth
                    }
                } label: { Image(systemName: "chevron.left") }
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Spacer()
                Text("Step \(appState.questionnaire.step + 1) of \(totalSteps)")
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                    .font(Theme.Typography.footnote())
            }
            ProgressView(value: Double(appState.questionnaire.step + 1), total: Double(totalSteps))
                .tint(Theme.ColorToken.accentTerracotta)
        }
        .padding(Theme.Layout.contentHorizontalPadding)
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
        VStack(alignment: .leading, spacing: 14) {
            Text("Why are you here?")
                .font(Theme.Typography.title())
                .foregroundStyle(Theme.ColorToken.textPrimary)
            Text("Pick everything that matters — we’ll blend it into one protocol.")
                .font(Theme.Typography.subheadline())
                .foregroundStyle(Theme.ColorToken.textSecondary)

            let cols = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(UCareFocus.allCases) { focus in
                    let on = appState.questionnaire.careGoals.contains(focus)
                    Button {
                        if on { appState.questionnaire.careGoals.remove(focus) } else { appState.questionnaire.careGoals.insert(focus) }
                    } label: {
                        GlassCard(cornerRadius: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(systemName: focus.icon)
                                    .foregroundStyle(Theme.ColorToken.accentSage)
                                Text(focus.title)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(on ? Theme.ctaGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                        }
                        .shadow(color: on ? Theme.ColorToken.glowWarm : .clear, radius: on ? 12 : 0)
                        .scaleEffect(on ? 1.02 : 1)
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                }
            }
        }
    }

    private var stepBaseline: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Body & lifestyle baseline")
                    .font(Theme.Typography.headline())
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                Picker("Gender", selection: $appState.questionnaire.sex) {
                    ForEach(BiologicalSex.allCases) { s in
                        Text(s.displayTitle).tag(s)
                    }
                }
                .pickerStyle(.segmented)

                Stepper("Age: \(appState.questionnaire.age)", value: $appState.questionnaire.age, in: 18 ... 80)
                    .foregroundStyle(Theme.ColorToken.textPrimary)

                Text("Diet style").font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                Picker("Diet style", selection: $appState.questionnaire.dietStyle) {
                    ForEach(DietStyle.allCases) { d in
                        Text(d.title).tag(d)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Allergies or sensitivities").font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                    TextField("Peanuts, fragrance, etc.", text: $appState.questionnaire.allergiesText, axis: .vertical)
                        .lineLimit(2 ... 4)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Current routine (honest snapshot)").font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                    TextField("Morning rush? Night owl? Be real.", text: $appState.questionnaire.routineNotes, axis: .vertical)
                        .lineLimit(2 ... 5)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Problem areas you want handled").font(Theme.Typography.caption()).foregroundStyle(Theme.ColorToken.textSecondary)
                    TextField("Breath after coffee, scalp itch…", text: $appState.questionnaire.problemAreasText, axis: .vertical)
                        .lineLimit(2 ... 5)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
                }
            }
        }
    }

    private var stepGlowUpDate: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Glow-up countdown")
                    .font(Theme.Typography.headline())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("Wedding, trip, first date — optional. We’ll bias intensity, not shame you.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                Toggle("I have a target date", isOn: $appState.questionnaire.wantsGlowUpTarget)
                    .tint(Theme.ColorToken.accentTerracotta)
                if appState.questionnaire.wantsGlowUpTarget {
                    DatePicker("Target date", selection: $appState.questionnaire.glowUpTargetDate, displayedComponents: .date)
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                }
            }
        }
    }

    private var stepPhotos: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Optional starting photos")
                .font(Theme.Typography.title2())
                .foregroundStyle(Theme.ColorToken.textPrimary)
            Text("Face, hair, and skin — private, on-device in this MVP build (no cloud sync yet). Encrypted storage ships before we enable sync.")
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textSecondary)

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Face baseline (weekly Progress)", isOn: $appState.questionnaire.optedInFacePhoto)
                        .tint(Theme.ColorToken.accentTerracotta)
                    Toggle("Hair / scalp baseline", isOn: $appState.questionnaire.optedInHairPhoto)
                        .tint(Theme.ColorToken.accentTerracotta)
                    Toggle("Skin close-up baseline", isOn: $appState.questionnaire.optedInSkinPhoto)
                        .tint(Theme.ColorToken.accentTerracotta)
                }
            }

            Button("Skip photos for now") {
                appState.questionnaire.skippedPhotoStep = true
                appState.questionnaire.optedInFacePhoto = false
                appState.questionnaire.optedInHairPhoto = false
                appState.questionnaire.optedInSkinPhoto = false
            }
            .font(Theme.Typography.caption())
            .foregroundStyle(Theme.ColorToken.textSecondary)
        }
    }

    private var stepNotifications: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Reminders you actually want")
                    .font(Theme.Typography.headline())
                    .foregroundStyle(Theme.ColorToken.textPrimary)
                Text("System permission comes next in a build with push — for now we save your preferences.")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
                Toggle("Water rhythm reminders", isOn: $appState.questionnaire.wantsWaterReminders)
                    .tint(Theme.ColorToken.accentTerracotta)
                Toggle("Morning routine nudge", isOn: $appState.questionnaire.wantsMorningRoutineNudge)
                    .tint(Theme.ColorToken.accentTerracotta)
                Toggle("Evening skincare nudge", isOn: $appState.questionnaire.wantsEveningSkincareNudge)
                    .tint(Theme.ColorToken.accentTerracotta)
                Toggle("Bedtime wind-down", isOn: $appState.questionnaire.wantsBedtimeWindDown)
                    .tint(Theme.ColorToken.accentTerracotta)
            }
        }
    }

    private var controls: some View {
        GradientCTAButton(title: primaryCTATitle, isEnabled: canContinue) {
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
        }
        .padding(Theme.Layout.contentHorizontalPadding)
        .padding(.vertical, 10)
        .background(.regularMaterial)
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
