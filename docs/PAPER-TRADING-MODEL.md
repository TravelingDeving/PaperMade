# Paper-Trading Model

This document summarizes the core simulation rules used by PaperMade v0.9.13.

## Starting state

Brand-new PaperMade accounts default to **$100** of virtual cash. Users may choose a starting bankroll from **$100 to $1,000**.

Changing the starting bankroll resets the current paper record; existing saved/synced accounts are not silently overwritten just because the default changed.

Paper buys reduce virtual cash and create or add to a simulated position. Paper sells increase virtual cash and record simulated realized P&L.

No blockchain transaction is constructed or signed.

## Supported host platforms

The current private-beta overlay supports FOMO and Axiom.

Axiom pages may expose a pool/pair address instead of the canonical token contract. PaperMade resolves that public pair context into a token address before keying the simulated position so the same token is not duplicated merely because it was viewed on a different host platform.

## Position value

PaperMade tracks a position using a ratio between the current mark and the position's entry baseline.

When a valid host-platform market cap is available:

```text
ratio = current host market cap / average host entry market cap
position value = net exposure basis × ratio
```

When a fallback/reference feed is used, PaperMade compares that feed against the fallback/reference market cap stored at entry. This prevents a difference between market-cap providers from automatically becoming fake profit or loss.

## Market-data sanity guard

PaperMade v0.9.13 cross-checks visible host-page market-cap candidates against the resolved reference feed.

A page can contain many unrelated numbers near labels such as Market Cap / Price. If a candidate is implausibly far from the resolved token reference market cap, PaperMade rejects that candidate and falls back to normalized reference data.

PaperMade also checks **source-scale drift**. If the relationship between host-platform MC and reference MC changes drastically compared with the relationship captured at entry, the host mark is not trusted for P&L.

The purpose of this guard is to prevent a DOM scrape mistake — for example accidentally reading a multi-million-dollar UI value on a token trading around a few thousand dollars of market cap — from creating fake five-figure paper profit.

See [DATA-INTEGRITY.md](DATA-INTEGRITY.md).

## Open P&L

```text
Open P&L $ = current paper position value - cost basis
Open P&L % = Open P&L $ / cost basis × 100
```

The large Open P&L display shows:

```text
CURRENT POSITION VALUE (RETURN %) +/- DOLLAR P&L
```

Example:

```text
$502.28 (-16.29%) -$97.72
```

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

For a partial paper sell, PaperMade removes the same fraction of cost basis, exposure basis, and held paper quantity.

Realized P&L is:

```text
net simulated proceeds - removed cost basis
```

## Sell All / Max

Max / 100% Sell uses the live held paper position as the source of truth.

At execution time PaperMade recalculates the live full position value and sells the exact simulated quantity held. It does not trust a stale dollar value selected before the token moved.

For a full close:

```text
paper quantity = 0
cost basis = 0
net exposure basis = 0
```

This hard-zero behavior prevents simulated dust from being left behind after Max / Sell All.

## Journal

When a position is fully closed, PaperMade records a journal entry including simulated realized P&L, return percentage, entry/exit market caps, hold time, peak return (MFE), worst return (MAE), and follow-up checkpoints where available.

## High-confidence historical repair

v0.9.13 can repair an existing journal result only when the data looks like a very high-confidence source-scale failure rather than an ordinary large meme-coin move.

The current repair requires both:

- extreme platform/reference scale drift; and
- an extreme recorded return.

A repaired record is tagged so the same repair cannot be applied twice. If an obviously corrupted extreme MFE/captured-profit value was caused by the same bad mark, that value is also cleared/rebased.

## Profiles and achievements

The website can derive achievements from synchronized paper-trading records. Users can choose which earned badges to feature, but performance achievements are intended to be server-derived rather than self-awarded.

Website v4.4.1 revalidates performance-derived achievements after corrected paper-state data syncs, so an invalid market-data spike should not leave a false +50%/+100% style achievement behind.

## Leaderboards

Current community leaderboards use simulated closed-trade/account records. Shared leaderboard rows, achievements, and flex cards represent **paper/simulated results**, not real-money performance.

Because PaperMade now supports different starting bankrolls, bankroll-normalized leaderboard views are planned to improve fairness across users starting with different virtual balances.
