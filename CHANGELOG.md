# Changelog

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
- After selecting Max, the visible sell amount updates as the position value changes.
- Max execution re-resolves the position immediately before the full close.
- Manual dollar input cancels Max mode as before.
- Keeps v0.9.6 exact held-quantity and dust-free full-close behavior.

## Website v4.1
- Added persistent product/community navigation across the major website pages.
- Added public profile banner uploads with a dedicated Supabase Storage bucket.
- Added a PaperMade Staff Center for reviewing the full feedback queue.
- Added owner-controlled moderator access by approved Discord username.
- Moderators can move reports through new, reviewing, planned, fixed, and closed states.
- Tightened public-profile privacy so anonymous users use sanitized RPC output instead of direct profile-table reads.

## Website v4.0
- Added public trader profiles.
- Added Friends and friend requests.
- Added trader comparison.
- Added install/download, transparency, roadmap, status, and feedback pages.
- Added feedback submission storage for approved testers.

## v0.9.6
- Sell All / Max now uses the live held paper position as the source of truth.
- Full closes sell the exact paper-token quantity held.
- Sell preview shows live held value and token quantity.
- Full closes hard-zero simulated quantity/cost/exposure to avoid residual dust.

## v0.9.5
- Fixed minimize so PaperMade collapses to the header only.
- Minimized/expanded state persists.
- Restores the user's prior expanded height.

## v0.9.4
- Fixed Fast Buy enable/disable and persistence.
- Fixed editable Sell percentage presets.
- Open P&L left value now reflects the live position value.
- Improved Max-sell full-close behavior.

## v0.9.3
- Replaced the mistaken Avg P&L token stat with Avg Buy MC.
- Added editable Buy and Sell quick presets.

## v0.9.2
- Account status displays the approved Discord username when available.

## v0.9.0–v0.9.1
- Added Discord-gated private-beta access.
- Added account sync.
- Added Avg Buy/P&L presentation refinements and consolidated prior beta fixes.

## Earlier beta builds
Earlier versions introduced paper buys/sells, live P&L, journal analytics, MFE/MAE, After-I-Sold tracking, movable/resizable UI, Solana address detection, FOMO market-cap preference, and trade controls.
