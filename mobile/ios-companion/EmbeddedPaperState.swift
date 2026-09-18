import Foundation

enum EmbeddedPaperState {
    static func currentDictionary() -> [String: Any] {
        guard
            let data = SharedPaperMadeBridge.paperStateData(),
            let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return [
                "cash": 100.0,
                "startingBalance": 100.0,
                "positions": [:],
                "trades": [],
                "journal": [],
                "calendarDays": [:]
            ]
        }

        var state = raw
        if state["positions"] == nil { state["positions"] = [String: Any]() }
        if state["trades"] == nil { state["trades"] = [[String: Any]]() }
        if state["journal"] == nil { state["journal"] = [[String: Any]]() }
        if state["calendarDays"] == nil { state["calendarDays"] = [String: Any]() }
        return state
    }

    static func write(_ state: [String: Any], markDirty: Bool = true) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: state)
        SharedPaperMadeBridge.writePaperState(data, markDirty: markDirty)
        return data
    }

    static func paperBuy(
        state: [String: Any],
        token: ResolvedMarketToken,
        spend: Double,
        now: Date = Date()
    ) throws -> [String: Any] {
        guard spend > 0 else { throw TradeError.invalidAmount }

        var next = state
        let cash = number(next["cash"])
        guard spend <= cash + 0.000_001 else { throw TradeError.insufficientPaperCash }

        var positions = next["positions"] as? [String: Any] ?? [:]
        var position = positions[token.address] as? [String: Any] ?? [:]

        let oldCost = number(position["costBasis"])
        let oldExposure = number(position["netExposureBasis"], fallback: oldCost)
        let oldQty = number(position["qty"])
        let newCost = oldCost + spend
        let newExposure = oldExposure + spend
        let qtyAdded = token.priceUsd > 0 ? spend / token.priceUsd : 0
        let newQty = oldQty + qtyAdded

        position["symbol"] = token.symbol
        position["chainId"] = token.chainId
        position["qty"] = newQty
        position["costBasis"] = newCost
        position["netExposureBasis"] = newExposure
        position["avgEntryPrice"] = newQty > 0 ? newExposure / newQty : 0
        position["avgEntryMc"] = newCost > 0
            ? ((number(position["avgEntryMc"]) * oldCost) + (token.marketCap * spend)) / newCost
            : token.marketCap
        position["firstEntryAt"] = number(position["firstEntryAt"]) > 0
            ? number(position["firstEntryAt"])
            : now.timeIntervalSince1970 * 1000
        position["highestMc"] = max(number(position["highestMc"]), token.marketCap)
        let oldLow = number(position["lowestMc"])
        position["lowestMc"] = oldLow > 0 ? min(oldLow, token.marketCap) : token.marketCap

        positions[token.address] = position
        next["positions"] = positions
        next["cash"] = cash - spend

        var trades = next["trades"] as? [[String: Any]] ?? []
        trades.append([
            "type": "BUY",
            "address": token.address,
            "symbol": token.symbol,
            "chainId": token.chainId,
            "usd": spend,
            "price": token.priceUsd,
            "marketCap": token.marketCap,
            "at": now.timeIntervalSince1970 * 1000,
            "source": "PaperMade iOS embedded"
        ])
        next["trades"] = trades

        return next
    }

    static func paperSell(
        state: [String: Any],
        token: ResolvedMarketToken,
        amountUsd: Double,
        now: Date = Date()
    ) throws -> [String: Any] {
        guard amountUsd > 0 else { throw TradeError.invalidAmount }

        var next = state
        var positions = next["positions"] as? [String: Any] ?? [:]
        guard var position = positions[token.address] as? [String: Any] else {
            throw TradeError.noPosition
        }

        let costBasis = number(position["costBasis"])
        let exposure = number(position["netExposureBasis"], fallback: costBasis)
        guard costBasis > 0, exposure > 0 else { throw TradeError.noPosition }

        var ratio = 1.0
        let avgMc = number(position["avgEntryMc"])
        let avgPrice = number(position["avgEntryPrice"])

        if token.marketCap > 0, avgMc > 0 {
            ratio = token.marketCap / avgMc
        } else if token.priceUsd > 0, avgPrice > 0 {
            ratio = token.priceUsd / avgPrice
        }
        if !ratio.isFinite || ratio <= 0 { ratio = 1 }

        let positionValue = exposure * ratio
        guard positionValue > 0 else { throw TradeError.noPosition }

        let requested = min(amountUsd, positionValue)
        let fraction = min(1, max(0, requested / positionValue))
        let hardClose = fraction >= 0.999_999

        let grossProceeds = hardClose ? positionValue : positionValue * fraction
        let costRemoved = hardClose ? costBasis : costBasis * fraction
        let exposureRemoved = hardClose ? exposure : exposure * fraction
        let qtyBefore = number(position["qty"])
        let qtySold = hardClose ? qtyBefore : qtyBefore * fraction
        let realized = grossProceeds - costRemoved

        next["cash"] = number(next["cash"]) + grossProceeds

        var trades = next["trades"] as? [[String: Any]] ?? []
        trades.append([
            "type": "SELL",
            "address": token.address,
            "symbol": token.symbol,
            "chainId": token.chainId,
            "usd": grossProceeds,
            "price": token.priceUsd,
            "marketCap": token.marketCap,
            "realizedPnl": realized,
            "at": now.timeIntervalSince1970 * 1000,
            "source": "PaperMade iOS embedded"
        ])
        next["trades"] = trades

        if hardClose {
            positions.removeValue(forKey: token.address)
            next["positions"] = positions

            let entryAtMs = number(position["firstEntryAt"])
            let exitAtMs = now.timeIntervalSince1970 * 1000
            let returnPercent = costBasis > 0 ? realized / costBasis * 100 : 0

            var journal = next["journal"] as? [[String: Any]] ?? []
            journal.append([
                "id": "\(Int(exitAtMs))-\(token.address)",
                "address": token.address,
                "symbol": token.symbol,
                "chainId": token.chainId,
                "entryAt": entryAtMs,
                "exitAt": exitAtMs,
                "holdMs": max(0, exitAtMs - entryAtMs),
                "avgEntryMc": avgMc,
                "exitMc": token.marketCap,
                "highestMc": max(number(position["highestMc"]), token.marketCap),
                "lowestMc": {
                    let low = number(position["lowestMc"])
                    return low > 0 ? min(low, token.marketCap) : token.marketCap
                }(),
                "maxPnlPercent": number(position["maxPnlPercent"]),
                "minPnlPercent": number(position["minPnlPercent"]),
                "totalCost": costBasis,
                "totalProceeds": grossProceeds,
                "realizedPnl": realized,
                "returnPercent": returnPercent
            ])
            next["journal"] = journal

            var calendar = next["calendarDays"] as? [String: Any] ?? [:]
            let key = dayKey(now)
            var row = calendar[key] as? [String: Any] ?? [:]
            let previousTrades = Int(number(row["trades"]))
            let previousWins = Int(number(row["wins"]))
            let previousLosses = Int(number(row["losses"]))
            let oldBest = optionalNumber(row["bestReturn"])
            let oldWorst = optionalNumber(row["worstReturn"])

            row["pnl"] = number(row["pnl"]) + realized
            row["trades"] = previousTrades + 1
            row["wins"] = previousWins + (realized > 0 ? 1 : 0)
            row["losses"] = previousLosses + (realized < 0 ? 1 : 0)
            row["bestReturn"] = oldBest.map { max($0, returnPercent) } ?? returnPercent
            row["worstReturn"] = oldWorst.map { min($0, returnPercent) } ?? returnPercent
            calendar[key] = row
            next["calendarDays"] = calendar
        } else {
            position["costBasis"] = max(0, costBasis - costRemoved)
            position["netExposureBasis"] = max(0, exposure - exposureRemoved)
            position["qty"] = max(0, qtyBefore - qtySold)
            positions[token.address] = position
            next["positions"] = positions
        }

        return next
    }

    static func positionMetrics(
        state: [String: Any],
        token: ResolvedMarketToken
    ) -> (invested: Double, value: Double, pnl: Double, pct: Double, avgEntryMc: Double) {
        let positions = state["positions"] as? [String: Any] ?? [:]
        guard let position = positions[token.address] as? [String: Any] else {
            return (0,0,0,0,0)
        }

        let cost = number(position["costBasis"])
        let exposure = number(position["netExposureBasis"], fallback: cost)
        let avgMc = number(position["avgEntryMc"])
        let avgPrice = number(position["avgEntryPrice"])

        var ratio = 1.0
        if token.marketCap > 0, avgMc > 0 {
            ratio = token.marketCap / avgMc
        } else if token.priceUsd > 0, avgPrice > 0 {
            ratio = token.priceUsd / avgPrice
        }
        if !ratio.isFinite || ratio <= 0 { ratio = 1 }

        let value = exposure * ratio
        let pnl = value - cost
        let pct = cost > 0 ? pnl / cost * 100 : 0
        return (cost, value, pnl, pct, avgMc)
    }

    private static func dayKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func number(_ value: Any?, fallback: Double = 0) -> Double {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String, let d = Double(s) { return d }
        return fallback
    }

    private static func optionalNumber(_ value: Any?) -> Double? {
        guard value != nil else { return nil }
        return number(value)
    }

    enum TradeError: LocalizedError {
        case invalidAmount
        case insufficientPaperCash
        case noPosition

        var errorDescription: String? {
            switch self {
            case .invalidAmount: return "Enter a paper amount above zero."
            case .insufficientPaperCash: return "Not enough paper cash."
            case .noPosition: return "No open paper position for this token."
            }
        }
    }
}
