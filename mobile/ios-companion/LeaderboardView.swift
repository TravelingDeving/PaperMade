import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var store: PaperMadeStore

    var body: some View {
        Group {
            if store.leaderboard.isEmpty {
                ContentUnavailableView(
                    "Leaderboard Not Loaded Yet",
                    systemImage: "trophy",
                    description: Text("Open PaperMade in Safari and visit More once while signed in. The extension will sync the latest leaderboard into the app.")
                )
            } else {
                List(store.leaderboard) { row in
                    HStack(spacing: 12) {
                        Text("#\(row.rank)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(row.rank <= 3 ? .green : .secondary)
                            .frame(width: 42, alignment: .leading)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 5) {
                                Text(row.displayName.isEmpty ? row.discordUsername : row.displayName)
                                    .font(.headline)
                                if row.isMe {
                                    Text("YOU")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.green)
                                }
                            }

                            Text("@\(row.discordUsername) • \(row.closedTrades) closed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 3) {
                            Text(row.realizedPnl.formatted(.currency(code: "USD").sign(strategy: .always())))
                                .font(.headline)
                                .foregroundStyle(row.realizedPnl >= 0 ? .green : .red)
                            Text("\(Int(row.winRate.rounded()))% WR")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Leaderboard")
        .task {
            store.reloadSharedSnapshots()
        }
    }
}
