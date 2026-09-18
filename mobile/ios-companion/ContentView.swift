import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PaperMadeStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TradeHomeView()
            }
            .tabItem { Label("Trade", systemImage: "chart.xyaxis.line") }
            .tag(0)

            NavigationStack {
                PositionsView()
            }
            .tabItem { Label("Positions", systemImage: "rectangle.stack") }
            .tag(1)

            NavigationStack {
                JournalView()
            }
            .tabItem { Label("Journal", systemImage: "book.closed") }
            .tag(2)

            NavigationStack {
                MoreView()
            }
            .tabItem { Label("More", systemImage: "ellipsis.circle") }
            .tag(3)
        }
        .tint(.green)
    }
}

private struct TradeHomeView: View {
    @EnvironmentObject var store: PaperMadeStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PaperMade Mobile")
                        .font(.system(size: 30, weight: .black))

                    Text("Real charts. Fake money. Better traders.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    StatCard(title: "AVAILABLE", value: store.snapshot.cash.formatted(.currency(code: "USD")))
                    StatCard(title: "INVESTED", value: store.totalInvested.formatted(.currency(code: "USD")))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Trade from Safari", systemImage: "safari")
                        .font(.headline)

                    Text("Open FOMO, Axiom, Pump.fun or GMGN in Safari. PaperMade appears as a small pill at the bottom of the page. Tap it to open the mobile paper-trading sheet.")
                        .foregroundStyle(.secondary)

                    Button {
                        if let url = URL(string: "https://papermade.xyz") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "safari")
                            Text("Open PaperMade in Safari")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Safari extension")
                            .font(.headline)
                        Spacer()
                        Text(store.isConnected ? "SYNCED" : "SETUP")
                            .font(.caption.bold())
                            .foregroundStyle(store.isConnected ? .green : .orange)
                    }

                    Label("Enable PaperMade in Safari Extensions", systemImage: "puzzlepiece.extension")
                    Label("Allow it on supported trading sites", systemImage: "checkmark.shield")
                    Label("Sign into the same PaperMade account", systemImage: "person.crop.circle.badge.checkmark")
                }
                .font(.subheadline)
                .padding()
                .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mobile alpha")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("Paper trading only. PaperMade Mobile does not require a seed phrase, private key, wallet custody or blockchain signing.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("Trade")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}
