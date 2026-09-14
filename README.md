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
- Website: **v4.0**
- Status: **Private Beta**

## Repository layout

```text
extension/   Current browser-extension source
docs/        Public documentation
```

## Inspecting the extension

1. Clone or download this repository.
2. Open `chrome://extensions`.
3. Enable **Developer mode**.
4. Choose **Load unpacked**.
5. Select the `extension` folder.

PaperMade is currently a private beta, so paper-trading controls still require an approved PaperMade account.

## Transparency

The source is published so traders can inspect PaperMade's permissions, storage behavior, paper-trading calculations, and account-sync behavior before installing it.

**PaperMade should never ask for your seed phrase or private key.**

## Disclaimer

PaperMade simulates trades for learning and performance tracking. PaperMade P&L, leaderboards, and flex cards represent simulated results and are not proof of real-money trading performance.
