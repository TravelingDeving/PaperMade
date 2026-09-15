# Changelog

## Website v4.4.2
- Added a site-wide **Update Available** banner for new extension releases.
- The banner is driven by `release.json`, so future builds can be announced without editing every page.
- Added direct download and What's new actions.
- Dismissal is remembered per extension version; a newer version shows a fresh alert.
- Install page now distributes Overlay v0.9.14.

## Overlay v0.9.14
- Added multi-source token resolution instead of treating DexScreener as the only valid token source.
- Resolution order is normal DEX token data, Axiom pair-to-token resolution, then Jupiter Tokens/Price for early Solana mints.
- Manually pasted Solana CAs can resolve even when a standard DEX pair has not been indexed yet, provided the fallback source has metadata or price data.
- Manual CA mode no longer inherits the visible market cap from an unrelated token page underneath the overlay.
- Added `lite-api.jup.ag` to the public manifest permissions for the Solana fallback.

## Website v4.4.1
- Added a permanent **Profile** action directly beside **My record** across every website page.
- Made the universal website header sticky while scrolling.
- Removed the duplicate My profile entry from the Community dropdown.
- Added active states for My record / Profile.
- Added performance-badge revalidation so repaired market-data spikes do not leave false return badges behind.
- Updated the Install page to distribute Overlay v0.9.13.

## Overlay v0.9.13
- Added market-cap sanity checks for host-page values.
- Cross-checks visible platform market-cap candidates against the resolved reference feed.
- Rejects implausible Axiom/FOMO DOM values instead of allowing them to create fake paper P&L.
- Added source-scale drift protection for position valuation.
- Added conservative repair for high-confidence historical source-scale failures.
- Repaired records are tagged so they cannot be repaired twice.
- Corrupted extreme MFE/captured-profit values are also cleared during repair.

## Website v4.4
- Added a main editable trader profile for every approved PaperMade user.
- Added display name, avatar, banner, bio, favorite chain, trading style, and social handle settings.
- Added server-earned achievements and badge rarity levels.
- Added featured badge showcases.
- Added OG Beta Tester and milestone/trading/community achievements.
- Added a lifetime trade ledger so earned achievements can persist across paper-account resets.
- Added badge display support on profiles, trader directory, and leaderboard surfaces.

## Overlay v0.9.12
- Replaced Solana-only Axiom pair resolution with chain-agnostic pair lookup.
- Supports Axiom pair-to-token resolution across chains when the pair is available through the reference market-data source.
- Prefers exact pair-address matches and then resolves to the canonical token contract.

## Overlay v0.9.11
- Fixed Axiom `/meme/<pair>` auto-detection by resolving pair/pool addresses into real token contracts.
- Keeps the same canonical paper position when a token is viewed across FOMO and Axiom.
- Fixed Starting Bankroll so **Apply & Reset** works on the first click.

## Overlay v0.9.10
- Added adjustable full-overlay transparency from 35% to 100%.
- Transparency updates live and persists across refreshes.

## Overlay v0.9.9
- Brand-new PaperMade accounts now default to a $100 starting bankroll.
- Added selectable $100–$1,000 starting bankrolls.
- Added $100 / $250 / $500 / $1,000 presets plus custom whole-dollar input.
- Reset now returns to the user's selected starting bankroll.
- Existing saved/synced user state is preserved.

## Overlay v0.9.8
- Added first Axiom beta support while retaining FOMO support.
- Added shared PaperMade state across supported host platforms.
- Added Axiom token/market-context detection and reference-data fallback behavior.

## Website v4.3.2
- Fixed My Record and leaderboard loading after the universal-header migration.
- Updated site navigation to reuse the same shared Supabase/auth client as the rest of the website.

## Website v4.3.1
- Fixed the homepage universal-header stylesheet regression.
- Added Staff Center to the About menu.

## Website v4.3
- Standardized the same account/navigation header across website pages.

## Website v4.2
- Replaced the crowded navigation button row with compact dropdown menus.
- Community menu: Leaderboard, Trader Profiles, Friends.
- Tools menu: Compare Traders, P&L Cards, Install.
- About menu: GitHub & Transparency, Status + Changelog, Roadmap, Feedback / Bugs.
- Keeps the Website v4.1 staff/moderation and profile-banner features.

## Overlay v0.9.7
- Max / 100% Sell is live-linked to the current simulated position value.
- Max execution re-resolves the position immediately before the full close.
- Keeps v0.9.6 exact held-quantity and dust-free full-close behavior.

## Earlier beta builds
Earlier versions introduced paper buys/sells, live P&L, journal analytics, MFE/MAE, After-I-Sold tracking, movable/resizable UI, Solana address detection, FOMO market-cap preference, account sync, public profiles, moderation and community features.
