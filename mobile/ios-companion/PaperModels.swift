import Foundation

struct PaperPosition: Identifiable, Hashable {
    let id: String
    var symbol: String
    var costBasis: Double
    var netExposureBasis: Double
    var avgEntryPrice: Double
    var avgEntryMC: Double
    var quantity: Double
}

struct PaperTrade: Identifiable, Hashable {
    let id: String
    var type: String
    var symbol: String
    var usd: Double
    var marketCap: Double
    var realizedPnl: Double?
    var timestamp: Date
}

struct PaperAccountSnapshot {
    var cash: Double
    var startingBalance: Double
    var positions: [PaperPosition]
    var trades: [PaperTrade]

    static let empty = PaperAccountSnapshot(
        cash: 0,
        startingBalance: 0,
        positions: [],
        trades: []
    )
}
