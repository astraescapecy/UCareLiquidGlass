import SwiftUI

/// Discover library — items loaded from bundled `discover_feed.json` (Phase 3).
struct DiscoverLibraryView: View {
    @Environment(\.dismiss) private var dismiss

    private var items: [DiscoverFeedItem] {
        let loaded = DiscoverFeedLoader.loadItems()
        if !loaded.isEmpty { return loaded }
        return [
            DiscoverFeedItem(category: "Protocols", title: "7-Day Smell Reset", summary: "Offline fallback — add discover_feed.json to the app bundle."),
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Curated reads and stacks — local JSON for now; cloud sync can land later.")
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.ColorToken.textSecondary)
                        .listRowBackground(Color.clear)
                }
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.category.uppercased())
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.ColorToken.accentTerracotta)
                        Text(item.title)
                            .font(Theme.Typography.headline())
                            .foregroundStyle(Theme.ColorToken.textPrimary)
                        Text(item.summary)
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
