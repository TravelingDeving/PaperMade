// PaperMade Free iPhone Beta
// Deployment source is kept in the private website bundle.
// This public transparency stub documents the route without duplicating
// the private website/session bundle.
//
// Runtime behavior:
// - launched manually from iPhone Safari via Shortcuts > Run JavaScript on Web Page
// - paper-only; no wallet connection, seed phrase, private key, custody or signing
// - FOMO-first, with Axiom/Pump.fun/GMGN hostname allowance for testing
// - detects token address from the visible URL
// - resolves public market data
// - refreshes roughly every 2.5 seconds
// - simulates Buy/Sell, quick buys, percentage sells, Avg Buy MC, Position Value and active P&L
// - stores free-beta state locally in Safari on the trading site
//
// The deployable self-contained script is shipped with Website v4.7.0
// as mobile/papermade-free-overlay.js.
