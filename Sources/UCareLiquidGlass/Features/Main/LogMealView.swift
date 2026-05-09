import SwiftUI

struct LogMealView: View {
    @State private var query = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions").font(Theme.Typography.largeTitle()).foregroundStyle(Theme.ColorToken.textPrimary)
            TextField("Search habits or notes", text: $query)
                .padding().background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
            GlassCard { Text("Quick add a custom step, note, or reminder for today.").foregroundStyle(Theme.ColorToken.textSecondary) }
            Spacer()
        }
        .padding(Theme.Layout.contentHorizontalPadding)
    }
}
