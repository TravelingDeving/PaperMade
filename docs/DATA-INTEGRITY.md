# Market-Data Integrity

PaperMade is a simulator, so bad market data can create bad simulated results even when no real money is at risk. This document describes the safeguards added in Overlay v0.9.13.

## Why the guard exists

Trading pages contain many unrelated numeric values: market cap, price, liquidity, volume, wallet balances, fee values, chart labels, rankings, and other UI statistics.

A DOM scraper can occasionally see the wrong number near a market-cap label. If that value were accepted without validation, a token trading around a few thousand dollars of market cap could briefly look like it was worth millions and create fake paper profit.

## Reference feed

PaperMade uses the supported host page as the preferred visible market source when that value is trustworthy. DexScreener is used as a public fallback/reference source.

For Axiom, the route may contain a pool/pair address instead of the token contract. PaperMade can resolve that pair across chains and convert it into a canonical token address before using it as a paper-position key.

## Candidate validation

When PaperMade finds market-cap candidates in the host page, v0.9.13 compares them with the resolved token's reference market cap.

A candidate that is too far from the reference scale is rejected instead of being used for simulated P&L.

This is not intended to force the two data sources to be identical. Different sources can legitimately show different values. The check exists to catch obvious scale mistakes.

## Source-scale drift

At entry, PaperMade can store both:

- the market cap shown by the host platform; and
- the reference market cap from the fallback feed.

Later, PaperMade compares the relationship between those two values with the current relationship.

If the host/reference scale suddenly changes by an extreme amount, the host mark is treated as unsafe for paper P&L and PaperMade falls back to the normalized reference feed.

## Normalized fallback

When a reference feed is used, PaperMade can project the reference move back onto the host-platform entry scale:

```text
normalized current MC =
entry host MC × (current reference MC / entry reference MC)
```

This keeps a provider-to-provider scale difference from automatically becoming profit or loss.

## Historical repair

Overlay v0.9.13 contains a conservative repair path for already-recorded results that strongly resemble a source-scale failure.

The repair requires both:

- extreme host/reference scale drift; and
- an extreme recorded paper return.

It is deliberately not a general 'undo a bad trade' feature.

When a qualifying record is repaired:

- simulated proceeds/P&L are recalculated from the reference move;
- paper cash is corrected;
- the journal row is tagged so the repair cannot run twice;
- obviously corrupted extreme MFE/captured-profit values from the same spike are cleared/rebased; and
- corrected state can be synced back to the PaperMade account.

## Achievement integrity

Website v4.4.1 revalidates performance-derived achievements after paper-state updates. This is meant to prevent a corrected data spike from leaving behind a false +25%, +50%, +100%, win-streak, or similar performance badge.

Special/manual-status badges such as owner, moderator, or OG Beta Tester are not removed by that performance revalidation.

## Scope

These safeguards protect **simulated PaperMade statistics**. They do not make PaperMade a source of execution-grade pricing and do not turn PaperMade into a real-money trading system.

PaperMade remains paper trading only.
