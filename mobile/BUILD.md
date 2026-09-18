# PaperMade Mobile Build Notes

## What exists now

The `mobile-ios` branch now contains:

1. A touch-first mobile UI prototype.
2. A Safari Web Extension source folder with:
   - supported host permissions;
   - token/pair resolution through public DexScreener data;
   - local paper balance;
   - paper Buy/Sell;
   - live Price / MC / Liquidity;
   - Invested / Position Value / Avg Buy MC / Open P&L;
   - compact minimized pill.
3. A SwiftUI companion-app source shell.

## Current limitation

This is **mobile alpha source**, not an App Store/TestFlight binary yet.

The Safari extension currently uses local extension storage and does not yet connect to PaperMade production account sync. The next milestone is to reuse the production account/session bridge so mobile and desktop share the same PaperMade paper account.

## Xcode packaging path

On macOS with Xcode installed:

- Create a new iOS app target named PaperMade.
- Add a Safari Web Extension target.
- Copy the contents of `mobile/safari-extension/` into the Safari extension's Resources folder.
- Use `mobile/ios-companion/PaperMadeApp.swift` and `ContentView.swift` as the companion-app starting source.
- Keep the extension paper-only; do not add wallet signing capabilities.

## Next engineering milestone

- Port the current PaperMade production account bridge.
- Pull/push the same paper state as desktop.
- Add Positions and Journal native views.
- Add Calendar and Leaderboard.
- Add Flex Studio/share export.
- Add mobile host-specific chart-marker adapters.
