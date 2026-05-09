import Foundation

struct DiscoverFeedRoot: Codable {
    var items: [DiscoverFeedItem]
}

struct DiscoverFeedItem: Codable, Identifiable {
    var category: String
    var title: String
    var summary: String

    var id: String { "\(category)|\(title)" }
}

enum DiscoverFeedLoader {
    static func loadItems() -> [DiscoverFeedItem] {
        guard let url = Bundle.main.url(forResource: "discover_feed", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONDecoder().decode(DiscoverFeedRoot.self, from: data)
        else { return [] }
        return root.items
    }
}
