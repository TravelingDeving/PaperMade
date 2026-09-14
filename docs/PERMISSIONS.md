# Extension Permissions

PaperMade's current private-beta manifest requests a deliberately small set of browser permissions.

## Browser permissions

### `storage`
Used to store simulated paper-trading state and UI preferences, including virtual balance, paper positions, trade history, quick-trade settings, and overlay size/position.

### `alarms`
Used for delayed **After I Sold** checkpoints so PaperMade can record what happened to a token after a simulated exit.

PaperMade does **not** request wallet permissions or blockchain signing permissions.

## Host permissions

### `https://fomo.family/*`
### `https://production.fomo.family/*`
Used to display the PaperMade overlay on supported FOMO token pages and read public information visible to the page such as token context and market information.

### `https://api.dexscreener.com/*`
Used as a public fallback/reference market-data source when PaperMade needs off-page tracking or cannot use the visible FOMO market-cap value.

### `https://*.supabase.co/*`
Used by the private-beta account-sync flow. Privileged server credentials are not supposed to be embedded in the extension.

### PaperMade website domains
Used by the approved-account bridge between the PaperMade website and extension during private beta.

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

While the learner is viewing a token in FOMO, the visible FOMO market cap is preferred. The DexScreener feed is treated as a fallback/reference source and is normalized against the reference market cap captured at entry to avoid artificial P&L caused by different source scales.
