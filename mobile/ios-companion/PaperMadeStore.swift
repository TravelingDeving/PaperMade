import Foundation
import SwiftUI

@MainActor
final class PaperMadeStore: ObservableObject {
    @Published var snapshot: PaperAccountSnapshot = .empty
    @Published var isConnected = false
    @Published var accountLabel = "Not connected"
    @Published var lastUpdated: Date?
    @Published var leaderboard: [LeaderboardRow] = []
    @Published var profile: PaperMadeProfile = .empty
    @Published var socialUpdatedAt: Date?
    @Published var nativeSyncPending = false

    init() {
        reloadSharedSnapshots()
    }

    var positions: [PaperPosition] {
        snapshot.positions.sorted { $0.costBasis > $1.costBasis }
    }

    var trades: [PaperTrade] {
        snapshot.trades.sorted { $0.timestamp > $1.timestamp }
    }

    var closedTrades: [ClosedPaperTrade] {
        snapshot.journal.sorted { $0.exitAt > $1.exitAt }
    }

    var totalInvested: Double {
        snapshot.positions.reduce(0) { $0 + $1.costBasis }
    }

    var totalRealizedPnl: Double {
        snapshot.journal.reduce(0) { $0 + $1.realizedPnl }
    }

    func reloadSharedSnapshots() {
        if let data = SharedPaperMadeBridge.paperStateData() {
            try? replaceFromStateJSON(data)
        }

        if let data = SharedPaperMadeBridge.syncStatusData() {
            parseSyncStatus(data)
        }

        if let data = SharedPaperMadeBridge.socialSnapshotData() {
            parseSocialSnapshot(data)
        }

        if let updated = SharedPaperMadeBridge.paperStateUpdatedAt() {
            lastUpdated = updated
        }

        socialUpdatedAt = SharedPaperMadeBridge.socialUpdatedAt()
        nativeSyncPending = SharedPaperMadeBridge.hasDirtyPaperState()
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

        var parsedJournal: [ClosedPaperTrade] = []
        if let journal = raw["journal"] as? [[String: Any]] {
            for (index, trade) in journal.enumerated() {
                let entryMs = number(trade["entryAt"])
                let exitMs = number(trade["exitAt"])
                let id = string(
                    trade["id"],
                    fallback: "\(Int(exitMs))-closed-\(index)"
                )

                parsedJournal.append(
                    ClosedPaperTrade(
                        id: id,
                        address: string(trade["address"]),
                        symbol: string(trade["symbol"], fallback: "TOKEN"),
                        chainId: string(trade["chainId"]),
                        entryAt: entryMs > 0 ? Date(timeIntervalSince1970: entryMs / 1000) : Date(),
                        exitAt: exitMs > 0 ? Date(timeIntervalSince1970: exitMs / 1000) : Date(),
                        holdMs: number(trade["holdMs"]),
                        avgEntryMC: number(trade["avgEntryMc"]),
                        exitMC: number(trade["exitMc"]),
                        highestMC: number(trade["highestMc"]),
                        lowestMC: number(trade["lowestMc"]),
                        maxPnlPercent: number(trade["maxPnlPercent"]),
                        minPnlPercent: number(trade["minPnlPercent"]),
                        totalCost: number(trade["totalCost"]),
                        totalProceeds: number(trade["totalProceeds"]),
                        realizedPnl: number(trade["realizedPnl"]),
                        returnPercent: number(trade["returnPercent"]),
                        capturedPercent: trade["capturedPercent"] == nil ? nil : number(trade["capturedPercent"])
                    )
                )
            }
        }

        var parsedCalendar: [String: CalendarDayLedger] = [:]
        if let calendar = raw["calendarDays"] as? [String: Any] {
            for (key, value) in calendar {
                guard let row = value as? [String: Any] else { continue }
                parsedCalendar[key] = CalendarDayLedger(
                    pnl: number(row["pnl"]),
                    trades: Int(number(row["trades"])),
                    wins: Int(number(row["wins"])),
                    losses: Int(number(row["losses"])),
                    bestReturn: row["bestReturn"] == nil ? nil : number(row["bestReturn"]),
                    worstReturn: row["worstReturn"] == nil ? nil : number(row["worstReturn"])
                )
            }
        }

        snapshot = PaperAccountSnapshot(
            cash: cash,
            startingBalance: startingBalance,
            positions: parsedPositions,
            trades: parsedTrades,
            journal: parsedJournal,
            calendarDays: parsedCalendar
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
        leaderboard = []
        profile = .empty
    }

    private func parseSyncStatus(_ data: Data) {
        guard
            let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        let connected = bool(raw["connected"])
        let approved = bool(raw["approved"])
        let discord = string(raw["discordUsername"])

        isConnected = connected && approved
        accountLabel = isConnected
            ? (discord.isEmpty ? "PaperMade" : discord)
            : approved ? "Signed in" : "Not connected"

        if !discord.isEmpty && profile.discordUsername.isEmpty {
            profile.discordUsername = discord
        }
    }

    private func parseSocialSnapshot(_ data: Data) {
        guard
            let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        if let profileContainer = raw["profile"] as? [String: Any] {
            let discord = string(profileContainer["discordUsername"])

            if let p = profileContainer["profile"] as? [String: Any] {
                profile = PaperMadeProfile(
                    discordUsername: discord,
                    displayName: string(p["display_name"]),
                    bio: string(p["bio"]),
                    favoriteChain: string(p["favorite_chain"]),
                    tradingStyle: string(p["trading_style"]),
                    xHandle: string(p["x_handle"]),
                    publicEnabled: bool(p["public_enabled"], fallback: true),
                    bannerPath: string(p["banner_path"]),
                    avatarPath: string(p["avatar_path"]),
                    badges: parseBadges(profileContainer["badges"])
                )
            } else {
                profile.discordUsername = discord
                profile.badges = parseBadges(profileContainer["badges"])
            }
        }

        if let rows = raw["leaderboard"] as? [[String: Any]] {
            leaderboard = rows.map { row in
                let username = string(row["discord_username"], fallback: "PaperMade Trader")
                return LeaderboardRow(
                    id: username.lowercased(),
                    rank: Int(number(row["rank"])),
                    discordUsername: username,
                    displayName: string(row["display_name"]),
                    realizedPnl: number(row["realized_pnl"]),
                    winRate: number(row["win_rate"]),
                    closedTrades: Int(number(row["closed_trades"])),
                    avgReturn: number(row["avg_return"]),
                    bestTrade: number(row["best_trade"]),
                    paperBalance: number(row["paper_balance"]),
                    isMe: bool(row["is_me"]) || (!profile.discordUsername.isEmpty && username.caseInsensitiveCompare(profile.discordUsername) == .orderedSame)
                )
            }
            .sorted { $0.rank < $1.rank }
        }
    }

    private func parseBadges(_ raw: Any?) -> [PaperMadeBadge] {
        guard let rows = raw as? [[String: Any]] else { return [] }

        return rows.map { row in
            let slug = string(row["slug"], fallback: UUID().uuidString)
            return PaperMadeBadge(
                id: slug,
                slug: slug,
                title: string(row["title"], fallback: "Badge"),
                description: string(row["description"]),
                rarity: string(row["rarity"], fallback: "common"),
                unlocked: bool(row["unlocked"]),
                featured: bool(row["featured"])
            )
        }
    }

    private func number(_ value: Any?, fallback: Double = 0) -> Double {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String, let d = Double(s) { return d }
        return fallback
    }

    private func bool(_ value: Any?, fallback: Bool = false) -> Bool {
        if let b = value as? Bool { return b }
        if let n = value as? NSNumber { return n.boolValue }
        if let s = value as? String {
            if s == "true" || s == "1" { return true }
            if s == "false" || s == "0" { return false }
        }
        return fallback
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let s = value as? String, !s.isEmpty { return s }
        return fallback
    }
}
