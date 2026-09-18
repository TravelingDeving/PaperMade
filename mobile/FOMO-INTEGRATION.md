# PaperMade Mobile — FOMO Integration Plan

FOMO is the priority mobile trading surface for PaperMade.

## Two FOMO paths are being kept

### 1. Embedded FOMO beta

PaperMade loads the public FOMO web experience inside an iOS WKWebView.

Because FOMO's web product is currently desktop-first, the embedded browser requests desktop web content for FOMO. This is equivalent to a browser's "Request Desktop Website" preference.

The PaperMade trading controls are **native SwiftUI layered above the web view**. PaperMade does not need to rewrite or inject controls into FOMO's DOM for this mode.

PaperMade:
- detects the token address from the visible page URL;
- resolves public market data from PaperMade's market-data source;
- shows PaperMade price / MC / liquidity / position statistics;
- executes only simulated PaperMade Buy/Sell actions;
- never triggers a real FOMO trade;
- never reads or uses a FOMO seed phrase/private key;
- never signs a blockchain transaction.

### 2. Safari extension fallback

If embedded FOMO has login, layout, WebView, or App Review issues, the user can open the same FOMO URL in Safari.

The PaperMade Safari extension remains the fallback and can show the mobile PaperMade panel there.

## iPhone test matrix

The first physical iPhone build must verify:

- FOMO home page loads in embedded desktop mode
- existing FOMO account login works
- email login works
- Apple sign-in works, if FOMO exposes it inside WebView
- navigation into a token updates the WebView URL
- Solana token addresses are detected
- EVM token addresses are detected
- PaperMade market data resolves
- PaperMade pill remains touch-friendly while FOMO is desktop-scaled
- Paper Buy works
- Paper Sell works
- partial Sell works
- Sell All closes exactly
- position appears in the native PaperMade Positions screen
- close appears in Journal
- close appears in P&L Calendar
- native trade marks account sync as pending
- Safari extension/account bridge clears pending sync after upload
- opening the Safari fallback preserves the same PaperMade paper state
- orientation changes do not hide the PaperMade pill
- FOMO popups/new-window navigation stays usable

## Public-release guardrail

The embedded FOMO mode is a **private beta integration experiment** until PaperMade confirms that public third-party embedding/integration is permitted.

Do not automate FOMO real-account actions. Do not scrape FOMO private/account data. Do not bypass location, security, authentication, or product restrictions.

Before a public App Store launch that markets FOMO integration, obtain written permission/partnership confirmation from FOMO or otherwise confirm the integration is permitted.

## Architecture choice

The native overlay is deliberate.

A native SwiftUI PaperMade sheet:
- stays correctly sized even while FOMO requests desktop web content;
- isolates PaperMade controls from FOMO CSS/DOM changes;
- reduces breakage when FOMO redesigns;
- makes PaperMade's simulated-trading boundary clearer;
- avoids relying on FOMO chart DOM for core paper-trading functionality.

Chart B/S markers remain a separate host-adapter milestone because they require mapping the visible chart's time/price coordinates.
