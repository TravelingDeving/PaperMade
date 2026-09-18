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


## Cloud build pipeline

The `mobile-ios` branch now includes a root-level `codemagic.yaml` for a macOS cloud build.

Workflow:
- installs XcodeGen
- generates `PaperMadeMobile.xcodeproj`
- verifies both app/extension targets
- applies App Store provisioning profiles
- builds a signed IPA
- exposes IPA, app, dSYM and Xcode logs as artifacts
- is prepared to upload to App Store Connect once the Codemagic Apple integration is connected

The Codemagic Apple integration is expected to be named:

`papermade`

The first workflow intentionally keeps automatic TestFlight submission disabled until the first signed iPhone build and Safari-extension behavior are verified.

## App Store compliance prep

Both native bundles now include a `PrivacyInfo.xcprivacy` manifest for the shared App Group `UserDefaults` bridge. The declared reason is `1C8F.1`, which is the App Group sharing reason for UserDefaults.

Safari native messaging now uses the containing app identifier parameter expected by Safari's `sendNativeMessage` API.


## FOMO-first embedded beta

FOMO is now the first-priority embedded mobile host.

The iOS companion app has an experimental **FOMO inside PaperMade** path:
- WKWebView hosts FOMO web.
- FOMO requests desktop content because the official FOMO web experience is desktop-first.
- PaperMade's pill and trading sheet are native SwiftUI, not injected FOMO DOM.
- token context comes from the page URL;
- market data resolves independently;
- PaperMade Buy/Sell remains fully simulated;
- native paper trades write into the shared PaperMade App Group state;
- a dirty-state queue is picked up by the Safari extension/account bridge and uploaded to the normal PaperMade state when account sync is available.

The original Safari extension route remains available as the fallback.

See `mobile/FOMO-INTEGRATION.md` for the physical-device test matrix and public-release guardrails.
