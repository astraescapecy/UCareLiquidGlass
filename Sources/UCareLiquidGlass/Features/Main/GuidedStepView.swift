import Combine
import SwiftUI

struct GuidedStepView: View {
    let step: ProgramStep
    var onMarkDone: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var remaining: Int
    @State private var running = false

    init(step: ProgramStep, onMarkDone: @escaping () -> Void) {
        self.step = step
        self.onMarkDone = onMarkDone
        _remaining = State(initialValue: max(0, step.estimatedSeconds ?? 0))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(step.title)
                        .font(Theme.Typography.title())
                        .foregroundStyle(Theme.ColorToken.textPrimary)
                    Text(step.details)
                        .font(Theme.Typography.body())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                    if !step.scienceBlurb.isEmpty {
                        GlassCard {
                            Text(step.scienceBlurb)
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                        }
                    }
                    if let total = step.estimatedSeconds, total > 0 {
                        Text(timeString(from: remaining))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                            .frame(maxWidth: .infinity)
                        HStack(spacing: 12) {
                            Button(running ? "Pause" : "Start") {
                                running.toggle()
                            }
                            .buttonStyle(GlassCapsuleButtonStyle())
                            Button("Reset") {
                                running = false
                                remaining = total
                            }
                            .buttonStyle(GlassCapsuleButtonStyle())
                        }
                        .padding(.top, 8)
                    } else {
                        Text("No timer for this one — mark it when you’ve done the action.")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                }
                .padding(Theme.Layout.contentHorizontalPadding)
            }
            .ucareScrollOnMesh()
            .navigationTitle("Guided step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Mark complete") {
                        onMarkDone()
                        dismiss()
                    }
                }
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard running, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { running = false }
        }
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m == 0 { return "\(s)s" }
        return String(format: "%d:%02d", m, s)
    }
}
