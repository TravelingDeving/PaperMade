# PaperMade Extension — Public Beta Snapshot

This directory contains the public inspection snapshot for PaperMade's private-beta browser extension.

## Included

- `manifest.json` — current v0.9.6 permissions and host access
- `background.js` — public market-data / After-I-Sold background logic
- `trading-core.js` — paper position, P&L, Avg Buy MC, fee mirroring, partial sell, and Sell All math

## Not yet included

The private-beta authentication/session transport is temporarily excluded while that bridge receives a security review.

Because of that omission, **this directory is not the current install package**. The current private-beta build is distributed through the official PaperMade install flow.

The goal of this repository is to let users inspect the parts that matter most to the PaperMade trust model while private-beta authentication continues to evolve.

## Security invariant

PaperMade's simulator should not require a wallet connection, seed phrase, private key, custody, or permission to sign a real blockchain transaction.
