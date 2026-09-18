import Foundation

@MainActor
final class EmbeddedTradingSession: ObservableObject {
    let site: TradingSite

    @Published var token: ResolvedMarketToken?
    @Published var status = "Open a token page."
    @Published var statusIsError = false
    @Published var sheetOpen = false
    @Published var lastPageURL: URL?

    init(site: TradingSite) {
        self.site = site
    }

    func updateToken(_ token: ResolvedMarketToken?) {
        self.token = token
        if token != nil {
            status = "Live paper market connected."
            statusIsError = false
        }
    }

    func updateStatus(_ text: String, error: Bool = false) {
        status = text
        statusIsError = error
    }
}
