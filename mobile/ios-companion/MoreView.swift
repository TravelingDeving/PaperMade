import SwiftUI

struct MoreView: View {
    @EnvironmentObject var store: PaperMadeStore

    var body: some View {
        List {
            Section("Account") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.accountLabel)
                            .fontWeight(.semibold)
                        Text(store.isConnected ? "Paper state sync enabled" : "Sign in through PaperMade in Safari to sync desktop and mobile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Circle()
                        .fill(store.isConnected ? Color.green : Color.secondary)
                        .frame(width: 9, height: 9)
                }

                Button("Refresh Shared Data") {
                    store.reloadSharedSnapshots()
                }
            }

            Section("PaperMade") {
                NavigationLink("P&L Calendar") {
                    CalendarView()
                }
                NavigationLink("Leaderboard") {
                    LeaderboardView()
                }
                NavigationLink("Flex Studio") {
                    FlexShareView()
                }
                NavigationLink("Profile") {
                    ProfileView()
                }
            }

            Section("Safety") {
                Label("Paper trading only", systemImage: "checkmark.shield")
                Label("No seed phrase or private key", systemImage: "key.slash")
                Label("No blockchain signing", systemImage: "signature")
            }
        }
        .navigationTitle("More")
        .task {
            store.reloadSharedSnapshots()
        }
    }
}
