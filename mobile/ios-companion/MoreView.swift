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
                        Text(store.isConnected ? "Paper state sync enabled" : "Sign in to sync desktop and mobile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Circle()
                        .fill(store.isConnected ? Color.green : Color.secondary)
                        .frame(width: 9, height: 9)
                }
            }

            Section("PaperMade") {
                Link("P&L Calendar", destination: URL(string: "https://papermade.xyz/calendar.html")!)
                Link("Leaderboard", destination: URL(string: "https://papermade.xyz/leaderboard.html")!)
                Link("Flex Studio", destination: URL(string: "https://papermade.xyz/flex.html")!)
                Link("Profile", destination: URL(string: "https://papermade.xyz/profile.html")!)
            }

            Section("Safety") {
                Label("Paper trading only", systemImage: "checkmark.shield")
                Label("No seed phrase or private key", systemImage: "key.slash")
                Label("No blockchain signing", systemImage: "signature")
            }
        }
        .navigationTitle("More")
    }
}
