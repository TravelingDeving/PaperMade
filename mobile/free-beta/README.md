# PaperMade Free iPhone Beta

This is the no-cost iPhone validation route used before paying for Apple Developer Program distribution.

## User flow

1. Open `papermade.xyz/mobile.html` in iPhone Safari.
2. Add PaperMade to the Home Screen.
3. Copy the PaperMade Shortcut code.
4. Create an Apple Shortcut using **Safari → Run JavaScript on Web Page** and enable it in the Share Sheet.
5. Open a supported token page in Safari.
6. Share → PaperMade.
7. The PaperMade pill appears; tap it to paper Buy/Sell.

## Why this exists

The goal is to validate whether customers actually use PaperMade on iPhone before paying for native App Store/TestFlight distribution.

## Free-beta limitations

- Manual Share Sheet launch instead of automatic Safari-extension injection.
- Paper state is local to Safari on the trading site.
- It is not yet the same synced account as the desktop extension.
- No native App Store binary.
- No chart-marker host adapter in the first free beta.

## Safety boundary

PaperMade remains simulation-only. The free mobile beta does not connect wallets, request seed phrases/private keys, take custody, sign transactions, or send real orders.

## Paid upgrade path

If the free beta gets real usage, the existing `mobile-ios` native companion app + Safari Web Extension + shared App Group + Codemagic/TestFlight work becomes the production path.


## FOMO Universal Link caveat

On iPhone, tapping a normal `https://fomo.family/` link can hand off directly to the installed FOMO native app through Apple's Universal Links behavior.

For the free beta, the setup page therefore does **not** use a normal clickable FOMO link. It tells the tester to copy `https://production.fomo.family/`, paste it directly into Safari's address bar, and navigate from there. The normal Safari Shortcut flow only begins after FOMO is actually staying in Safari.

If FOMO later blocks or redirects all mobile web browsing at the site level, the free Shortcut route cannot provide the intended FOMO experience and the native/paid integration path must be reconsidered.
