# PaperMade Extension — Public Beta Snapshot

This directory contains PaperMade's public inspection snapshot for the private-beta browser extension.

## Current private-beta build

- Overlay: **v0.10.6**
- Website: **v4.6.4**
- Official site: **https://papermade.xyz**

## Included

- `manifest.json` — current v0.10.6 requested permissions and supported hosts
- `background.js` — public market-data / pair-resolution / After-I-Sold inspection snapshot
- `trading-core.js` — paper position, P&L, Avg Buy MC, fee mirroring, partial-sell and Sell All math
- `papermade-bridge.js` — public browser-side website bridge loader

## Current private-beta behavior

The production overlay supports:

- FOMO, Axiom, Pump.fun and GMGN host pages
- multichain Axiom pair-to-token resolution
- early Solana token fallback through public Jupiter data
- compact full-data Trade UI
- live paper balance, Invested, Position Value, Open P&L and Avg Buy MC
- seven-figure market-cap P&L precision that avoids sticky P&L when host M-scale labels are rounded
- on-chart simulated Buy/Sell markers on supported host charts
- candle-aware B/S marker re-anchoring after supported chart zoom/pan
- $100 default starting bankroll for new users
- selectable $100–$1,000 starting bankrolls
- 35%–100% overlay transparency
- live-linked percentage sells and exact Sell All / Max closes
- market-data sanity checks and conservative high-confidence spike repair
- trade journal, MFE/MAE, hold time and After-I-Sold tracking
- account sync for approved private-beta users

## Not included in this public snapshot

The complete production content-script UI bundle, website session injection page, and full private-beta authentication/session transport are not published here yet while those surfaces continue to receive security review.

Because of those omissions, **this directory is not the install package**. The signed-in private-beta build is distributed through the official PaperMade install flow.

The public repository is an inspection snapshot intended to make PaperMade's permissions, market-data model and paper-trading math easier to review.

## Security invariant

PaperMade's simulator should not require a wallet connection, seed phrase, private key, custody, or permission to sign a real blockchain transaction.

See [`../docs/PERMISSIONS.md`](../docs/PERMISSIONS.md), [`../docs/DATA-INTEGRITY.md`](../docs/DATA-INTEGRITY.md), and [`../docs/PAPER-TRADING-MODEL.md`](../docs/PAPER-TRADING-MODEL.md).
