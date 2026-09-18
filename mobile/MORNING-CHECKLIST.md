# PaperMade Mobile — Morning Setup Checklist

The code can keep moving without a Mac. To get the first real iPhone/TestFlight build, these are the account-side steps that need a human login.

## 1. Apple Developer Program

Enroll the Apple ID that will own PaperMade in the Apple Developer Program.

TestFlight/App Store distribution requires active Apple Developer Program membership.

## 2. Create the app identifiers

In Apple Developer Certificates, Identifiers & Profiles, register:

- App: `xyz.papermade.app`
- Safari extension: `xyz.papermade.app.Extension`
- App Group: `group.xyz.papermade.shared`

Enable the App Groups capability for both the app and extension and attach the shared group.

If Apple says one of these identifiers is unavailable, stop and change all matching references in the repo together rather than making only one side different.

## 3. Create the App Store Connect app

Create a new iOS app named **PaperMade** using bundle ID:

`xyz.papermade.app`

The first App Store Connect record must exist before automated TestFlight publishing can be fully wired.

## 4. Create a Codemagic account

Connect the GitHub repository:

`TravelingDeving/PaperMade`

Select the `mobile-ios` branch. Codemagic reads `codemagic.yaml` from the repository root.

## 5. Connect Apple to Codemagic

In App Store Connect:

Users and Access → Integrations → App Store Connect API

Create a dedicated API key for Codemagic with App Manager access.

Save:
- Issuer ID
- Key ID
- the downloaded `.p8` private key

The private key can only be downloaded once.

Then add that key in Codemagic:

Team settings → Developer Portal → Manage keys

## 6. Signing

Codemagic needs:
- an Apple Distribution certificate
- an App Store provisioning profile for `xyz.papermade.app`
- an App Store provisioning profile for `xyz.papermade.app.Extension`

Because PaperMade contains a Safari app extension, both bundle identifiers need signing profiles.

## 7. First build

Run workflow:

**PaperMade iOS TestFlight**

The first goal is only:
- Xcode project generates
- both targets sign
- IPA builds

Do not enable automatic external TestFlight distribution until we have tested the app and Safari extension on a real iPhone.

## 8. First-device test order

After the first build is available:

1. Install PaperMade through TestFlight/internal testing.
2. Open PaperMade once.
3. Enable the PaperMade Safari extension.
4. Allow it on FOMO/Axiom/Pump.fun/GMGN.
5. Sign into papermade.xyz in Safari.
6. Open a supported token.
7. Confirm the PaperMade pill appears.
8. Make a tiny paper buy.
9. Confirm the same position appears in the PaperMade app.
10. Sell/close and confirm Journal + Calendar update.

Do not test with real wallet transactions. PaperMade Mobile is a simulator.
