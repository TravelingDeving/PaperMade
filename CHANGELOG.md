# Changelog

## Website v4.8.3
- Keeps the v4.8.2 live mobile beta.
- Publishes Overlay v0.10.7 through the official install flow.
- Fixes the prior v0.10.6 nested-folder ZIP that could cause “Manifest file is missing or unreadable” after extraction.
- No new SQL is required.

## Overlay v0.10.7 — Live P&L + Markers Fix
- Active-page P&L now prefers higher-resolution live price/reference movement at all market caps instead of depending on a rounded or stale visible MC label.
- Retains platform MC for visible MC / Avg Buy MC labels.
- Restores reliable canvas/TradingView chart-surface preference before broader wrapper detection.
- Candle-aware marker geometry can no longer suppress a fresh B/S marker when its estimate falls out of bounds.
- Marker lookup survives pair/route to canonical-token address changes by falling back to the active position trade ID.
- Buy/Sell triggers an immediate on-chart marker re-render.
- Extension ZIP now places `manifest.json` directly at the extracted package root for Load unpacked.

## Website v4.6.4
- Publishes Overlay v0.10.6 through the official install flow.
- Uses the descriptive download filename `PaperMade-v0.10.6-HIGH-MC-PNL-PRECISION.zip` instead of a generic FULL-DROP-IN release name.
- Preserves Calendar, recovered leaderboard, Flex Studio image/video exports, and the working auth configuration.
- No new SQL is required.

## Overlay v0.10.6 — High-MC P&L Precision
- Fixes active P&L becoming sticky or inaccurate on roughly $1M+ market-cap tokens.
- Keeps the platform-visible MC for display/entry labels while using a higher-resolution live price/reference ratio for position valuation when the M-scale MC label is too coarse.
- Cross-checks live price and normalized reference-MC ratios; materially divergent sources fall back to the normalized reference ratio.
- Speeds the FOMO fallback market-data refresh from 5s to 2.5s.
- Existing paper positions remain compatible; no state reset is required.

## Website v4.6.3
- Restored `calendar.html` and the P&L Calendar experience.
- Added P&L Calendar back to the Tools dropdown.
- Preserved the recovered leaderboard flow and restored Flex Studio image/video P&L tooling.
- Install flow now distributes Overlay v0.10.5.
- No new SQL is required for this release.

## Overlay v0.10.5
- Enlarged and emphasized the available paper balance in the token header.
- Reworked chart Buy/Sell marker anchoring to use visible candle spacing when possible.
- B/S markers re-anchor after supported host-chart zoom, pan, resize and scroll changes.
- Removed the floating chart-trades HUD in favor of direct on-chart markers.
- Keeps the compact full-data Trade UI and existing sub-pages.

## Website v4.6.2
- Recovery release that restored Flex Studio video/PNG P&L sharing.
- Recovered leaderboard fallback behavior and the working website authentication config.
- Preserved the existing profile, community and install flows.

## Overlay v0.10.4
- Reduced the minimized overlay footprint.
- Moved the available paper balance into the token header.
- Removed the old chart-trades summary box.
- Strengthened direct on-chart B/S marker rendering.

## Website v4.4.3
- Updated the site-wide release alert to distribute Overlay v0.9.15.
- Install page now serves the v0.9.15 tracking-fix build.
- No new SQL is required for this website release.
- `papermade.xyz` is now the primary public PaperMade domain.

## Overlay v0.9.15
- Fixed sell presets so **25% / 50% / 75% / 100%** all stay live-linked to the changing position value, not only Max.
- Percentage sell execution now re-resolves the live position immediately before the paper sell.
- Manually typing a dollar amount cancels the linked percentage preset.
- Added principal-recovered / **“initials out”** P&L display logic.
- Once simulated sell proceeds recover the original paper principal, the remaining runner is shown as profit while internal accounting basis remains available for journal bookkeeping.
- Fixed a host-chart regression where a nearby UI value could win merely because it was numerically closest to the reference feed.
- Added direct Axiom token-header market-cap detection.
- Strong semantic/chart MC matches now outrank reference-feed proximity.
- Clears stale page MC/price values on token or route changes.
- Manual CA mode can use the host chart when the page is clearly showing the same token/pair.
- Added `papermade.xyz` to the extension account bridge and made it the primary login URL while keeping the old workers.dev hostname as a transition fallback.

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
