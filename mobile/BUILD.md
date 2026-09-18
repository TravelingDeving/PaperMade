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


## Progress — mobile app shell

The companion app now has native:
- Trade home / Safari setup
- Positions
- Journal
- P&L Calendar
- More / account status

The Safari overlay now has:
- Trade
- Positions
- Journal
- More
- account sync status
- links into Calendar, Leaderboard, Flex Studio and Profile

The next app milestone is native leaderboard/profile data plus Flex Studio sharing, followed by Xcode packaging and TestFlight.


## Progress — native app bridge + social + sharing

PaperMade Mobile now also includes:

- Safari native-messaging permission
- SafariWebExtensionHandler bridge
- shared App Group snapshot storage
- native iOS Leaderboard screen
- native iOS Profile / achievements screen
- native image P&L Flex cards + iOS share sheet
- existing video Flex Studio link while MP4 rendering is ported
- persistent closed-trade journal parsing
- persistent calendar-day ledger parsing
- native app refresh when returning to the foreground
- XcodeGen project definition
- app + extension entitlements
- Safari extension Info.plist

Proposed Apple identifiers:
- app: xyz.papermade.app
- extension: xyz.papermade.app.Extension
- App Group: group.xyz.papermade.shared

The next physical-device milestone is generating the Xcode project on macOS, registering/signing these identifiers with the Apple Developer account, installing on an iPhone, and testing the Safari overlay on the supported host sites before TestFlight.
