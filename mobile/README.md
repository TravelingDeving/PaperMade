# PaperMade Mobile — iPhone First

This branch starts the mobile version of PaperMade.

## Product direction

The first mobile target is **iPhone/iPad Safari** using a Safari Web Extension packaged inside a lightweight iOS companion app. The goal is to preserve the PaperMade workflow on supported trading sites while redesigning the overlay for touch and small screens.

## Mobile trade UI

Collapsed state:
- Small PaperMade pill
- Token symbol
- Open P&L

Expanded bottom sheet:
- Token + chain + live status
- Available paper balance
- Price
- Market cap
- Liquidity
- Invested
- Position value
- Avg buy market cap
- Open P&L
- Buy / Sell tabs
- Amount entry
- Quick buys / quick sells
- Max
- Paper Buy / Paper Sell

The mobile overlay should use a bottom-sheet interaction instead of shrinking the desktop panel.

## Existing PaperMade systems to reuse

- Paper position / P&L math
- Avg Buy MC
- Journal
- MFE / MAE
- After-I-Sold
- Account sync
- Profiles
- Leaderboard
- P&L Calendar
- Flex Studio / share cards
- FOMO / Axiom / Pump.fun / GMGN host adapters

## Milestones

### M1 — mobile UI prototype
- Bottom-sheet trade panel
- Compact minimized pill
- Touch-friendly buy/sell controls
- Mobile navigation shell

### M2 — shared trading core
- Reuse PaperMade trade/account logic
- Keep desktop and mobile P&L math identical
- Share journal and account state

### M3 — Safari Web Extension
- Inject mobile PaperMade UI into supported Safari pages
- Detect token context
- Read public market data
- Paper buy / sell only
- No wallet signing

### M4 — iOS companion app
- Account login
- Positions
- Journal
- Calendar
- Leaderboard
- Flex Studio
- Extension onboarding / permission status

### M5 — TestFlight
- Private PaperMade testers
- Crash / session / host-site compatibility testing
- App Store prep

## Security invariant

PaperMade Mobile remains a simulator. It should not require a seed phrase, private key, custody, or permission to sign real blockchain transactions.
