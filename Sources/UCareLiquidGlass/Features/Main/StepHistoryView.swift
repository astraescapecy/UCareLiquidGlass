import SwiftUI

struct StepHistoryView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if appState.completionHistory().isEmpty {
                    Text("No completed steps logged yet — your Today tab writes history as you check things off.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(Array(appState.completionHistory().enumerated()), id: \.offset) { _, row in
                        HStack {
                            Text(row.date, format: .dateTime.month().day().year())
                            Spacer()
                            Text("\(row.count) step\(row.count == 1 ? "" : "s")")
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Step history")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
