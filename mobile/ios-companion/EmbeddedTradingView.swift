import SwiftUI
import WebKit

struct EmbeddedTradingView: View {
    @EnvironmentObject var store: PaperMadeStore
    let site: TradingSite
    @StateObject private var session: EmbeddedTradingSession

    init(site: TradingSite) {
        self.site = site
        _session = StateObject(wrappedValue: EmbeddedTradingSession(site: site))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            EmbeddedTradingWebView(site: site, session: session)
                .ignoresSafeArea(edges: .bottom)

            if session.sheetOpen {
                EmbeddedPaperSheet(session: session)
                    .environmentObject(store)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                EmbeddedPaperPill(session: session)
                    .environmentObject(store)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: session.sheetOpen)
        .navigationTitle(site.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIApplication.shared.open(site.url)
                } label: {
                    Image(systemName: "safari")
                }
                .accessibilityLabel("Open in Safari")
            }
        }
    }
}

private struct EmbeddedPaperPill: View {
    @EnvironmentObject var store: PaperMadeStore
    @ObservedObject var session: EmbeddedTradingSession

    private var metrics: (invested: Double, value: Double, pnl: Double, pct: Double, avgEntryMc: Double) {
        guard let token = session.token else { return (0,0,0,0,0) }
        return EmbeddedPaperState.positionMetrics(
            state: EmbeddedPaperState.currentDictionary(),
            token: token
        )
    }

    var body: some View {
        Button {
            session.sheetOpen = true
        } label: {
            HStack(spacing: 8) {
                Text("P")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.green)
                    .frame(width: 27, height: 27)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 1)
                    }

                Text(session.token.map { "$\($0.symbol)" } ?? "PaperMade")
                    .font(.subheadline.bold())

                Text(metrics.invested > 0
                     ? percent(metrics.pct)
                     : "PAPER")
                    .font(.caption.bold())
                    .foregroundStyle(metrics.pnl >= 0 ? .green : .red)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.black.opacity(0.94), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.green.opacity(0.45), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.45), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func percent(_ value: Double) -> String {
        String(format: "%+.2f%%", value)
    }
}

private struct EmbeddedPaperSheet: View {
    @EnvironmentObject var store: PaperMadeStore
    @ObservedObject var session: EmbeddedTradingSession

    @State private var mode: Mode = .buy
    @State private var amount = ""

    enum Mode {
        case buy
        case sell
    }

    private var state: [String: Any] {
        EmbeddedPaperState.currentDictionary()
    }

    private var cash: Double {
        if let n = state["cash"] as? NSNumber { return n.doubleValue }
        if let s = state["cash"] as? String, let d = Double(s) { return d }
        return store.snapshot.cash
    }

    private var metrics: (invested: Double, value: Double, pnl: Double, pct: Double, avgEntryMc: Double) {
        guard let token = session.token else { return (0,0,0,0,0) }
        return EmbeddedPaperState.positionMetrics(state: state, token: token)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                session.sheetOpen = false
            } label: {
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 48, height: 5)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            ScrollView {
                VStack(spacing: 10) {
                    header
                    stats
                    pnlCard
                    buySellTabs
                    amountField
                    quickButtons
                    actionRow
                    tradeButton

                    Text(session.status)
                        .font(.caption2)
                        .foregroundStyle(session.statusIsError ? .red : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.72)
        .background(
            Color(red: 0.027, green: 0.063, blue: 0.039)
                .ignoresSafeArea()
        )
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 24,
            topTrailingRadius: 24
        ))
        .overlay(alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                topTrailingRadius: 24
            )
            .stroke(Color.green.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.6), radius: 28, y: -10)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.token.map { "$\($0.symbol)" } ?? "TOKEN")
                        .font(.title3.bold())
                    Text(session.token?.chainId ?? "detecting")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }

                Text(shortAddress(session.token?.address))
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("\(money(cash)) available")
                    .font(.subheadline.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green.opacity(0.22), lineWidth: 1)
                    }

                Text("LIVE")
                    .font(.caption2.bold())
                    .foregroundStyle(.green)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 7)
                    .overlay {
                        Capsule()
                            .stroke(Color.green.opacity(0.45), lineWidth: 1)
                    }
            }
        }
    }

    private var stats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            sheetStat("PRICE", price(session.token?.priceUsd ?? 0))
            sheetStat("MARKET CAP", compact(session.token?.marketCap ?? 0))
            sheetStat("LIQUIDITY", compact(session.token?.liquidityUsd ?? 0))
            sheetStat("INVESTED", money(metrics.invested))
            sheetStat("POSITION VALUE", money(metrics.value))
            sheetStat("AVG BUY MC", compact(metrics.avgEntryMc))
        }
    }

    private var pnlCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("OPEN P&L")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)

            Text("\(signedMoney(metrics.pnl))  \(percent(metrics.pct))")
                .font(.title3.bold())
                .foregroundStyle(metrics.pnl >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var buySellTabs: some View {
        HStack(spacing: 8) {
            tabButton("Buy", mode: .buy, tint: .green)
            tabButton("Sell", mode: .sell, tint: .red)
        }
    }

    private var amountField: some View {
        HStack(spacing: 7) {
            Text("$")
                .font(.title)
                .foregroundStyle(.secondary)

            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .font(.title.bold())

            Text("Amount")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var quickButtons: some View {
        let values = mode == .buy ? [3, 5, 10, 15] : [25, 50, 75, 100]

        return HStack(spacing: 7) {
            ForEach(values, id: \.self) { value in
                Button {
                    if mode == .buy {
                        amount = String(value)
                    } else {
                        amount = String(format: "%.2f", metrics.value * (Double(value) / 100))
                    }
                } label: {
                    Text(mode == .buy ? "$\(value)" : "\(value)%")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var actionRow: some View {
        HStack {
            Label("Paper only", systemImage: "checkmark.shield")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Max") {
                amount = String(format: "%.2f", mode == .buy ? cash : metrics.value)
            }
            .font(.caption.bold())
            .foregroundStyle(.green)
        }
    }

    private var tradeButton: some View {
        Button {
            executeTrade()
        } label: {
            Text(mode == .buy
                 ? "Paper Buy \(session.token.map { "$\($0.symbol)" } ?? "")"
                 : "Paper Sell \(session.token.map { "$\($0.symbol)" } ?? "")")
                .font(.headline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(mode == .buy ? .green : .red)
        .background(
            (mode == .buy ? Color.green : Color.red).opacity(0.12),
            in: RoundedRectangle(cornerRadius: 13)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke((mode == .buy ? Color.green : Color.red).opacity(0.7), lineWidth: 1)
        }
    }

    private func tabButton(_ title: String, mode target: Mode, tint: Color) -> some View {
        Button {
            mode = target
        } label: {
            Text(title)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .foregroundStyle(mode == target ? tint : .secondary)
        .background(
            mode == target ? tint.opacity(0.12) : Color.white.opacity(0.035),
            in: RoundedRectangle(cornerRadius: 11)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 11)
                .stroke(mode == target ? tint.opacity(0.65) : Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func sheetStat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.bold())
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        }
    }

    private func executeTrade() {
        guard let token = session.token else {
            session.updateStatus("Open a supported token page first.", error: true)
            return
        }

        guard let amountValue = Double(amount), amountValue > 0 else {
            session.updateStatus("Enter a paper amount above zero.", error: true)
            return
        }

        do {
            var raw = EmbeddedPaperState.currentDictionary()

            if mode == .sell {
                raw = try EmbeddedPaperState.paperSell(
                    state: raw,
                    token: token,
                    amountUsd: amountValue
                )
            } else {
                raw = try EmbeddedPaperState.paperBuy(
                    state: raw,
                    token: token,
                    spend: amountValue
                )
            }

            let data = try EmbeddedPaperState.write(raw)
            try store.replaceFromStateJSON(data)
            store.reloadSharedSnapshots()
            amount = ""
            session.updateStatus(mode == .sell ? "Paper sell filled." : "Paper buy filled.")
        } catch {
            session.updateStatus((error as? LocalizedError)?.errorDescription ?? error.localizedDescription, error: true)
        }
    }

    private func money(_ value: Double) -> String {
        value.formatted(.currency(code: "USD"))
    }

    private func signedMoney(_ value: Double) -> String {
        value.formatted(.currency(code: "USD").sign(strategy: .always()))
    }

    private func percent(_ value: Double) -> String {
        String(format: "%+.2f%%", value)
    }

    private func compact(_ value: Double) -> String {
        guard value > 0 else { return "—" }
        if value >= 1_000_000_000 { return String(format: "$%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "$%.2fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "$%.1fK", value / 1_000) }
        return money(value)
    }

    private func price(_ value: Double) -> String {
        guard value > 0 else { return "—" }
        return "$" + value.formatted(.number.precision(.significantDigits(3...6)))
    }

    private func shortAddress(_ value: String?) -> String {
        guard let value, value.count > 12 else { return value ?? "Open a token page" }
        return "\(value.prefix(7))…\(value.suffix(5))"
    }
}

private struct EmbeddedTradingWebView: UIViewRepresentable {
    let site: TradingSite
    @ObservedObject var session: EmbeddedTradingSession

    func makeCoordinator() -> Coordinator {
        Coordinator(site: site, session: session)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.allowsInlineMediaPlayback = true

        // FOMO's official web product is currently desktop-first. Requesting
        // desktop content here is the same class of browser preference as
        // Safari's "Request Desktop Website"; it does not bypass geo/security.
        if site.id == "fomo" {
            config.defaultWebpagePreferences.preferredContentMode = .desktop
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always

        context.coordinator.webView = webView
        webView.load(URLRequest(url: site.url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.session = session
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let site: TradingSite
        var session: EmbeddedTradingSession
        weak var webView: WKWebView?

        private let resolver = MarketResolver()
        private var lastAddress = ""
        private var refreshTask: Task<Void, Never>?

        init(site: TradingSite, session: EmbeddedTradingSession) {
            self.site = site
            self.session = session
        }

        deinit {
            refreshTask?.cancel()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            session.lastPageURL = webView.url
            refreshMarket()
            startRefreshLoop()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url {
                session.lastPageURL = url
            }
            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        private func startRefreshLoop() {
            refreshTask?.cancel()
            refreshTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(5))
                    guard !Task.isCancelled else { return }
                    self?.refreshMarket()
                }
            }
        }

        private func refreshMarket() {
            guard let url = webView?.url else {
                session.updateToken(nil)
                return
            }

            Task { [weak self] in
                guard let self else { return }

                guard let address = await resolver.tokenAddress(from: url) else {
                    await MainActor.run {
                        if !lastAddress.isEmpty {
                            lastAddress = ""
                            session.updateToken(nil)
                        }
                        session.updateStatus("Open a token page on \(site.name).")
                    }
                    return
                }

                do {
                    let token = try await resolver.resolve(address: address)
                    await MainActor.run {
                        lastAddress = token.address
                        session.updateToken(token)
                    }
                } catch {
                    await MainActor.run {
                        lastAddress = address
                        session.updateToken(nil)
                        session.updateStatus("Token detected, market data unavailable.", error: true)
                    }
                }
            }
        }
    }
}
