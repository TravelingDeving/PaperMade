# Extension Permissions

PaperMade's current private-beta manifest requests a deliberately small set of browser permissions.

## Browser permissions

### `storage`
Used to store simulated paper-trading state and UI preferences, including virtual balance, paper positions, trade history, starting bankroll, quick-trade settings, overlay size/position, collapsed state, transparency, and account bridge state.

### `alarms`
Used for delayed **After I Sold** checkpoints so PaperMade can record what happened to a token after a simulated exit.

PaperMade does **not** request wallet permissions or blockchain signing permissions.

## Host permissions

### `https://fomo.family/*`
### `https://production.fomo.family/*`
Used to display the PaperMade overlay on supported FOMO token pages and read public information visible to the page such as token context and market information.

### `https://axiom.trade/*`
### `https://*.axiom.trade/*`
Used to display the PaperMade overlay on supported Axiom pages and read public token/chart context. Axiom may expose a pool/pair identifier instead of the canonical token contract; PaperMade can resolve that public pair context through its reference market-data source.

### `https://api.dexscreener.com/*`
Used as a public fallback/reference market-data source, for off-page tracking, and for chain-agnostic Axiom pair-to-token resolution.

### `https://lite-api.jup.ag/*`
Used as an early-Solana fallback when a valid Solana mint is not yet available through a normal indexed DEX pair. PaperMade can use public Jupiter token metadata/price information to resolve that mint.

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

## Market-cap source behavior

While the learner is viewing a supported token page, PaperMade prefers a valid visible host-platform market cap. DexScreener is treated as a fallback/reference source.

v0.9.15 fixes a tracking regression in the earlier market-data guard: semantic host-chart values now outrank unrelated nearby dollar figures that merely happen to be numerically closer to the fallback feed. Axiom's token-header market cap is detected directly when possible.

Weak or ambiguous DOM candidates are still sanity-checked against the resolved reference feed. PaperMade also clears stale page price/market-cap values when the host route changes so one token's page data is not carried into another.

When a fallback/reference feed is used, PaperMade normalizes that feed against the reference market cap captured at entry so differences between providers do not automatically become fake profit or loss.

See [DATA-INTEGRITY.md](DATA-INTEGRITY.md) for the current guard/repair model.
