# PaperMade Mobile — QA Checklist

Use this checklist before any external TestFlight group gets the app.

## Installation / onboarding

- App installs through TestFlight without entitlement errors.
- PaperMade opens without crashing.
- First-run setup explains how to enable the Safari extension.
- App survives background/foreground transitions.
- App shows useful empty states before sync.

## Safari extension

Test each supported host independently:

- FOMO
- Axiom
- Pump.fun
- GMGN

For each host:

- PaperMade pill appears on token pages.
- Pill does not obstruct primary host navigation.
- Tapping the pill opens the bottom sheet.
- Sheet scrolls normally on a small iPhone.
- Drag/collapse control remains reachable.
- Current token/contract resolves correctly.
- Chain/symbol/price/market cap/liquidity populate.
- Navigating to a second token updates PaperMade to the new token.
- Refreshing the host page does not create duplicate overlays.

## Paper Buy

- Amount validation rejects 0/negative/NaN values.
- Buy cannot exceed available paper cash.
- Quick buttons work.
- Max uses available paper cash.
- Position appears immediately.
- Invested is correct.
- Avg Buy MC updates correctly after multiple buys.
- Position Value and Open P&L update with the live mark.
- Paper cash decreases by paper spend only.

## Paper Sell

- Sell mode is visibly red.
- 25/50/75/100% buttons calculate from current position value.
- Max closes the paper position exactly.
- Partial sell leaves the correct remaining paper basis.
- Full sell creates a closed journal entry.
- Full sell updates the P&L calendar ledger.
- Realized P&L is consistent with the position math.
- No simulated dust remains after Sell All.

## Sync

- Sign into papermade.xyz in Safari.
- Extension reports PaperMade sync connected.
- Desktop state appears on mobile after sync.
- Mobile paper buy appears on desktop after sync.
- Mobile paper sell appears on desktop after sync.
- Stale logged-out Safari tabs do not clear a valid session.
- Explicit logout clears the session.
- Closing/reopening the app preserves shared state.

## Native app

- Positions matches synced open positions.
- Journal matches synced closed trades.
- Calendar matches persistent calendarDays ledger.
- Leaderboard loads and scrolls.
- Profile loads.
- Achievements load.
- Flex image card renders.
- iOS share sheet works.
- Every P&L share asset clearly identifies simulated results.

## Safety

- No seed phrase prompt exists anywhere.
- No private key prompt exists anywhere.
- No wallet signing request exists anywhere.
- No real blockchain transaction can be initiated.
- PaperMade remains clearly identified as a simulator.

## Release gate

Do not move to external TestFlight until:

- all four host adapters pass basic token navigation tests;
- account sync passes both directions;
- Sell All / journal / calendar are correct;
- no launch-blocking crashes remain;
- privacy answers match actual production behavior.
