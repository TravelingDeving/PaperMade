# PaperMade Mobile Xcode Packaging

This folder is the handoff from the PaperMade mobile source tree into a real iOS + Safari Web Extension project.

## Proposed identifiers

- App bundle: `xyz.papermade.app`
- Safari extension bundle: `xyz.papermade.app.Extension`
- App Group: `group.xyz.papermade.shared`

These identifiers are proposed until they are registered in the Apple Developer account. If Apple reports that any identifier is unavailable, change all matching references together.

## Generate the Xcode project

On a Mac:

1. Install Xcode.
2. Install XcodeGen.
3. From this directory run:
   `xcodegen generate`
4. Open `PaperMadeMobile.xcodeproj`.
5. Select the PaperMade development team for both targets.
6. Enable the App Groups capability on both targets and select:
   `group.xyz.papermade.shared`
7. Confirm the Safari Web Extension target has the same App Group.
8. Build to a physical iPhone.

## What the native bridge does

The Safari extension background script can use Safari native messaging. The native Safari app-extension handler writes non-wallet PaperMade snapshots into the shared App Group container.

Shared snapshots include:
- paper balance/state
- positions
- trade history
- closed-trade journal
- P&L calendar ledger
- sync status
- leaderboard snapshot
- profile/badges snapshot

The iPhone app reads those shared snapshots and renders them natively.

## TestFlight path

After a successful physical-device build:
- Archive the PaperMade scheme.
- Validate signing/capabilities.
- Upload the archive to App Store Connect.
- Add the build to an internal TestFlight group first.
- Verify Safari extension enablement and site permissions on a real iPhone before external beta.

## Important

A TestFlight/App Store binary cannot be produced from this Linux build environment because Apple requires Xcode, Apple signing, and App Store Connect credentials on macOS. The source tree is being prepared so the Xcode step is packaging/signing rather than a rewrite.
