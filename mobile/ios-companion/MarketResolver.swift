import Foundation

struct ResolvedMarketToken: Hashable {
    let address: String
    let symbol: String
    let name: String
    let chainId: String
    let priceUsd: Double
    let marketCap: Double
    let liquidityUsd: Double
    let pairAddress: String
}

actor MarketResolver {
    private let commonQuotes = Set(["SOL","WSOL","ETH","WETH","BNB","WBNB","USDC","USDT","USDS","DAI"])

    func tokenAddress(from url: URL?) -> String? {
        guard let url else { return nil }
        let text = url.absoluteString.removingPercentEncoding ?? url.absoluteString

        if let range = text.range(of: #"0x[a-fA-F0-9]{40}"#, options: .regularExpression) {
            return String(text[range])
        }

        let separators = CharacterSet(charactersIn: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz").inverted
        let parts = text.components(separatedBy: separators).filter { !$0.isEmpty }
        return parts.first(where: {
            $0.count >= 32 &&
            $0.count <= 44 &&
            $0.range(of: #"^[1-9A-HJ-NP-Za-km-z]+$"#, options: .regularExpression) != nil
        })
    }

    func resolve(address: String) async throws -> ResolvedMarketToken {
        var pairs = try await fetchPairs(
            URL(string: "https://api.dexscreener.com/latest/dex/tokens/\(address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? address)")!
        )

        if pairs.isEmpty {
            let escaped = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
            let searched = try await fetchPairs(URL(string: "https://api.dexscreener.com/latest/dex/search?q=\(escaped)")!)
            guard let pair = bestPair(in: searched, exactPairAddress: address) else {
                throw ResolverError.noMarket
            }

            let side = chooseSide(pair)
            let resolved = token(from: pair, side: side)

            if !resolved.address.isEmpty, resolved.address.caseInsensitiveCompare(address) != .orderedSame {
                pairs = try await fetchPairs(
                    URL(string: "https://api.dexscreener.com/latest/dex/tokens/\(resolved.address)")!
                )
                if let best = bestPair(in: pairs) {
                    let bestSide = baseAddress(best).caseInsensitiveCompare(resolved.address) == .orderedSame ? "base" : "quote"
                    return token(from: best, side: bestSide)
                }
            }
            return resolved
        }

        guard let best = bestPair(in: pairs) else {
            throw ResolverError.noMarket
        }

        let side = baseAddress(best).caseInsensitiveCompare(address) == .orderedSame
            ? "base"
            : chooseSide(best)

        return token(from: best, side: side)
    }

    private func fetchPairs(_ url: URL) async throws -> [[String: Any]] {
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("PaperMade-Mobile/0.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ResolverError.badResponse
        }

        let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return root?["pairs"] as? [[String: Any]] ?? []
    }

    private func bestPair(in pairs: [[String: Any]], exactPairAddress: String? = nil) -> [String: Any]? {
        if let exactPairAddress {
            if let exact = pairs.first(where: {
                string($0["pairAddress"]).caseInsensitiveCompare(exactPairAddress) == .orderedSame
            }) {
                return exact
            }
        }

        return pairs.max {
            liquidity($0) < liquidity($1)
        }
    }

    private func chooseSide(_ pair: [String: Any]) -> String {
        let base = symbol(pair["baseToken"])
        let quote = symbol(pair["quoteToken"])
        if commonQuotes.contains(base) && !commonQuotes.contains(quote) {
            return "quote"
        }
        return "base"
    }

    private func token(from pair: [String: Any], side: String) -> ResolvedMarketToken {
        let token = (pair[side == "quote" ? "quoteToken" : "baseToken"] as? [String: Any]) ?? [:]
        let liquidityObject = pair["liquidity"] as? [String: Any] ?? [:]

        return ResolvedMarketToken(
            address: string(token["address"]),
            symbol: string(token["symbol"], fallback: "TOKEN"),
            name: string(token["name"], fallback: "Unknown token"),
            chainId: string(pair["chainId"]),
            priceUsd: number(pair["priceUsd"]),
            marketCap: max(number(pair["marketCap"]), number(pair["fdv"])),
            liquidityUsd: number(liquidityObject["usd"]),
            pairAddress: string(pair["pairAddress"])
        )
    }

    private func baseAddress(_ pair: [String: Any]) -> String {
        let token = pair["baseToken"] as? [String: Any] ?? [:]
        return string(token["address"])
    }

    private func symbol(_ raw: Any?) -> String {
        let token = raw as? [String: Any] ?? [:]
        return string(token["symbol"]).uppercased()
    }

    private func liquidity(_ pair: [String: Any]) -> Double {
        let object = pair["liquidity"] as? [String: Any] ?? [:]
        return number(object["usd"])
    }

    private func number(_ value: Any?) -> Double {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String, let d = Double(s) { return d }
        return 0
    }

    private func string(_ value: Any?, fallback: String = "") -> String {
        if let s = value as? String, !s.isEmpty { return s }
        return fallback
    }

    enum ResolverError: Error {
        case noMarket
        case badResponse
    }
}
