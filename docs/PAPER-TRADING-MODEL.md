# Paper-Trading Model

This document summarizes the core simulation rules used by PaperMade v0.9.6.

## Starting state

A PaperMade account begins with virtual cash. Paper buys reduce virtual cash and create or add to a simulated position. Paper sells increase virtual cash and record simulated realized P&L.

No blockchain transaction is constructed or signed.

## Position value

PaperMade tracks a position using a ratio between the current mark and the position's entry baseline.

While the token is being viewed inside FOMO, the visible FOMO market cap is preferred:

```text
ratio = current FOMO market cap / average FOMO entry market cap
position value = net exposure basis × ratio
```

When a fallback feed is used away from the token page, PaperMade compares that feed against the fallback-reference market cap stored at entry. This prevents a difference between two market-cap providers from becoming fake profit or loss.

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

v0.9.6 changed Sell All so the live held position itself is the source of truth.

At execution time PaperMade recalculates the live full position value and sells the exact simulated quantity held. It does not trust a stale dollar value that may have been selected before the token moved.

For a full close:

```text
paper quantity = 0
cost basis = 0
net exposure basis = 0
```

This hard-zero behavior prevents simulated dust from being left behind after Max / Sell All.

## Journal

When a position is fully closed, PaperMade records a journal entry including simulated realized P&L, return percentage, entry/exit market caps, hold time, peak return (MFE), worst return (MAE), and follow-up checkpoints where available.

## Leaderboards

Website leaderboards are intended to rank by **realized paper P&L**, not temporary open P&L. Shared flex cards are labeled as simulated/paper results.
