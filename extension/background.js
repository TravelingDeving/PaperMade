const STORAGE_KEY = "fomoPaperStateV01";
const AFTER_EXIT_ALARM = "fomoPaperAfterExit";
const CHECKPOINTS = {
  m5: 5,
  m15: 15,
  m30: 30,
  h1: 60
};

async function fetchToken(address) {
  const encoded = encodeURIComponent(String(address || "").trim());
  if (!encoded) throw new Error("Missing token contract.");

  const response = await fetch(`https://api.dexscreener.com/latest/dex/tokens/${encoded}`);
  if (!response.ok) throw new Error(`Market data request failed (${response.status})`);

  const data = await response.json();
  const pairs = Array.isArray(data?.pairs) ? data.pairs : [];
  if (!pairs.length) throw new Error("No live pair found for this contract.");

  pairs.sort((a, b) => (b?.liquidity?.usd || 0) - (a?.liquidity?.usd || 0));
  const p = pairs[0];

  return {
    address: p?.baseToken?.address || address,
    name: p?.baseToken?.name || "Unknown token",
    symbol: p?.baseToken?.symbol || "TOKEN",
    chainId: p?.chainId || "",
    dexId: p?.dexId || "",
    priceUsd: Number(p?.priceUsd || 0),
    marketCap: Number(p?.marketCap || p?.fdv || 0),
    fdv: Number(p?.fdv || 0),
    liquidityUsd: Number(p?.liquidity?.usd || 0),
    pairAddress: p?.pairAddress || "",
    pairUrl: p?.url || ""
  };
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type !== "FETCH_TOKEN" || !message.address) return;

  fetchToken(message.address)
    .then(token => sendResponse({ ok: true, token }))
    .catch(err => sendResponse({ ok: false, error: err.message || String(err) }));

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
  if (!state || !Array.isArray(state.journal) || !state.journal.length) return;

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
      const token = await fetchToken(address);
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
    } catch (_) {}
  }

  if (changed) {
    await chrome.storage.local.set({ [STORAGE_KEY]: state });
    try { await pushPaperState(state); } catch (_) {}
  }
}

chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === AFTER_EXIT_ALARM) {
    updateAfterExitJournal().catch(() => {});
  }
});

// Private-beta account-sync transport is intentionally excluded from the
// public snapshot while the authentication bridge receives a security review.
// Public trading behavior and UI logic live in content.js and overlay.css.
