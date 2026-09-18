import Foundation

struct LeaderboardRow: Identifiable, Hashable {
    let id: String
    var rank: Int
    var discordUsername: String
    var displayName: String
    var realizedPnl: Double
    var winRate: Double
    var closedTrades: Int
    var avgReturn: Double
    var bestTrade: Double
    var paperBalance: Double
    var isMe: Bool
}

struct PaperMadeBadge: Identifiable, Hashable {
    let id: String
    var slug: String
    var title: String
    var description: String
    var rarity: String
    var unlocked: Bool
    var featured: Bool
}

struct PaperMadeProfile: Hashable {
    var discordUsername: String
    var displayName: String
    var bio: String
    var favoriteChain: String
    var tradingStyle: String
    var xHandle: String
    var publicEnabled: Bool
    var bannerPath: String
    var avatarPath: String
    var badges: [PaperMadeBadge]

    static let empty = PaperMadeProfile(
        discordUsername: "",
        displayName: "",
        bio: "",
        favoriteChain: "",
        tradingStyle: "",
        xHandle: "",
        publicEnabled: true,
        bannerPath: "",
        avatarPath: "",
        badges: []
    )
}
