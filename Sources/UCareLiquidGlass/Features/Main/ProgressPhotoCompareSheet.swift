import SwiftUI
import UIKit

/// Swipeable before / after viewer for two saved weekly selfies (Phase 3).
struct ProgressPhotoCompareSheet: View {
    let beforeMonday: Date
    let afterMonday: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TabView {
                photoPage(title: "Before", monday: beforeMonday)
                photoPage(title: "After", monday: afterMonday)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(Theme.paperGradient.ignoresSafeArea())
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func photoPage(title: String, monday: Date) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(Theme.Typography.headline())
                .foregroundStyle(Theme.ColorToken.textSecondary)
            Text(monday, format: .dateTime.month().day().year())
                .font(Theme.Typography.caption())
                .foregroundStyle(Theme.ColorToken.textTertiary)
            if let data = WeeklyProgressPhotoStore.loadJPEGData(weekMonday: monday),
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Theme.ColorToken.glassStroke, lineWidth: 1)
                    }
                    .padding(.horizontal, 20)
            } else {
                Text("No photo for this week.")
                    .font(Theme.Typography.subheadline())
                    .foregroundStyle(Theme.ColorToken.textTertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 24)
    }
}
