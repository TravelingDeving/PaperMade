# Changelog

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
