import Foundation

struct TradingSite: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL
    let systemImage: String
    let embeddedPriority: Bool

    static let fomo = TradingSite(
        id: "fomo",
        name: "FOMO",
        url: URL(string: "https://fomo.family/")!,
        systemImage: "bolt.fill",
        embeddedPriority: true
    )

    static let axiom = TradingSite(
        id: "axiom",
        name: "Axiom",
        url: URL(string: "https://axiom.trade/")!,
        systemImage: "waveform.path.ecg",
        embeddedPriority: false
    )

    static let pump = TradingSite(
        id: "pump",
        name: "Pump.fun",
        url: URL(string: "https://pump.fun/")!,
        systemImage: "arrow.up.right.circle.fill",
        embeddedPriority: false
    )

    static let gmgn = TradingSite(
        id: "gmgn",
        name: "GMGN",
        url: URL(string: "https://gmgn.ai/")!,
        systemImage: "chart.line.uptrend.xyaxis",
        embeddedPriority: false
    )

    static let all: [TradingSite] = [.fomo, .axiom, .pump, .gmgn]
}
