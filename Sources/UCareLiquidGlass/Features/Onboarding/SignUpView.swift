import SwiftUI

struct SignUpView: View {
    enum Mode { case signUp, signIn }
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var mode: Mode = .signUp
    @State private var passwordVisible = false
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var entered = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Button {
                        appState.phase = .getStarted
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.regularMaterial))
                    }
                    .buttonStyle(GlassCapsuleButtonStyle())
                    Spacer()
                }
                modeToggle
                if mode == .signUp { signUpForm } else { loginForm }
                socialButtons
            }
            .padding(.horizontal, Theme.Layout.contentHorizontalPadding)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .opacity(entered ? 1 : 0)
            .offset(y: entered ? 0 : 16)
        }
        .onAppear {
            withAnimation(LLGAnimation.entrance(reduceMotion: reduceMotion)) { entered = true }
        }
    }

    private var modeToggle: some View {
        HStack(spacing: 8) {
            toggleButton("Create Account", .signUp)
            toggleButton("Sign In", .signIn)
        }
        .padding(4)
        .background(Capsule().fill(.regularMaterial))
        .overlay { Capsule().strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1) }
    }

    private func toggleButton(_ title: String, _ value: Mode) -> some View {
        let on = mode == value
        return Button {
            withAnimation(LLGAnimation.screenSpring(reduceMotion: reduceMotion)) { mode = value }
        } label: {
            Text(title)
                .font(Theme.Typography.subheadline())
                .foregroundStyle(on ? Theme.ColorToken.textPrimary : Theme.ColorToken.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(on ? AnyShapeStyle(Theme.ctaGradient.opacity(0.45)) : AnyShapeStyle(Color.clear))
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var signUpForm: some View {
        GlassCard {
            VStack(spacing: 12) {
                field("Full Name", text: $appState.signUpDraft.fullName)
                field("Email", text: $appState.signUpDraft.email)
                passwordField(text: $appState.signUpDraft.password)
                GradientCTAButton(title: "Create Account", isEnabled: appState.signUpDraft.password.count >= 6) {
                    appState.completeAuth()
                }
            }
        }
    }

    private var loginForm: some View {
        GlassCard {
            VStack(spacing: 12) {
                field("Email", text: $loginEmail)
                passwordField(text: $loginPassword)
                GradientCTAButton(title: "Sign In", isEnabled: !loginEmail.isEmpty && !loginPassword.isEmpty) {
                    appState.completeAuth()
                }
                Button("Forgot password?") { }
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.ColorToken.textSecondary)
            }
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 10) {
            socialButton("Continue with Apple", icon: "apple.logo")
            socialButton("Continue with Google", icon: "globe")
        }
    }

    private func socialButton(_ title: String, icon: String) -> some View {
        Button { } label: {
            HStack {
                Image(systemName: icon)
                Text(title).font(Theme.Typography.subheadline())
                Spacer()
            }
            .foregroundStyle(Theme.ColorToken.textPrimary)
            .padding()
            .background(RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).fill(.regularMaterial))
            .overlay { RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1) }
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .textInputAutocapitalization(.never)
            .padding()
            .foregroundStyle(Theme.ColorToken.textPrimary)
            .background(RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).fill(.regularMaterial))
            .overlay { RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).strokeBorder(Theme.ColorToken.glassStrokeFocus, lineWidth: 1) }
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
            Button(passwordVisible ? "Hide" : "Show") { passwordVisible.toggle() }
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textSecondary)
        }
        .padding()
        .foregroundStyle(Theme.ColorToken.textPrimary)
        .background(RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).fill(.regularMaterial))
        .overlay { RoundedRectangle(cornerRadius: Theme.Layout.fieldCornerRadius).strokeBorder(Theme.ColorToken.glassStrokeFocus, lineWidth: 1) }
    }
}
