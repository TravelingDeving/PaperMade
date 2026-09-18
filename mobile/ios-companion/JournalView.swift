import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: PaperMadeStore

    var body: some View {
        Group {
            if store.trades.isEmpty {
                ContentUnavailableView(
                    "No Paper Trades Yet",
                    systemImage: "book.closed",
                    description: Text("Your synced PaperMade buys and sells will show here.")
                )
            } else {
                List(store.trades) { trade in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("\(trade.type) $\(trade.symbol)")
                                .font(.headline)
                                .foregroundStyle(trade.type == "SELL" ? .red : .green)

                            Spacer()

                            Text(trade.usd.formatted(.currency(code: "USD")))
                                .font(.headline)
                        }

                        HStack {
                            Text(trade.timestamp, format: .dateTime.month(.abbreviated).day().hour().minute())
                            Spacer()
                            Text("MC \(compact(trade.marketCap))")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        if let pnl = trade.realizedPnl, trade.type == "SELL" {
                            HStack {
                                Text("Realized P&L")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(pnl.formatted(.currency(code: "USD").sign(strategy: .always())))
                                    .fontWeight(.bold)
                                    .foregroundStyle(pnl >= 0 ? .green : .red)
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Journal")
    }

    private func compact(_ value: Double) -> String {
        guard value > 0 else { return "—" }
        if value >= 1_000_000_000 { return String(format: "$%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "$%.2fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "$%.1fK", value / 1_000) }
        return value.formatted(.currency(code: "USD"))
    }
}
