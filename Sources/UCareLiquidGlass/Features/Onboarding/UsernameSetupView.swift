import SwiftUI

/// Post-auth handle: public @username — labs chrome; layout tuned for this step (not a copy of auth).
struct UsernameSetupView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var fieldFocused: Bool

    @State private var draft = ""
    @State private var appeared = false

    private var normalized: String { UCareUsernameAvailability.normalized(draft) }

    private var reason: String? { UCareUsernameAvailability.validationReason(for: draft) }

    private var isOK: Bool { normalized.count >= 3 && reason == nil }

    private var displayHandle: String {
        let n = normalized
        return n.isEmpty ? "yourname" : n
    }

    /// Neutral while still typing; green when valid; red when long enough but invalid / taken.
    private enum AtAvailability {
        case neutral, available, unavailable
    }

    private var atAvailability: AtAvailability {
        if normalized.count < 3 { return .neutral }
        if reason != nil { return .unavailable }
        return .available
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(spacing: 0) {
                    introBlock
                        .padding(.bottom, 22)

                    heroPreviewDial
                        .padding(.bottom, 28)

                    editorCard
                        .padding(.bottom, 20)

                    suggestionsBlock
                        .padding(.bottom, 16)

                    rulesInline
                        .padding(.bottom, 18)

                    statusCard
                }
                .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 4), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -2))
            }
            .ucareScrollOnMesh()

            usernamePrimaryButton
                .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
                .padding(.bottom, max(12, 8))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
                .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.12, reduceMotion: reduceMotion), value: appeared)
        }
        .onAppear {
            if draft.isEmpty {
                draft = suggestedHandle()
            }
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fieldFocused = true
            }
        }
    }

    private var introBlock: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Claim your handle")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Friends see this on invites and when you share progress. You can’t change it later in this build.")
                .font(Theme.Typography.subheadline())
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(LLGAnimation.entrance(reduceMotion: reduceMotion), value: appeared)
    }

    private var heroPreviewDial: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(atAvailability == .available ? 0.14 : atAvailability == .unavailable ? 0.1 : 0.08),
                                Color.clear,
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 56)
                    .offset(y: 44)
                    .blur(radius: 8)

                TimelineView(.animation(minimumInterval: reduceMotion ? 0.35 : 1.0 / 28.0, paused: false)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let pulse = reduceMotion ? 1.0 : 1.0 + 0.06 * sin(t * 2.8)
                    let tilt = reduceMotion ? 0.0 : sin(t * 1.15) * 1.8

                    ZStack {
                        Circle()
                            .stroke(atRingOuterLine, lineWidth: 10)
                            .blur(radius: 14)
                            .opacity(atAvailability == .neutral ? 0.22 : 0.38)
                            .frame(width: 118, height: 118)

                        Circle()
                            .fill(Color.white.opacity(0.04))
                            .frame(width: 112, height: 112)
                            .overlay {
                                Circle()
                                    .strokeBorder(atRingCrispLine, lineWidth: 2.5)
                            }

                        Text("@")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(atGlyphStyle)
                            .shadow(color: atGlyphShadow.opacity(0.5), radius: reduceMotion ? 4 : 10 + 4 * sin(t * 2.2))
                            .scaleEffect(pulse)
                            .rotationEffect(.degrees(tilt))
                    }
                }
            }
            .frame(height: 132)

            VStack(spacing: 6) {
                Text("Live preview")
                    .font(Theme.Typography.caption())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                Text("@\(displayHandle)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.96))
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.96)
        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.04, reduceMotion: reduceMotion), value: appeared)
    }

    private var atGlyphStyle: AnyShapeStyle {
        switch atAvailability {
        case .available:
            AnyShapeStyle(Theme.ColorToken.usernameAvailable)
        case .unavailable:
            AnyShapeStyle(Theme.ColorToken.usernameTaken)
        case .neutral:
            AnyShapeStyle(OnboardingLabsChrome.silverIconGradient)
        }
    }

    private var atRingOuterLine: LinearGradient {
        switch atAvailability {
        case .available:
            LinearGradient(colors: [Theme.ColorToken.usernameAvailable.opacity(0.5), Theme.ColorToken.usernameAvailable.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        case .unavailable:
            LinearGradient(colors: [Theme.ColorToken.usernameTaken.opacity(0.55), Theme.ColorToken.usernameTaken.opacity(0.12)], startPoint: .top, endPoint: .bottom)
        case .neutral:
            LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var atRingCrispLine: LinearGradient {
        switch atAvailability {
        case .available:
            LinearGradient(colors: [Theme.ColorToken.usernameAvailable, Theme.ColorToken.usernameAvailable.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .unavailable:
            LinearGradient(colors: [Theme.ColorToken.usernameTaken, Theme.ColorToken.usernameTaken.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neutral:
            LinearGradient(colors: [Color.white.opacity(0.45), Color(white: 0.35).opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var atGlyphShadow: Color {
        switch atAvailability {
        case .available: Theme.ColorToken.usernameAvailable
        case .unavailable: Theme.ColorToken.usernameTaken
        case .neutral: Color.white
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                fieldFocused = false
                appState.phase = .auth
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
            Text("STEP 1 OF 2")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var editorCard: some View {
        OnboardingLabsCard(cornerRadius: Theme.Layout.fieldCornerRadius + 4) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OnboardingLabsChrome.silverIconGradient)
                    Text("YOUR HANDLE")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                }

                ZStack(alignment: .leading) {
                    if normalized.isEmpty {
                        Text("username")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.45))
                    }

                    TextField("", text: $draft, prompt: Text("letters, numbers, _").foregroundStyle(OnboardingLabsChrome.secondaryLabel.opacity(0.4)))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.96))
                        .focused($fieldFocused)
                        .onChange(of: draft) { _, newValue in
                            let filtered = UCareUsernameAvailability.normalized(newValue)
                            if filtered != newValue.lowercased() {
                                draft = filtered
                            }
                        }

                    HStack {
                        Spacer(minLength: 0)
                        Image(systemName: "pencil.line")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    }
                }
                .padding(.vertical, 6)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: isOK
                                ? [Theme.ColorToken.usernameAvailable.opacity(0.5), Theme.ColorToken.usernameAvailable]
                                : (normalized.count >= 3 && reason != nil)
                                    ? [Theme.ColorToken.usernameTaken.opacity(0.4), Theme.ColorToken.usernameTaken]
                                    : [Color.white.opacity(0.12), Color.white.opacity(0.28)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .clipShape(Capsule())
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius + 4, style: .continuous)
                .strokeBorder(
                    isOK
                        ? Theme.ColorToken.usernameAvailable.opacity(0.45)
                        : (normalized.count >= 3 && reason != nil ? Theme.ColorToken.usernameTaken.opacity(0.45) : Color.clear),
                    lineWidth: 1.2
                )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.06, reduceMotion: reduceMotion), value: appeared)
    }

    private var suggestionsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ideas for you")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 10, alignment: .leading)], alignment: .leading, spacing: 10) {
                ForEach(handleSuggestions(), id: \.self) { suggestion in
                    UsernameSuggestionChip(
                        suggestion: suggestion,
                        isSelected: suggestion == normalized
                    ) {
                        draft = suggestion
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.08, reduceMotion: reduceMotion), value: appeared)
    }

    private var rulesInline: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Requirements")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingLabsChrome.secondaryLabel)

            VStack(alignment: .leading, spacing: 8) {
                ruleLine(icon: "ruler", "3–14 characters")
                ruleLine(icon: "textformat", "Letters, numbers, underscore")
                ruleLine(icon: "eye", "Public on this device")
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(OnboardingLabsChrome.panelFill.opacity(0.65))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(OnboardingLabsChrome.hairline.opacity(0.7), lineWidth: 1)
                    }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.09, reduceMotion: reduceMotion), value: appeared)
    }

    private func ruleLine(icon: String, _ text: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(OnboardingLabsChrome.silverIconGradient)
                .frame(width: 22, alignment: .center)
            Text(text)
                .font(Theme.Typography.caption())
                .foregroundStyle(Color.white.opacity(0.82))
            Spacer(minLength: 0)
        }
    }

    private var statusCard: some View {
        OnboardingLabsCard(cornerRadius: 14) {
            HStack(alignment: .top, spacing: 12) {
                Group {
                    if normalized.count < 3 {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                    } else if reason != nil {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.ColorToken.usernameTaken)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.ColorToken.usernameAvailable)
                    }
                }
                .font(.system(size: 22, weight: .semibold))

                VStack(alignment: .leading, spacing: 4) {
                    if normalized.count < 3 {
                        Text("Keep typing")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text("At least 3 letters or numbers — underscore is OK anywhere in the middle.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                            .lineSpacing(3)
                    } else if let reason {
                        Text("Can’t use this one")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text(reason)
                            .font(Theme.Typography.subheadline())
                            .foregroundStyle(Theme.ColorToken.usernameTaken)
                    } else {
                        Text("You’re clear")
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text("This handle is available on this device.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.usernameAvailable)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(LLGAnimation.softFade(reduceMotion: reduceMotion), value: normalized)
    }

    private var usernamePrimaryButton: some View {
        Button {
            fieldFocused = false
            appState.finishUsernameSetup(normalized: normalized)
        } label: {
            HStack(spacing: 10) {
                Text("Continue with @\(displayHandle)")
                    .font(Theme.Typography.headline())
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(Color.black.opacity(isOK ? 1 : 0.45))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .fill(Color.white.opacity(isOK ? 1 : 0.35))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
        .disabled(!isOK)
    }

    private func handleSuggestions() -> [String] {
        let base = suggestedHandle()
        var out: [String] = []
        let candidates = [
            base,
            UCareUsernameAvailability.normalized(String(base.prefix(10)) + "_"),
            UCareUsernameAvailability.normalized(String(base.prefix(8)) + "hq"),
            UCareUsernameAvailability.normalized(String(base.prefix(6)) + "uc"),
        ]
        for c in candidates where !c.isEmpty {
            if !out.contains(c) { out.append(c) }
        }
        var n = 0
        while out.count < 4, n < 30 {
            n += 1
            let alt = UCareUsernameAvailability.normalized(String(base.prefix(8)) + String(n))
            if !out.contains(alt), UCareUsernameAvailability.isAvailable(alt) {
                out.append(alt)
            }
        }
        return Array(out.prefix(6))
    }

    private func suggestedHandle() -> String {
        let existing = appState.username.trimmingCharacters(in: .whitespacesAndNewlines)
        if !existing.isEmpty, UCareUsernameAvailability.isAvailable(existing) { return existing }
        let raw = appState.signUpDraft.email.split(separator: "@").first.map(String.init) ?? "you"
        let cleaned = raw.filter(\.isLetter).lowercased()
        let base = String(cleaned.prefix(10)).isEmpty ? "you" : String(cleaned.prefix(10))
        var candidate = UCareUsernameAvailability.normalized(base)
        var n = 0
        while !UCareUsernameAvailability.isAvailable(candidate), n < 80 {
            n += 1
            candidate = UCareUsernameAvailability.normalized(String(base.prefix(8)) + String(n))
        }
        return candidate
    }
}

private struct UsernameSuggestionChip: View {
    let suggestion: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("@\(suggestion)")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.82))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.white : OnboardingLabsChrome.panelFill)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
