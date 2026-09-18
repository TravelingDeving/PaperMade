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

struct ClosedPaperTrade: Identifiable, Hashable {
    let id: String
    var address: String
    var symbol: String
    var chainId: String
    var entryAt: Date
    var exitAt: Date
    var holdMs: Double
    var avgEntryMC: Double
    var exitMC: Double
    var highestMC: Double
    var lowestMC: Double
    var maxPnlPercent: Double
    var minPnlPercent: Double
    var totalCost: Double
    var totalProceeds: Double
    var realizedPnl: Double
    var returnPercent: Double
    var capturedPercent: Double?
}

struct CalendarDayLedger: Hashable {
    var pnl: Double
    var trades: Int
    var wins: Int
    var losses: Int
    var bestReturn: Double?
    var worstReturn: Double?
}

struct PaperAccountSnapshot {
    var cash: Double
    var startingBalance: Double
    var positions: [PaperPosition]
    var trades: [PaperTrade]
    var journal: [ClosedPaperTrade]
    var calendarDays: [String: CalendarDayLedger]

    static let empty = PaperAccountSnapshot(
        cash: 0,
        startingBalance: 0,
        positions: [],
        trades: [],
        journal: [],
        calendarDays: [:]
    )
}
