import SwiftUI

struct PositionsView: View {
    @EnvironmentObject var store: PaperMadeStore

    var body: some View {
        Group {
            if store.positions.isEmpty {
                ContentUnavailableView(
                    "No Open Positions",
                    systemImage: "rectangle.stack",
                    description: Text("Paper positions from your synced PaperMade account will appear here.")
                )
            } else {
                List(store.positions) { position in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("$\(position.symbol)")
                                .font(.headline)
                            Spacer()
                            Text(currency(position.costBasis))
                                .font(.headline)
                        }

                        HStack {
                            metric("Invested", currency(position.costBasis))
                            Spacer()
                            metric("Avg Buy MC", compact(position.avgEntryMC))
                        }

                        Text(shortAddress(position.id))
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Positions")
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
    }

    private func currency(_ value: Double) -> String {
        value.formatted(.currency(code: "USD"))
    }

    private func compact(_ value: Double) -> String {
        guard value > 0 else { return "—" }
        if value >= 1_000_000_000 { return String(format: "$%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "$%.2fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "$%.1fK", value / 1_000) }
        return currency(value)
    }

    private func shortAddress(_ value: String) -> String {
        guard value.count > 12 else { return value }
        return "\(value.prefix(6))…\(value.suffix(5))"
    }
}
