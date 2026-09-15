# PaperMade

**Real charts. Fake money. Better traders.**

PaperMade is a browser-extension paper-trading overlay for practicing meme-coin trading directly on live chart pages without risking real funds.

> **Private beta:** access is currently limited to approved PaperMade Discord testers.

## What PaperMade does

- Paper trading only — no real transaction execution
- No wallet connection required
- No seed phrase or private key access
- FOMO + Axiom overlay support
- Axiom multichain pair-to-token resolution
- Multi-source early Solana token resolution
- DexScreener reference/fallback data
- Jupiter Tokens/Price fallback for Solana mints without a normal indexed DEX pair yet
- Live chart / market-cap tracking
- Solana and EVM contract-address detection
- Custom dollar buys and sells
- Editable quick-buy and sell presets
- Optional Fast Buy
- Live-linked Max / 100% Sell
- Exact Sell All / Max close
- Live Open P&L
- Avg Buy MC
- Open-position tracking
- Trade journal
- Hold-time tracking
- MFE / MAE
- Profit-captured tracking
- After-I-Sold tracking
- Movable and resizable overlay
- Adjustable overlay transparency
- $100 default starting bankroll for new accounts
- Selectable $100–$1,000 starting bankroll
- Paper-trading account sync
- Discord-gated private beta access
- Main trader profiles
- Friends and trader comparison
- Server-earned achievements and featured badges
- P&L flex cards and leaderboard
- Site-wide extension update alerts

## Security model

PaperMade is designed so the extension does **not** need:

- a wallet connection
- a seed phrase
- a private key
- custody of funds
- permission to sign blockchain transactions

The trading state is simulated. The extension reads public market information and can sync a signed-in user's simulated record to the PaperMade backend.

PaperMade also sanity-checks host-page market-cap values so an implausible DOM scrape is rejected instead of being allowed to create fake simulated P&L. A conservative repair path exists for high-confidence historical source-scale failures.

See [SECURITY.md](SECURITY.md), [PRIVACY.md](PRIVACY.md), and [docs/DATA-INTEGRITY.md](docs/DATA-INTEGRITY.md).

## Current build

- Overlay: **v0.9.14**
- Website: **v4.4.2**
- Status: **Private Beta**

Website v4.4.2 includes editable main trader profiles, achievements/badges, profile banners, Friends, trader comparison, staff moderation, P&L cards, a persistent Profile action beside My record, and a site-wide update banner driven by `release.json` whenever a newer extension package is published.

Overlay v0.9.14 keeps FOMO + Axiom multichain support, the $100–$1,000 bankroll system, transparency control, live-linked Max Sell, account sync, and market-data spike protection. It also adds a multi-source token resolver: normal DEX data first, Axiom pair resolution second, and Jupiter Tokens/Price as an early-Solana fallback.

## Public source snapshot

This repository is PaperMade's public transparency repository during private beta.

Currently published:

- the extension manifest / requested permissions;
- public market-data, multi-source token-resolution, and After-I-Sold background logic;
- core paper position / P&L / Avg Buy MC / Sell All math;
- security, privacy, permission, data-integrity, and release documentation.

The private-beta authentication/session transport is **not included in the public snapshot yet while that bridge receives a security review**. The public repository therefore should be treated as an inspection snapshot, **not the current install package**.

The private-beta install package is distributed through the official PaperMade install flow.

## Repository layout

```text
extension/   Public extension logic and permission snapshot
docs/        Public documentation
```

## Transparency

The repository is meant to make the important trust questions easy to answer:

1. What browser permissions does PaperMade request?
2. What market sources does it read?
3. How is simulated P&L calculated?
4. How does Avg Buy MC work?
5. What does Sell All actually do?
6. How does PaperMade reject implausible market-data spikes?
7. How can an early Solana token load before a normal DEX pair is indexed?
8. Does any of this require a wallet or transaction signature? (**No.**)

Read [docs/PERMISSIONS.md](docs/PERMISSIONS.md), [docs/PAPER-TRADING-MODEL.md](docs/PAPER-TRADING-MODEL.md), and [extension/trading-core.js](extension/trading-core.js).

**PaperMade should never ask for your seed phrase or private key.**

## Disclaimer

PaperMade simulates trades for learning and performance tracking. PaperMade P&L, leaderboards, achievements, and flex cards represent simulated results and are not proof of real-money trading performance.
