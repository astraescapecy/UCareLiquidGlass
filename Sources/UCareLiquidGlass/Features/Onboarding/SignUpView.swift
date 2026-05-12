import SwiftUI

struct SignUpView: View {
    enum Mode { case signUp, signIn }
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var parallax: ParallaxMotion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var mode: Mode = .signUp
    @State private var passwordVisible = false
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var entered = false
    @State private var formBounce = false
    @State private var authNotice: AuthNotice?

    private enum AuthNotice: Identifiable {
        case forgotPassword
        case socialApple
        case socialGoogle
        var id: String {
            switch self {
            case .forgotPassword: return "forgot"
            case .socialApple: return "apple"
            case .socialGoogle: return "google"
            }
        }
    }

    private let decorIcons = [
        "lock.shield.fill",
        "person.text.rectangle.fill",
        "envelope.fill",
        "key.horizontal.fill",
        "touchid",
        "checkmark.seal.fill",
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button {
                        appState.phase = .getStarted
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .frame(width: 40, height: 40)
                            .background {
                                Circle()
                                    .fill(OnboardingLabsChrome.panelFill)
                                    .overlay {
                                        Circle().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                                    }
                            }
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                    Spacer()
                }

                decorIconStrip
                    .opacity(entered ? 1 : 0)
                    .offset(y: entered ? 0 : 10)
                    .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.02, reduceMotion: reduceMotion), value: entered)

                VStack(spacing: 6) {
                    Text(mode == .signUp ? "Join UCare" : "Welcome back")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingLabsChrome.headlineGradient)
                        .multilineTextAlignment(.center)
                    Text(mode == .signUp ? "Create your local account — data stays on this device." : "Sign in to continue your protocol.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 4)
                .opacity(entered ? 1 : 0)
                .offset(y: entered ? 0 : 12)
                .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.05, reduceMotion: reduceMotion), value: entered)

                modeToggle
                    .opacity(entered ? 1 : 0)
                    .offset(y: entered ? 0 : 10)
                    .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.08, reduceMotion: reduceMotion), value: entered)

                Group {
                    if mode == .signUp {
                        signUpForm
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        loginForm
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .animation(LLGAnimation.screenSpring(reduceMotion: reduceMotion), value: mode)
                .scaleEffect(formBounce && !reduceMotion ? 1.018 : 1.0)
                .opacity(entered ? 1 : 0)
                .offset(y: entered ? 0 : 14)
                .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.1, reduceMotion: reduceMotion), value: entered)

                socialButtons
                    .opacity(entered ? 1 : 0)
                    .offset(y: entered ? 0 : 16)
                    .animation(LLGAnimation.entrance(delay: reduceMotion ? 0 : 0.14, reduceMotion: reduceMotion), value: entered)
            }
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .offset(x: reduceMotion ? 0 : CGFloat(parallax.roll * 5), y: reduceMotion ? 0 : CGFloat(parallax.pitch * -3))
        }
        .ucareScrollOnMesh()
        .onAppear {
            if appState.consumeOpenAuthOnSignInTab() {
                mode = .signIn
            }
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { entered = true }
        }
        .onChange(of: mode) { _, _ in
            guard !reduceMotion else { return }
            formBounce = false
            withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) {
                formBounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                formBounce = false
            }
        }
        .alert(item: $authNotice) { notice in
            switch notice {
            case .forgotPassword:
                Alert(
                    title: Text("Password reset"),
                    message: Text("UCare doesn’t run a cloud account yet — everything is on this device. There’s no email reset in this build. You can delete the local account from Profile and sign up again."),
                    dismissButton: .default(Text("OK"))
                )
            case .socialApple, .socialGoogle:
                Alert(
                    title: Text("Coming soon"),
                    message: Text("Sign in with Apple and Google aren’t wired up in this MVP. Use email and password for now."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var decorIconStrip: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 1.0 / 36.0, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(decorIcons.enumerated()), id: \.offset) { index, name in
                        let bob = reduceMotion ? 0 : sin(t * 2.15 + Double(index) * 0.65) * 3.2
                        OnboardingDecorChip(icon: name, bob: bob)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 6)
            }
        }
    }

    private var modeToggle: some View {
        HStack(spacing: 6) {
            toggleButton("Create Account", .signUp, systemImage: "person.badge.plus")
            toggleButton("Sign In", .signIn, systemImage: "person.fill")
        }
        .padding(4)
        .background {
            Capsule()
                .fill(OnboardingLabsChrome.panelFill)
                .overlay { Capsule().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1) }
        }
    }

    private func toggleButton(_ title: String, _ value: Mode, systemImage: String) -> some View {
        let on = mode == value
        return Button {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) { mode = value }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(on ? Color.black : Color.white.opacity(0.78))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if on {
                    Capsule().fill(Color.white)
                } else {
                    Capsule().fill(Color.clear)
                }
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var signUpForm: some View {
        OnboardingLabsCard {
            VStack(alignment: .leading, spacing: 14) {
                labeledField(icon: "person.fill", title: "Full name") {
                    field("Full Name", text: $appState.signUpDraft.fullName)
                }
                labeledField(icon: "envelope.fill", title: "Email") {
                    field("Email", text: $appState.signUpDraft.email)
                }
                labeledField(icon: "lock.fill", title: "Password") {
                    passwordField(text: $appState.signUpDraft.password)
                }
                primaryAuthButton(title: "Create Account", systemImage: "arrow.right.circle.fill", isEnabled: appState.signUpDraft.password.count >= 6) {
                    appState.completeAuth()
                }
            }
        }
    }

    private var loginForm: some View {
        OnboardingLabsCard {
            VStack(alignment: .leading, spacing: 14) {
                labeledField(icon: "envelope.fill", title: "Email") {
                    field("Email", text: $loginEmail)
                }
                labeledField(icon: "lock.fill", title: "Password") {
                    passwordField(text: $loginPassword)
                }
                primaryAuthButton(title: "Sign In", systemImage: "arrow.right.circle.fill", isEnabled: !loginEmail.isEmpty && !loginPassword.isEmpty) {
                    appState.completeAuth()
                }
                Button {
                    authNotice = .forgotPassword
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Forgot password?")
                    }
                    .font(Theme.Typography.caption())
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func labeledField<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OnboardingLabsChrome.silverIconGradient)
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            }
            content()
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 10) {
            socialButton("Continue with Apple", icon: "apple.logo")
            socialButton("Continue with Google", icon: "globe")
        }
    }

    private func socialButton(_ title: String, icon: String) -> some View {
        Button {
            if title.contains("Apple") { authNotice = .socialApple }
            else { authNotice = .socialGoogle }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(OnboardingLabsChrome.silverIconGradient)
                    .frame(width: 36, height: 36)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay { Circle().strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1) }
                    }
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .fill(OnboardingLabsChrome.panelFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                            .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                    }
            }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private func primaryAuthButton(title: String, systemImage: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(Theme.Typography.headline())
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(Color.black.opacity(isEnabled ? 1 : 0.45))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .fill(Color.white.opacity(isEnabled ? 1 : 0.35))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
        .disabled(!isEnabled)
    }

    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .textInputAutocapitalization(.never)
            .padding(14)
            .foregroundStyle(Color.white.opacity(0.95))
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                            .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                    }
            }
    }

    private func passwordField(text: Binding<String>) -> some View {
        HStack {
            Group {
                if passwordVisible {
                    TextField("Password", text: text)
                } else {
                    SecureField("Password", text: text)
                }
            }
            Button {
                passwordVisible.toggle()
            } label: {
                Label(passwordVisible ? "Hide" : "Show", systemImage: passwordVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .labelStyle(.iconOnly)
                    .foregroundStyle(OnboardingLabsChrome.secondaryLabel)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .foregroundStyle(Color.white.opacity(0.95))
        .background {
            RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius, style: .continuous)
                        .strokeBorder(OnboardingLabsChrome.hairline, lineWidth: 1)
                }
        }
    }
}
