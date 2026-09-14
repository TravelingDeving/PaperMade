# PaperMade

**Real charts. Fake money. Better traders.**

PaperMade is a browser-extension paper-trading overlay built for practicing meme-coin trading directly on live chart pages without risking real funds.

> **Private beta:** access is currently limited to approved PaperMade Discord testers.

## What PaperMade does

- Paper trading only — no real transaction execution
- No wallet connection required
- No seed phrase or private key access
- Live chart / market-cap tracking
- Solana and EVM contract-address detection
- FOMO-style Buy / Sell controls
- Custom dollar buys and sells
- Editable quick-buy and sell presets
- Optional Fast Buy
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
- Paper-trading account sync
- Discord-gated private beta access

## Security model

PaperMade is designed so the extension does **not** need:

- a wallet connection
- a seed phrase
- a private key
- custody of funds
- permission to sign blockchain transactions

The trading state is simulated. The extension reads public market information and can sync a signed-in user's simulated record to the PaperMade backend.

See [SECURITY.md](SECURITY.md) and [PRIVACY.md](PRIVACY.md).

## Current build

- Overlay: **v0.9.6**
- Website: **v4.1**
- Status: **Private Beta**

Website v4.1 adds persistent navigation, public profile banners, owner-controlled moderator access, a staff feedback queue, and tighter public-profile privacy.

## Public source snapshot

This repository is being used as PaperMade's public transparency repository during private beta.

Currently published:

- the exact extension manifest / requested permissions;
- public market-data and After-I-Sold background logic;
- the core paper position / P&L / Avg Buy MC / Sell All math;
- security, privacy, permission, and release documentation.

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
6. Does any of this require a wallet or transaction signature? (**No.**)

Read [docs/PERMISSIONS.md](docs/PERMISSIONS.md) and [extension/trading-core.js](extension/trading-core.js).

**PaperMade should never ask for your seed phrase or private key.**

## Disclaimer

PaperMade simulates trades for learning and performance tracking. PaperMade P&L, leaderboards, and flex cards represent simulated results and are not proof of real-money trading performance.
