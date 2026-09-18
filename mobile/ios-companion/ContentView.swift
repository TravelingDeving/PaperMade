import SwiftUI
import SafariServices

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack(spacing: 22) {
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(.green)

                    Text("PaperMade")
                        .font(.system(size: 34, weight: .black))

                    Text("Real charts. Fake money. Better traders.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Open Safari", systemImage: "safari")
                        Label("Enable PaperMade in Safari Extensions", systemImage: "puzzlepiece.extension")
                        Label("Allow PaperMade on supported trading sites", systemImage: "checkmark.shield")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                    Button("Open Safari Extension Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Spacer()
                }
                .padding()
                .navigationTitle("Mobile Setup")
            }
            .tabItem { Label("Trade", systemImage: "chart.xyaxis.line") }
            .tag(0)

            NavigationStack {
                PlaceholderView(title: "Positions", icon: "rectangle.stack")
            }
            .tabItem { Label("Positions", systemImage: "rectangle.stack") }
            .tag(1)

            NavigationStack {
                PlaceholderView(title: "Journal", icon: "book.closed")
            }
            .tabItem { Label("Journal", systemImage: "book.closed") }
            .tag(2)

            NavigationStack {
                PlaceholderView(title: "More", icon: "ellipsis.circle")
            }
            .tabItem { Label("More", systemImage: "ellipsis.circle") }
            .tag(3)
        }
        .tint(.green)
    }
}

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text(title)
                .font(.title2.bold())
            Text("PaperMade account sync will populate this screen in the next mobile milestone.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle(title)
    }
}
