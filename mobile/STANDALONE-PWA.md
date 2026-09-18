# PaperMade Paper Made

Website v4.8.0 changes the free iPhone beta direction.

## Why

FOMO's iPhone web experience routes mobile users to its app/download landing experience, so the no-cost Safari-overlay experiment is not a dependable product path.

Paper Made therefore becomes its own market viewer + paper trader instead of depending on FOMO Web.

## Free beta architecture

The beta is an installable PWA at `papermade.xyz/mobile.html`.

Current first-party UI:
- Discover: Solana Trending / New / Movers / Volume
- Search: token name, ticker, contract address across DEX Screener-supported markets
- Token detail: price, market cap, liquidity, volume, age, DEX, 5m/1h/6h/24h changes
- Candles: GeckoTerminal public OHLCV feed, Price and estimated-MC modes
- Intelligence: buy pressure, transaction activity, turnover, PaperMade market-risk heuristics
- Solana security: best-effort GoPlus security/holder feed
- Watchlist
- Paper Buy / Sell
- $3 / $5 / $10 / $15 buys
- 25% / 50% / 75% / 100% sells
- Max close
- Avg Buy MC
- active P&L
- Positions
- Journal
- configurable local starting paper bankroll

## Data sources

- DEX Screener: current market/pair data and search
- GeckoTerminal: discovery and OHLCV candles
- GoPlus: best-effort Solana security/holder intelligence

No API keys are embedded in this first public beta.

## State

The first standalone beta stores state locally on the mobile browser under a dedicated PaperMade mobile storage key. It does not modify desktop extension storage or the desktop synchronized account.

Cloud account sync is a later milestone after the standalone experience proves demand.

## Safety boundary

PaperMade remains paper-only. The PWA:
- does not connect a wallet;
- does not request seed phrases or private keys;
- does not hold funds;
- does not sign blockchain transactions;
- does not place real orders.

## Native path

The existing native iOS + Safari Extension work remains on this branch. If users adopt the standalone beta, it can be packaged into the native app later after Apple Developer Program enrollment.
