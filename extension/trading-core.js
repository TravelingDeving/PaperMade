// PaperMade v0.10.7 — public trading-math snapshot
//
// This file documents the core simulated position math used by the private-beta
// overlay. It contains no wallet signing, blockchain transaction construction,
// or custody logic because PaperMade does not execute real trades.

export function normalizeQuickBuys(values, defaults = [3, 5, 10, 15]) {
  const list = Array.isArray(values) ? values : [];
  const cleaned = list
    .map(Number)
    .filter(v => Number.isFinite(v) && v > 0)
    .slice(0, 4);

  while (cleaned.length < 4) cleaned.push(defaults[cleaned.length]);
  return cleaned;
}

export function normalizeQuickSells(values, defaults = [25, 50, 75, 100]) {
  const list = Array.isArray(values) ? values : [];
  const cleaned = list
    .map(Number)
    .filter(v => Number.isFinite(v) && v > 0 && v <= 100)
    .slice(0, 4);

  while (cleaned.length < 4) cleaned.push(defaults[cleaned.length]);
  return cleaned;
}

export function mirroredFeeFor(notional, detectedFee = {}) {
  const n = Number(notional || 0);
  if (!Number.isFinite(n) || n <= 0) return 0;

  // PaperMade does not invent a platform fee. A fee is only mirrored when the
  // host trading page exposes one to the learner.
  if (Number.isFinite(detectedFee.percent) && detectedFee.percent >= 0) {
    return Math.min(n, n * (detectedFee.percent / 100));
  }

  if (Number.isFinite(detectedFee.usd) && detectedFee.usd >= 0) {
    return Math.min(n, detectedFee.usd);
  }

  return 0;
}

function validTrackingRatio(value) {
  value = Number(value || 0);
  return Number.isFinite(value) && value > 0 && value < 1000;
}

function ratioDivergence(a, b) {
  if (!validTrackingRatio(a) || !validTrackingRatio(b)) return Infinity;
  return Math.max(a / b, b / a);
}

export function positionMetrics(pos, mark) {
  if (!pos || !pos.costBasis) {
    return { value: 0, usd: 0, percent: 0, ratio: 1, trackingSource: "none" };
  }

  const currentPrice = Number(mark?.priceUsd || 0);
  const currentMc = Number(mark?.marketCap || 0);
  const referenceMc = Number(mark?.referenceMarketCap || 0);
  const entryPrice = Number(pos.avgEntryPrice || 0);
  const displayEntryMc = Number(pos.avgEntryMc || 0);
  const referenceEntryMc = Number(pos.avgReferenceMc || 0);
  const markSource = String(mark?.markSource || "");

  const displayMcRatio =
    currentMc > 0 && displayEntryMc > 0
      ? currentMc / displayEntryMc
      : 0;

  const priceRatio =
    currentPrice > 0 && entryPrice > 0
      ? currentPrice / entryPrice
      : 0;

  const referenceRatio =
    referenceMc > 0 && referenceEntryMc > 0
      ? referenceMc / referenceEntryMc
      : 0;

  const isHostChart = / chart$/i.test(markSource);

  let ratio = 1;
  let trackingSource = "entry";

  if (isHostChart) {
    if (validTrackingRatio(priceRatio) && validTrackingRatio(referenceRatio)) {
      if (ratioDivergence(priceRatio, referenceRatio) <= 1.15) {
        ratio = priceRatio;
        trackingSource = "live price";
      } else if (validTrackingRatio(displayMcRatio)) {
        const priceVsMc = ratioDivergence(priceRatio, displayMcRatio);
        const refVsMc = ratioDivergence(referenceRatio, displayMcRatio);
        if (priceVsMc <= 1.15 && priceVsMc <= refVsMc) {
          ratio = priceRatio;
          trackingSource = "live price";
        } else if (refVsMc <= 1.15) {
          ratio = referenceRatio;
          trackingSource = "reference MC";
        } else {
          ratio = referenceRatio;
          trackingSource = "reference MC";
        }
      } else {
        ratio = referenceRatio;
        trackingSource = "reference MC";
      }
    } else if (validTrackingRatio(priceRatio)) {
      ratio = priceRatio;
      trackingSource = "live price";
    } else if (validTrackingRatio(referenceRatio)) {
      ratio = referenceRatio;
      trackingSource = "reference MC";
    } else if (validTrackingRatio(displayMcRatio)) {
      ratio = displayMcRatio;
      trackingSource = "platform MC";
    }
  } else if (validTrackingRatio(referenceRatio)) {
    ratio = referenceRatio;
    trackingSource = "reference MC";
  } else if (
    currentMc > 0 &&
    referenceEntryMc > 0 &&
    validTrackingRatio(currentMc / referenceEntryMc)
  ) {
    ratio = currentMc / referenceEntryMc;
    trackingSource = "fallback MC";
  } else if (validTrackingRatio(priceRatio)) {
    ratio = priceRatio;
    trackingSource = "live price";
  } else if (validTrackingRatio(displayMcRatio)) {
    ratio = displayMcRatio;
    trackingSource = "display MC";
  }

  if (!Number.isFinite(ratio) || ratio <= 0) ratio = 1;

  const exposureBasis = Number(pos.netExposureBasis ?? pos.costBasis);
  const value = exposureBasis * ratio;
  const usd = value - Number(pos.costBasis || 0);
  const percent = pos.costBasis ? (usd / pos.costBasis) * 100 : 0;

  return { value, usd, percent, ratio, trackingSource };
}

export function applyPaperBuy(existing, {
  spend,
  priceUsd,
  marketCap,
  referenceMarketCap,
  detectedFee = {},
  now = Date.now()
}) {
  const amount = Number(spend);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Paper buy must be above zero.");
  }

  const fee = mirroredFeeFor(amount, detectedFee);
  const netExposure = Math.max(0, amount - fee);
  if (netExposure <= 0) {
    throw new Error("Detected fee would consume the paper order.");
  }

  const price = Number(priceUsd || 0);
  const qty = price > 0 ? netExposure / price : 0;
  const entryMc = Number(marketCap || 0);
  const referenceMc = Number(referenceMarketCap || 0);

  const pos = existing ? { ...existing } : {
    qty: 0,
    costBasis: 0,
    netExposureBasis: 0,
    avgEntryPrice: 0,
    avgEntryMc: 0,
    avgReferenceMc: 0,
    feesPaid: 0,
    totalCostAdded: 0,
    totalRealizedPnl: 0,
    totalSellProceeds: 0,
    maxPnlPercent: 0,
    minPnlPercent: 0,
    highestMc: entryMc || 0,
    lowestMc: entryMc || 0,
    firstEntryAt: now
  };

  const oldSpend = Number(pos.costBasis || 0);
  const oldExposure = Number(pos.netExposureBasis ?? pos.costBasis || 0);
  const newCost = oldSpend + amount;
  const newExposure = oldExposure + netExposure;
  const newQty = Number(pos.qty || 0) + qty;

  pos.qty = newQty;
  pos.costBasis = newCost;
  pos.netExposureBasis = newExposure;
  pos.feesPaid = Number(pos.feesPaid || 0) + fee;
  pos.totalCostAdded = Number(pos.totalCostAdded || 0) + amount;

  if (newQty > 0 && price > 0) {
    pos.avgEntryPrice = newExposure / newQty;
  }

  // AVG BUY MC is dollar-weighted across the actual paper buys.
  if (entryMc > 0) {
    pos.avgEntryMc = newCost > 0
      ? (((Number(pos.avgEntryMc || 0) * oldSpend) + (entryMc * amount)) / newCost)
      : entryMc;
  }

  // Keep a separate fallback-feed baseline for off-page normalization.
  if (referenceMc > 0) {
    pos.avgReferenceMc = newCost > 0
      ? (((Number(pos.avgReferenceMc || 0) * oldSpend) + (referenceMc * amount)) / newCost)
      : referenceMc;
  }

  return {
    position: pos,
    cashDelta: -amount,
    trade: {
      type: "BUY",
      usd: amount,
      netExposure,
      fee,
      qty,
      price,
      marketCap: entryMc,
      referenceMarketCap: referenceMc,
      at: now
    }
  };
}

export function applyPaperSell(pos, mark, {
  fraction,
  detectedFee = {},
  now = Date.now()
}) {
  if (!pos || Number(pos.costBasis || 0) <= 0) {
    throw new Error("No paper position to sell.");
  }

  const sellFraction = Math.min(1, Math.max(0, Number(fraction)));
  const hardClose = sellFraction >= 0.999999;
  const metrics = positionMetrics(pos, mark);

  // v0.9.6: Sell All uses the held paper position itself as the source of truth.
  // It does not trust a stale dollar amount from the sell input.
  const heldQtyBefore = Math.max(0, Number(pos.qty || 0));
  const grossProceeds = hardClose
    ? Math.max(0, Number(metrics.value || 0))
    : Math.max(0, Number(metrics.value || 0) * sellFraction);

  const fee = mirroredFeeFor(grossProceeds, detectedFee);
  const netProceeds = Math.max(0, grossProceeds - fee);

  const costBefore = Number(pos.costBasis || 0);
  const exposureBefore = Number(pos.netExposureBasis ?? pos.costBasis);
  const costRemoved = hardClose ? costBefore : costBefore * sellFraction;
  const exposureRemoved = hardClose ? exposureBefore : exposureBefore * sellFraction;
  const qtySold = hardClose ? heldQtyBefore : heldQtyBefore * sellFraction;
  const realizedPnl = netProceeds - costRemoved;

  const next = { ...pos };
  next.totalRealizedPnl = Number(next.totalRealizedPnl || 0) + realizedPnl;
  next.totalSellProceeds = Number(next.totalSellProceeds || 0) + netProceeds;
  next.feesPaid = Number(next.feesPaid || 0) + fee;

  if (hardClose) {
    // Exact zeroing prevents simulated dust after a Max / Sell All.
    next.costBasis = 0;
    next.netExposureBasis = 0;
    next.qty = 0;
  } else {
    next.costBasis = Math.max(0, costBefore - costRemoved);
    next.netExposureBasis = Math.max(0, exposureBefore - exposureRemoved);
    next.qty = Math.max(0, heldQtyBefore - qtySold);
  }

  return {
    position: next,
    fullyClosed: hardClose || next.costBasis < 0.000001,
    cashDelta: netProceeds,
    trade: {
      type: "SELL",
      grossProceeds,
      usd: netProceeds,
      fee,
      qty: qtySold,
      price: Number(mark?.priceUsd || 0),
      realizedPnl,
      at: now
    }
  };
}
