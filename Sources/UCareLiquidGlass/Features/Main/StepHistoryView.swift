import SwiftUI

struct StepHistoryView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var grouped: [(date: Date, rows: [(stepId: String, title: String)])] {
        let events = appState.completedStepEvents(limit: 1_000)
        let dict = Dictionary(grouping: events, by: \.date)
        return dict.keys.sorted { $0 > $1 }.map { date in
            let rows = dict[date]!.map { (stepId: $0.stepId, title: $0.title) }
            return (date: date, rows: rows.sorted { $0.title < $1.title })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if grouped.isEmpty {
                    Text("No completed steps yet — check things off on Today and they’ll show up here with titles from your current program.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(grouped, id: \.date) { section in
                        Section {
                            ForEach(section.rows, id: \.stepId) { row in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.ColorToken.success)
                                        .font(.system(size: 16, weight: .semibold))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.title)
                                            .font(Theme.Typography.subheadline())
                                            .foregroundStyle(Theme.ColorToken.textPrimary)
                                        Text(row.stepId)
                                            .font(Theme.Typography.caption())
                                            .foregroundStyle(Theme.ColorToken.textTertiary)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .listRowBackground(Color.white.opacity(0.04))
                            }
                        } header: {
                            Text(section.date, format: .dateTime.weekday(.wide).month().day().year())
                                .font(Theme.Typography.caption())
                                .foregroundStyle(Theme.ColorToken.textSecondary)
                        }
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
