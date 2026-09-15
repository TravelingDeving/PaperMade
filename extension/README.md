# PaperMade Extension — Public Beta Snapshot

This directory contains the public inspection snapshot for PaperMade's private-beta browser extension.

## Included

- `manifest.json` — current v0.9.13 permissions and supported hosts
- `background.js` — public market-data, Axiom pair-resolution, and After-I-Sold background logic
- `trading-core.js` — paper position, P&L, Avg Buy MC, fee mirroring, partial sell, and Sell All math

## Current private-beta behavior

The current private-beta overlay supports:

- FOMO token pages
- Axiom token pages
- multichain Axiom pair-to-token resolution
- $100 default starting bankroll for new users
- selectable $100–$1,000 starting bankrolls
- 35%–100% overlay transparency
- live-linked Max / 100% Sell
- exact dust-free full closes
- live paper P&L and Avg Buy MC
- market-data sanity checks and high-confidence spike repair

## Not yet included

The private-beta authentication/session transport and full production UI bundle are temporarily excluded while the account bridge continues to receive a security review.

Because of that omission, **this directory is not the current install package**. The current private-beta build is distributed through the official PaperMade install flow.

The goal of this repository is to let users inspect the parts that matter most to the PaperMade trust model while private-beta authentication continues to evolve.

## Security invariant

PaperMade's simulator should not require a wallet connection, seed phrase, private key, custody, or permission to sign a real blockchain transaction.

See [`../docs/DATA-INTEGRITY.md`](../docs/DATA-INTEGRITY.md) for the current market-data validation model.
