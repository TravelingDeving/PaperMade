import Foundation
import SwiftUI

@MainActor
final class PaperMadeStore: ObservableObject {
    @Published var snapshot: PaperAccountSnapshot = .empty
    @Published var isConnected = false
    @Published var accountLabel = "Not connected"
    @Published var lastUpdated: Date?

    var positions: [PaperPosition] {
        snapshot.positions.sorted { $0.costBasis > $1.costBasis }
    }

    var trades: [PaperTrade] {
        snapshot.trades.sorted { $0.timestamp > $1.timestamp }
    }

    var totalInvested: Double {
        snapshot.positions.reduce(0) { $0 + $1.costBasis }
    }

    func replaceFromStateJSON(_ json: Data) throws {
        let raw = try JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]

        let cash = number(raw["cash"])
        let startingBalance = number(raw["startingBalance"])

        var parsedPositions: [PaperPosition] = []
        if let positions = raw["positions"] as? [String: Any] {
            for (address, value) in positions {
                guard let pos = value as? [String: Any] else { continue }
                let cost = number(pos["costBasis"])
                guard cost > 0 else { continue }

                parsedPositions.append(
                    PaperPosition(
                        id: address,
                        symbol: string(pos["symbol"], fallback: "TOKEN"),
                        costBasis: cost,
                        netExposureBasis: number(pos["netExposureBasis"], fallback: cost),
                        avgEntryPrice: number(pos["avgEntryPrice"]),
                        avgEntryMC: number(pos["avgEntryMc"]),
                        quantity: number(pos["qty"])
                    )
                )
            }
        }

        var parsedTrades: [PaperTrade] = []
        if let trades = raw["trades"] as? [[String: Any]] {
            for (index, trade) in trades.enumerated() {
                let atMs = number(trade["at"])
                let at = atMs > 0 ? Date(timeIntervalSince1970: atMs / 1000) : Date()

                parsedTrades.append(
                    PaperTrade(
                        id: "\(Int(atMs))-\(index)-\(string(trade["type"], fallback: "TRADE"))",
                        type: string(trade["type"], fallback: "TRADE").uppercased(),
                        symbol: string(trade["symbol"], fallback: "TOKEN"),
                        usd: number(trade["usd"]),
                        marketCap: number(trade["marketCap"]),
                        realizedPnl: trade["realizedPnl"] == nil ? nil : number(trade["realizedPnl"]),
                        timestamp: at
                    )
                )
            }
        }

        snapshot = PaperAccountSnapshot(
            cash: cash,
            startingBalance: startingBalance,
            positions: parsedPositions,
            trades: parsedTrades
        )
        lastUpdated = Date()
    }

    func markConnected(label: String) {
        isConnected = true
        accountLabel = label
    }

    func markDisconnected() {
        isConnected = false
        accountLabel = "Not connected"
        snapshot = .empty
    }

    private func number(_ value: Any?, fallback: Double = 0) -> Double {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String, let d = Double(s) { return d }
        return fallback
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let s = value as? String, !s.isEmpty { return s }
        return fallback
    }
}
