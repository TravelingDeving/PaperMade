import SwiftUI
import WebKit

struct EmbeddedTradingView: View {
    @EnvironmentObject var store: PaperMadeStore
    let site: TradingSite

    var body: some View {
        EmbeddedTradingWebView(site: site, store: store)
            .ignoresSafeArea(edges: .bottom)
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

private struct EmbeddedTradingWebView: UIViewRepresentable {
    let site: TradingSite
    @ObservedObject var store: PaperMadeStore

    func makeCoordinator() -> Coordinator {
        Coordinator(site: site, store: store)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.allowsInlineMediaPlayback = true

        let userContent = WKUserContentController()
        userContent.add(context.coordinator, name: "papermade")
        config.userContentController = userContent

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
        context.coordinator.store = store
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "papermade")
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let site: TradingSite
        var store: PaperMadeStore
        weak var webView: WKWebView?

        private let resolver = MarketResolver()
        private var currentToken: ResolvedMarketToken?
        private var lastAddress = ""
        private var refreshTask: Task<Void, Never>?

        init(site: TradingSite, store: PaperMadeStore) {
            self.site = site
            self.store = store
        }

        deinit {
            refreshTask?.cancel()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            injectOverlay()
            resolveCurrentPage()
            startRefreshLoop()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
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

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard
                message.name == "papermade",
                let body = message.body as? [String: Any],
                let type = body["type"] as? String
            else { return }

            switch type {
            case "ready", "overlayOpen":
                resolveCurrentPage()
                pushModelToOverlay()

            case "trade":
                guard
                    let mode = body["mode"] as? String,
                    let amount = (body["amount"] as? NSNumber)?.doubleValue
                else { return }
                executeTrade(mode: mode, amount: amount)

            default:
                break
            }
        }

        private func injectOverlay() {
            webView?.evaluateJavaScript(EmbeddedTradingOverlayScript.source) { [weak self] _, _ in
                self?.pushModelToOverlay()
            }
        }

        private func startRefreshLoop() {
            refreshTask?.cancel()
            refreshTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(5))
                    guard !Task.isCancelled else { return }
                    await self?.refreshMarketAndOverlay()
                }
            }
        }

        private func resolveCurrentPage() {
            Task { [weak self] in
                await self?.refreshMarketAndOverlay()
            }
        }

        private func refreshMarketAndOverlay() async {
            guard let webView else { return }
            let url = await MainActor.run { webView.url }

            guard let address = await resolver.tokenAddress(from: url) else {
                await MainActor.run {
                    currentToken = nil
                    lastAddress = ""
                    pushModelToOverlay()
                    setStatus("Open a token page on \(site.name).", kind: "info")
                }
                return
            }

            if address != lastAddress || currentToken == nil {
                do {
                    let resolved = try await resolver.resolve(address: address)
                    await MainActor.run {
                        currentToken = resolved
                        lastAddress = resolved.address
                        pushModelToOverlay()
                        setStatus("Live paper market connected.", kind: "ok")
                    }
                } catch {
                    await MainActor.run {
                        currentToken = nil
                        lastAddress = address
                        pushModelToOverlay()
                        setStatus("Token detected, market data unavailable.", kind: "error")
                    }
                }
                return
            }

            do {
                let resolved = try await resolver.resolve(address: address)
                await MainActor.run {
                    currentToken = resolved
                    pushModelToOverlay()
                }
            } catch {}
        }

        private func executeTrade(mode: String, amount: Double) {
            guard let token = currentToken else {
                setStatus("Open a supported token page first.", kind: "error")
                return
            }

            do {
                var raw = EmbeddedPaperState.currentDictionary()

                if mode == "sell" {
                    raw = try EmbeddedPaperState.paperSell(
                        state: raw,
                        token: token,
                        amountUsd: amount
                    )
                } else {
                    raw = try EmbeddedPaperState.paperBuy(
                        state: raw,
                        token: token,
                        spend: amount
                    )
                }

                let data = try EmbeddedPaperState.write(raw)
                try store.replaceFromStateJSON(data)
                pushModelToOverlay()
                setStatus(mode == "sell" ? "Paper sell filled." : "Paper buy filled.", kind: "ok")
            } catch {
                setStatus((error as? LocalizedError)?.errorDescription ?? error.localizedDescription, kind: "error")
            }
        }

        private func pushModelToOverlay() {
            guard let webView else { return }
            var payload: [String: Any] = [
                "cash": store.snapshot.cash
            ]

            if let token = currentToken {
                let raw = EmbeddedPaperState.currentDictionary()
                let metrics = EmbeddedPaperState.positionMetrics(state: raw, token: token)

                payload["token"] = [
                    "address": token.address,
                    "symbol": token.symbol,
                    "name": token.name,
                    "chainId": token.chainId,
                    "priceUsd": token.priceUsd,
                    "marketCap": token.marketCap,
                    "liquidityUsd": token.liquidityUsd
                ]
                payload["invested"] = metrics.invested
                payload["value"] = metrics.value
                payload["pnl"] = metrics.pnl
                payload["pct"] = metrics.pct
                payload["avgEntryMc"] = metrics.avgEntryMc
            } else {
                payload["token"] = NSNull()
                payload["invested"] = 0
                payload["value"] = 0
                payload["pnl"] = 0
                payload["pct"] = 0
                payload["avgEntryMc"] = 0
            }

            guard
                JSONSerialization.isValidJSONObject(payload),
                let data = try? JSONSerialization.data(withJSONObject: payload),
                let json = String(data: data, encoding: .utf8)
            else { return }

            webView.evaluateJavaScript("window.PaperMadeNative && window.PaperMadeNative.update(\(json));")
        }

        private func setStatus(_ text: String, kind: String) {
            guard let webView else { return }
            let safeText = text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
            let safeKind = kind.replacingOccurrences(of: "'", with: "")
            webView.evaluateJavaScript("window.PaperMadeNative && window.PaperMadeNative.status('\(safeText)','\(safeKind)');")
        }
    }
}
