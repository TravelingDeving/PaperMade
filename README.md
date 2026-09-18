# PaperMade

**Real charts. Fake money. Better traders.**

PaperMade is a browser-extension paper-trading overlay for practicing meme-coin trading directly on live chart pages without risking real funds.

> **Private beta:** access is currently limited to approved PaperMade Discord testers.

## What PaperMade does

- Paper trading only — no real transaction execution
- No wallet connection required
- No seed phrase or private key access
- FOMO + Axiom + Pump.fun + GMGN overlay support
- Axiom multichain pair-to-token resolution
- Multi-source early Solana token resolution
- DexScreener reference/fallback data
- Jupiter Tokens/Price fallback for Solana mints without a normal indexed DEX pair yet
- Live host-chart / market-cap tracking
- On-chart paper Buy/Sell markers that re-anchor during supported host-chart zoom/pan
- Solana and EVM contract-address detection
- Custom dollar buys and sells
- Editable quick-buy and sell presets
- Optional Fast Buy
- Live-linked 25% / 50% / 75% / 100% sell presets
- Exact Sell All / Max close
- Principal-recovered (“initials out”) Open P&L display
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
- P&L flex cards, Flex Studio image/video exports, P&L Calendar, and leaderboard
- Site-wide extension update alerts

## Security model

PaperMade is designed so the extension does **not** need:

- a wallet connection
- a seed phrase
- a private key
- custody of funds
- permission to sign blockchain transactions

The trading state is simulated. The extension reads public market information and can sync a signed-in user's simulated record to the PaperMade backend.

PaperMade sanity-checks host-page market-cap values so unrelated DOM values are rejected instead of being allowed to create fake simulated P&L. High-confidence historical source-scale failures can be conservatively repaired.

See [SECURITY.md](SECURITY.md), [PRIVACY.md](PRIVACY.md), and [docs/DATA-INTEGRITY.md](docs/DATA-INTEGRITY.md).

## Current build

- Overlay: **v0.10.6**
- Website: **v4.6.4**
- Primary site: **https://papermade.xyz**
- Status: **Private Beta**

Website v4.6.4 distributes Overlay v0.10.6 with a descriptive release filename (`PaperMade-v0.10.6-HIGH-MC-PNL-PRECISION.zip`) while preserving the Calendar, recovered leaderboard, Flex Studio video/PNG workflow, and working authentication configuration.

Overlay v0.10.6 adds **High-MC P&L Precision**. When a seven-figure platform market-cap label is rounded (for example, multiple real values showing as `1.3M`), PaperMade keeps the visible platform MC for the UI but values the paper position from a higher-resolution live price/reference ratio. FOMO fallback market-data refresh is also faster.

PaperMade remains paper-only: the overlay does not need a wallet connection, seed phrase, private key, custody, or blockchain transaction signing.

## Public source snapshot

This repository is PaperMade's public transparency repository during private beta.

Currently published:

- the extension manifest / requested permissions;
- public market-data, multi-source token-resolution, and After-I-Sold background logic;
- core paper position / P&L / Avg Buy MC / Sell All math;
- security, privacy, permission, data-integrity, and release documentation.

The private-beta authentication/session transport and full production UI are **not included in the public snapshot yet while that bridge receives a security review**. The public repository therefore should be treated as an inspection snapshot, **not the current install package**.

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
4. What does “initials out” mean in the live P&L display?
5. How does Avg Buy MC work?
6. What does Sell All actually do?
7. How does PaperMade reject implausible market-data spikes?
8. How can an early Solana token load before a normal DEX pair is indexed?
9. Does any of this require a wallet or transaction signature? (**No.**)

Read [docs/PERMISSIONS.md](docs/PERMISSIONS.md), [docs/PAPER-TRADING-MODEL.md](docs/PAPER-TRADING-MODEL.md), and [extension/trading-core.js](extension/trading-core.js).

**PaperMade should never ask for your seed phrase or private key.**

## Disclaimer

PaperMade simulates trades for learning and performance tracking. PaperMade P&L, leaderboards, achievements, and flex cards represent simulated results and are not proof of real-money trading performance.
