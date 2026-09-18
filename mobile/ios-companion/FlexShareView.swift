import SwiftUI
import UIKit

struct FlexShareView: View {
    @EnvironmentObject var store: PaperMadeStore
    @State private var shareImage: UIImage?
    @State private var showShare = false

    private var realizedPnl: Double {
        store.trades.compactMap(\.realizedPnl).reduce(0, +)
    }

    private var closedTrades: Int {
        store.trades.filter { $0.type == "SELL" }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FlexCardView(
                    realizedPnl: realizedPnl,
                    closedTrades: closedTrades,
                    cash: store.snapshot.cash,
                    accountName: store.profile.displayName.isEmpty
                        ? (store.profile.discordUsername.isEmpty ? "PaperMade Trader" : store.profile.discordUsername)
                        : store.profile.displayName
                )
                .frame(height: 360)

                Button {
                    makeAndShare()
                } label: {
                    Label("Share P&L Card", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Link(destination: URL(string: "https://papermade.xyz/flex.html")!) {
                    Label("Open Video Flex Studio", systemImage: "video")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Text("Image flex cards are generated natively in the app. The existing PaperMade video Flex Studio remains available for custom background videos and MP4 export while we port that renderer to iOS.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Flex Studio")
        .sheet(isPresented: $showShare) {
            if let shareImage {
                ActivityView(activityItems: [shareImage])
            }
        }
    }

    @MainActor
    private func makeAndShare() {
        let view = FlexCardView(
            realizedPnl: realizedPnl,
            closedTrades: closedTrades,
            cash: store.snapshot.cash,
            accountName: store.profile.displayName.isEmpty
                ? (store.profile.discordUsername.isEmpty ? "PaperMade Trader" : store.profile.discordUsername)
                : store.profile.displayName
        )
        .frame(width: 1080, height: 1350)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        shareImage = renderer.uiImage
        showShare = shareImage != nil
    }
}

private struct FlexCardView: View {
    let realizedPnl: Double
    let closedTrades: Int
    let cash: Double
    let accountName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.green.opacity(0.20), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("PAPERMADE")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.green)
                        Text("REAL CHARTS. FAKE MONEY.")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("SIMULATED")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(accountName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white.opacity(0.86))

                Text(realizedPnl.formatted(.currency(code: "USD").sign(strategy: .always())))
                    .font(.system(size: 62, weight: .black))
                    .foregroundStyle(realizedPnl >= 0 ? .green : .red)
                    .minimumScaleFactor(0.6)

                Text("REALIZED PAPER P&L")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.secondary)

                HStack(spacing: 18) {
                    miniMetric("CLOSED TRADES", "\(closedTrades)")
                    miniMetric("PAPER BALANCE", cash.formatted(.currency(code: "USD")))
                }

                Spacer()

                Text("Simulated results • papermade.xyz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.green.opacity(0.32), lineWidth: 1)
        }
    }

    private func miniMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(.white)
        }
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
