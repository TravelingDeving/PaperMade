# Extension Permissions

PaperMade's current private-beta manifest requests a deliberately small set of browser permissions.

## Browser permissions

### `storage`
Used to store simulated paper-trading state and UI preferences, including virtual balance, paper positions, trade history, starting bankroll, quick-trade settings, overlay size/position, collapsed state, transparency, marker state and account bridge state.

### `alarms`
Used for delayed **After I Sold** checkpoints so PaperMade can record what happened to a token after a simulated exit.

PaperMade does **not** request wallet permissions or blockchain signing permissions.

## Host permissions

### FOMO
- `https://fomo.family/*`
- `https://production.fomo.family/*`

Used to display the PaperMade overlay on supported FOMO token pages and read public token/chart context.

### Axiom
- `https://axiom.trade/*`
- `https://*.axiom.trade/*`

Used to display the PaperMade overlay on supported Axiom pages and read public token/chart context. Axiom may expose a pool/pair identifier instead of the canonical token contract; PaperMade can resolve that public pair context through its reference market-data source.

### Pump.fun
- `https://pump.fun/*`
- `https://*.pump.fun/*`

Used to display the PaperMade overlay on supported Pump.fun pages and read public token/chart context.

### GMGN
- `https://gmgn.ai/*`
- `https://*.gmgn.ai/*`

Used to display the PaperMade overlay on supported GMGN pages and read public token/chart context.

### `https://api.dexscreener.com/*`
Used as a public fallback/reference market-data source, for off-page tracking, and for chain-agnostic pair-to-token resolution.

### `https://lite-api.jup.ag/*`
Used as an early-Solana fallback and live SOL/USD source when a valid Solana mint or native-price reference is not available through the normal indexed DEX path.

### `https://*.supabase.co/*`
Used by the private-beta account-sync flow. Privileged server credentials are not supposed to be embedded in the extension.

### `https://papermade.xyz/*`
PaperMade's primary public website/account-bridge domain.

### Transition website domains
The old workers.dev hostname and earlier PaperMade domain patterns remain permitted temporarily so existing private-beta sessions and claim/login flows do not break during the domain migration.

## What is not requested

PaperMade does not need permission to:

- read a seed phrase;
- read a private key;
- connect to a crypto wallet;
- approve a token;
- sign a transaction;
- transfer crypto;
- take custody of funds.

## Host-chart and marker behavior

While the learner is viewing a supported token page, PaperMade prefers a valid visible host-platform market cap. Reference feeds are used as fallbacks and sanity checks.

Overlay v0.10.5 also places simulated Buy/Sell markers on supported host charts. Those markers are PaperMade UI only; they do not interact with the user's wallet or broadcast transactions. The marker layer re-evaluates chart geometry after supported zoom, pan, resize and scroll changes so markers can remain anchored to the relevant trade time/candle when the host chart exposes enough geometry to do so.

Weak or ambiguous market-cap candidates are sanity-checked against the resolved reference feed, and stale page values are cleared when the host route changes.

See [DATA-INTEGRITY.md](DATA-INTEGRITY.md) for the current market-data guard/repair model.
