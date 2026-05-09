import SwiftUI

/// V1.1 Discover placeholder — protocols, guides, and recipes (spec §6.5).
struct DiscoverLibraryView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [(String, String, String)] = [
        ("Protocols", "7-Day Smell Reset", "Structured stacks you can start when odor confidence dips."),
        ("Protocols", "Glow Skin in 14 Days", "Barrier-first cadence — no miracle claims, just consistency."),
        ("Ingredient guides", "Why pineapple shows up", "Enzymes, fiber, and what’s actually evidence-based vs lore."),
        ("Mini-courses", "Why you smell (and how to fix it)", "Hygiene, diet, sleep, and fabrics — short reads with sources."),
        ("Recipes", "Hydration-forward drinks", "Chlorophyll water, electrolyte basics, and when to skip trends."),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Discover ships in V1.1 — this is a preview of how the library will feel.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .listRowBackground(Color.clear)
                }
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.0.uppercased())
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        Text(row.1)
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text(row.2)
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.textSecondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white.opacity(0.04))
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
