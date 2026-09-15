const STORAGE_KEY = "fomoPaperStateV01";
const AFTER_EXIT_ALARM = "fomoPaperAfterExit";

const CHECKPOINTS = {
  m5: 5,
  m15: 15,
  m30: 30,
  h1: 60
};

const COMMON_QUOTE_SYMBOLS = new Set([
  "SOL", "WSOL",
  "ETH", "WETH",
  "BNB", "WBNB",
  "USDC", "USDT", "USDS", "DAI",
  "USD1", "USDG"
]);

function tokenFromPair(pair, fallbackAddress = "", preferredSide = "base") {
  const base = pair?.baseToken || {};
  const quote = pair?.quoteToken || {};
  const chosen = preferredSide === "quote" ? quote : base;

  return {
    address: chosen?.address || fallbackAddress,
    name: chosen?.name || "Unknown token",
    symbol: chosen?.symbol || "TOKEN",
    chainId: pair?.chainId || "",
    dexId: pair?.dexId || "",
    priceUsd: Number(pair?.priceUsd || 0),
    marketCap: Number(pair?.marketCap || pair?.fdv || 0),
    fdv: Number(pair?.fdv || 0),
    liquidityUsd: Number(pair?.liquidity?.usd || 0),
    pairAddress: pair?.pairAddress || "",
    pairUrl: pair?.url || ""
  };
}

async function fetchPairsForToken(address) {
  const encoded = encodeURIComponent(String(address || "").trim());
  if (!encoded) throw new Error("Missing token contract.");

  const response = await fetch(
    `https://api.dexscreener.com/latest/dex/tokens/${encoded}`
  );

  if (!response.ok) {
    throw new Error(`Market data request failed (${response.status})`);
  }

  const data = await response.json();
  return Array.isArray(data?.pairs) ? data.pairs : [];
}

function chooseTradedSide(pair) {
  const base = pair?.baseToken || {};
  const quote = pair?.quoteToken || {};

  const baseCommon = COMMON_QUOTE_SYMBOLS.has(
    String(base?.symbol || "").toUpperCase()
  );
  const quoteCommon = COMMON_QUOTE_SYMBOLS.has(
    String(quote?.symbol || "").toUpperCase()
  );

  if (baseCommon && !quoteCommon) return "quote";
  return "base";
}

async function resolvePairAcrossChains(pairAddress) {
  const clean = String(pairAddress || "").trim();
  if (!clean) return null;

  // Axiom may place a DEX pool/pair address in the route rather than the token
  // contract itself. DexScreener search is used here as a chain-agnostic pair
  // resolver so PaperMade can map that pool back to a canonical token address.
  const encoded = encodeURIComponent(clean);
  const response = await fetch(
    `https://api.dexscreener.com/latest/dex/search?q=${encoded}`
  );

  if (!response.ok) return null;

  const data = await response.json();
  const pairs = Array.isArray(data?.pairs) ? data.pairs : [];
  if (!pairs.length) return null;

  const lower = clean.toLowerCase();

  let pair = pairs.find(
    candidate => String(candidate?.pairAddress || "").toLowerCase() === lower
  );

  if (!pair) {
    pair = pairs
      .slice()
      .sort(
        (a, b) =>
          Number(b?.liquidity?.usd || 0) -
          Number(a?.liquidity?.usd || 0)
      )[0];
  }

  if (!pair) return null;

  const side = chooseTradedSide(pair);
  const chosen = side === "quote" ? pair?.quoteToken : pair?.baseToken;
  const tokenAddress = chosen?.address || "";
  if (!tokenAddress) return null;

  // Re-query by canonical token address and prefer the highest-liquidity pair.
  try {
    const tokenPairs = await fetchPairsForToken(tokenAddress);
    if (tokenPairs.length) {
      tokenPairs.sort(
        (a, b) =>
          Number(b?.liquidity?.usd || 0) -
          Number(a?.liquidity?.usd || 0)
      );

      const best = tokenPairs[0];
      const bestBase = String(best?.baseToken?.address || "").toLowerCase();
      const tokenLower = tokenAddress.toLowerCase();

      return tokenFromPair(
        best,
        tokenAddress,
        bestBase === tokenLower ? "base" : "quote"
      );
    }
  } catch (_) {}

  return tokenFromPair(pair, tokenAddress, side);
}

async function fetchToken(address, { allowPairLookup = false } = {}) {
  const clean = String(address || "").trim();
  if (!clean) throw new Error("Missing token contract.");

  let pairs = [];

  try {
    pairs = await fetchPairsForToken(clean);
  } catch (error) {
    if (!allowPairLookup) throw error;
  }

  if (pairs.length) {
    pairs.sort(
      (a, b) =>
        Number(b?.liquidity?.usd || 0) -
        Number(a?.liquidity?.usd || 0)
    );

    return {
      token: tokenFromPair(pairs[0], clean),
      resolvedFromPair: false
    };
  }

  if (allowPairLookup) {
    const resolved = await resolvePairAcrossChains(clean);
    if (resolved) {
      return {
        token: resolved,
        resolvedFromPair: true
      };
    }
  }

  throw new Error("No live token or supported pair found.");
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type !== "FETCH_TOKEN" || !message.address) return;

  fetchToken(message.address, {
    allowPairLookup: Boolean(message.allowPairLookup)
  })
    .then(result => sendResponse({ ok: true, ...result }))
    .catch(error =>
      sendResponse({
        ok: false,
        error: error.message || String(error)
      })
    );

  return true;
});

function ensureAfterExitAlarm() {
  chrome.alarms.create(AFTER_EXIT_ALARM, { periodInMinutes: 1 });
}

chrome.runtime.onInstalled.addListener(ensureAfterExitAlarm);
chrome.runtime.onStartup.addListener(ensureAfterExitAlarm);
ensureAfterExitAlarm();

async function updateAfterExitJournal() {
  const stored = await chrome.storage.local.get(STORAGE_KEY);
  const state = stored?.[STORAGE_KEY];

  if (!state || !Array.isArray(state.journal) || !state.journal.length) {
    return;
  }

  const now = Date.now();
  let changed = false;

  const pendingEntries = state.journal.filter(entry => {
    if (!entry?.exitAt || entry.afterExitComplete) return false;
    const after = entry.afterExit || {};
    return Object.keys(CHECKPOINTS).some(key => !after[key]);
  });

  const byAddress = new Map();

  for (const entry of pendingEntries) {
    const due = Object.entries(CHECKPOINTS).filter(([key, minutes]) => {
      if (entry.afterExit?.[key]) return false;
      return now >= Number(entry.exitAt) + minutes * 60_000;
    });

    if (!due.length) continue;

    if (!byAddress.has(entry.address)) byAddress.set(entry.address, []);
    byAddress.get(entry.address).push({ entry, due });
  }

  for (const [address, jobs] of byAddress.entries()) {
    try {
      const result = await fetchToken(address);
      const token = result.token;
      const liveReferenceMc = Number(token.marketCap || 0);

      for (const { entry, due } of jobs) {
        if (!entry.afterExit) entry.afterExit = {};

        const exitMc = Number(entry.exitMc || 0);
        const exitReferenceMc = Number(entry.exitReferenceMc || 0);

        let normalizedMc = liveReferenceMc;
        if (exitMc > 0 && exitReferenceMc > 0 && liveReferenceMc > 0) {
          normalizedMc = exitMc * (liveReferenceMc / exitReferenceMc);
        }

        const changePercent = exitMc > 0
          ? ((normalizedMc / exitMc) - 1) * 100
          : 0;

        for (const [key, minutes] of due) {
          entry.afterExit[key] = {
            targetMinutes: minutes,
            marketCap: normalizedMc,
            referenceMarketCap: liveReferenceMc,
            changePercent,
            capturedAt: now
          };
          changed = true;
        }

        entry.afterExitComplete = Object.keys(CHECKPOINTS)
          .every(key => Boolean(entry.afterExit?.[key]));
      }
    } catch (_) {
      // Keep the checkpoint pending and retry on the next alarm.
    }
  }

  if (changed) {
    await chrome.storage.local.set({ [STORAGE_KEY]: state });

    // Private-beta account-sync transport is intentionally excluded from the
    // public snapshot while the authentication bridge receives security review.
  }
}

chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === AFTER_EXIT_ALARM) {
    updateAfterExitJournal().catch(() => {});
  }
});

// Public snapshot note:
// v0.9.13's host-page market-cap sanity checks and conservative historical
// spike-repair logic live in the production content-script layer. The private
// auth/session transport and full production UI bundle are intentionally not
// included in this inspection snapshot yet.
