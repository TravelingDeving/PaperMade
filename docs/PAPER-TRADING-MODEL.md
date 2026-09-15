# Paper-Trading Model

This document summarizes the core simulation rules used by PaperMade v0.9.15.

## Starting state

Brand-new PaperMade accounts default to **$100** of virtual cash. Users may choose a starting bankroll from **$100 to $1,000**.

Changing the starting bankroll resets the current paper record; existing saved/synced accounts are not silently overwritten just because the default changed.

Paper buys reduce virtual cash and create or add to a simulated position. Paper sells increase virtual cash and record simulated realized P&L.

No blockchain transaction is constructed or signed.

## Supported host platforms

The current private-beta overlay supports FOMO and Axiom.

Axiom pages may expose a pool/pair address instead of the canonical token contract. PaperMade resolves that public pair context into a token address before keying the simulated position so the same token is not duplicated merely because it was viewed on a different host platform.

For early Solana mints, PaperMade can also fall back to public Jupiter token/price data when a normal indexed DEX pair is not yet available.

## Position value

PaperMade tracks a position using a ratio between the current mark and the position's entry baseline.

When a valid host-platform market cap is available:

```text
ratio = current host market cap / average host entry market cap
position value = net exposure basis × ratio
```

When a fallback/reference feed is used, PaperMade compares that feed against the fallback/reference market cap stored at entry. This prevents a difference between market-cap providers from automatically becoming fake profit or loss.

## Market-data sanity guard

PaperMade cross-checks weak or ambiguous host-page market-cap candidates against the resolved reference feed.

v0.9.15 changes the selection order so a strong semantic/chart value outranks an unrelated nearby dollar figure merely because that unrelated value is numerically closer to the reference feed. Axiom's token-header market cap is detected directly when possible.

Stale host-page MC/price values are cleared on token/route changes. This prevents one token's visible data from being carried into another token's simulated position.

PaperMade also checks source-scale drift to protect against extreme DOM scrape failures. The purpose is to prevent a UI parsing mistake — for example accidentally reading a multi-million-dollar unrelated value on a token trading around a few thousand dollars of market cap — from creating fake five-figure paper profit.

See [DATA-INTEGRITY.md](DATA-INTEGRITY.md).

## Open P&L and “initials out”

PaperMade keeps two concepts separate:

1. **Internal accounting cost basis**, used for realized P&L and the journal.
2. **Remaining principal**, used for the live learner-facing P&L display.

Simulated sell proceeds recover remaining principal first for the display.

```text
remaining principal = max(0, original paper capital added - net sell proceeds recovered)
visible open profit = current position value - remaining principal
visible return % = visible open profit / total paper capital added × 100
```

Before any sell, this behaves like normal open P&L.

Example:

- Paper buy: $100
- Position grows to $200
- Paper sell: $100
- Remaining runner value: $100
- Remaining principal: $0

The live display becomes:

```text
$100 position (+100%) +$100
```

The remaining bag is therefore shown as profit after the original paper principal has been recovered, while the internal accounting basis is still retained for accurate journal bookkeeping.

## Avg Buy MC

AVG BUY MC is dollar-weighted across paper buys, not a simple arithmetic average.

For an existing position:

```text
new avg buy MC =
(old avg buy MC × old cost + new buy MC × new buy amount)
/ new total cost
```

Example:

- $100 paper buy at $300K MC
- $300 paper buy at $500K MC

The average buy MC is $450K, because the second buy had three times the dollar weight.

## Fees and slippage

PaperMade does not invent a platform fee. A fee is only simulated when the host page exposes a detectable fee setting.

Slippage is treated as a tolerance/displayed setting, not automatically deducted as if it were always paid.

## Partial sells

Internal accounting still removes the same fraction of cost basis, exposure basis, and held paper quantity for a partial sell.

Realized accounting P&L is:

```text
net simulated proceeds - removed accounting cost basis
```

Separately, the learner-facing remaining-principal display subtracts net sell proceeds from unrecovered principal first.

## Live sell percentage presets

v0.9.15 treats 25%, 50%, 75%, and 100% / Max as **live percentage intents**, not frozen dollar quotes.

If a 25% sell is selected while the position is worth $100, the visible sell amount is $25. If the position then moves to $120 before execution, the selected sell amount updates to $30.

At execution time PaperMade resolves the selected percentage again from the current simulated position value.

Manually typing a dollar amount cancels the linked percentage preset.

## Sell All / Max

Max / 100% Sell uses the live held paper position as the source of truth.

At execution time PaperMade recalculates the live full position value and sells the exact simulated quantity held. It does not trust a stale dollar value selected before the token moved.

For a full close:

```text
paper quantity = 0
cost basis = 0
net exposure basis = 0
remaining principal = 0
```

This hard-zero behavior prevents simulated dust from being left behind after Max / Sell All.

## Journal

When a position is fully closed, PaperMade records a journal entry including simulated realized P&L, return percentage, entry/exit market caps, hold time, peak return (MFE), worst return (MAE), and follow-up checkpoints where available.

## High-confidence historical repair

PaperMade can repair an existing journal result only when the data looks like a very high-confidence source-scale failure rather than an ordinary large meme-coin move.

The repair requires both extreme platform/reference scale drift and an extreme recorded return. A repaired record is tagged so the same repair cannot be applied twice. If an obviously corrupted extreme MFE/captured-profit value was caused by the same bad mark, that value is also cleared/rebased.

## Profiles and achievements

The website can derive achievements from synchronized paper-trading records. Users can choose which earned badges to feature, but performance achievements are intended to be server-derived rather than self-awarded.

Performance-derived achievements are revalidated after corrected paper-state data syncs so an invalid market-data spike should not leave a false return badge behind.

## Leaderboards

Current community leaderboards use simulated closed-trade/account records. Shared leaderboard rows, achievements, and flex cards represent **paper/simulated results**, not real-money performance.

Because PaperMade supports different starting bankrolls, bankroll-normalized leaderboard views are planned to improve fairness across users starting with different virtual balances.
