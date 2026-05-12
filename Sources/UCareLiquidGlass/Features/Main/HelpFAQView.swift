import SwiftUI

struct HelpFAQView: View {
    @Environment(\.dismiss) private var dismiss

    private let items: [(String, String)] = [
        ("Is UCare medical advice?", "No. UCare is education and habit design. For diagnosis or treatment, see a licensed clinician."),
        ("What data leaves my phone?", "This build keeps protocol + check-ins on-device. Cloud sync, photos, and encrypted backups ship before we turn networking on."),
        ("Why does Glow-Up Score move?", "It blends recent step completion with your weekly self-ratings when you log them. Missing a check-in doesn’t auto-penalize you."),
        ("Subscriptions & trials", "Billing is through Apple. Manage or cancel in Settings → Subscriptions. Trial terms follow what you configure in App Store Connect."),
        ("Contact", "Support email placeholder: hello@ucare.app (wire your real inbox before launch)."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, row in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(row.0)
                                    .font(Theme.Typography.headline())
                                    .foregroundStyle(Theme.ColorToken.textPrimary)
                                Text(row.1)
                                    .font(Theme.Typography.caption())
                                    .foregroundStyle(Theme.ColorToken.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(Theme.Layout.contentHorizontalPadding)
            }
            .ucareScrollOnMesh()
            .navigationTitle("Help & FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
