const api = globalThis.browser || globalThis.chrome;

const COMMON_QUOTES = new Set(["SOL","WSOL","ETH","WETH","BNB","WBNB","USDC","USDT","USDS","DAI"]);

function chooseSide(pair) {
  const base = String(pair?.baseToken?.symbol || "").toUpperCase();
  const quote = String(pair?.quoteToken?.symbol || "").toUpperCase();
  if (COMMON_QUOTES.has(base) && !COMMON_QUOTES.has(quote)) return "quote";
  return "base";
}

function tokenFromPair(pair, side = "base") {
  const token = side === "quote" ? pair?.quoteToken : pair?.baseToken;
  return {
    address: token?.address || "",
    symbol: token?.symbol || "TOKEN",
    name: token?.name || "Unknown token",
    chainId: pair?.chainId || "",
    priceUsd: Number(pair?.priceUsd || 0),
    marketCap: Number(pair?.marketCap || pair?.fdv || 0),
    liquidityUsd: Number(pair?.liquidity?.usd || 0),
    pairAddress: pair?.pairAddress || ""
  };
}

async function fetchByToken(address) {
  const url = `https://api.dexscreener.com/latest/dex/tokens/${encodeURIComponent(address)}`;
  const res = await fetch(url);
  if (!res.ok) return [];
  const data = await res.json();
  return Array.isArray(data?.pairs) ? data.pairs : [];
}

async function fetchBySearch(address) {
  const url = `https://api.dexscreener.com/latest/dex/search?q=${encodeURIComponent(address)}`;
  const res = await fetch(url);
  if (!res.ok) return [];
  const data = await res.json();
  return Array.isArray(data?.pairs) ? data.pairs : [];
}

async function resolveMarket(address) {
  let pairs = await fetchByToken(address);

  if (!pairs.length) {
    const searched = await fetchBySearch(address);
    const lower = address.toLowerCase();
    const exact = searched.find(p => String(p?.pairAddress || "").toLowerCase() === lower);
    const pair = exact || searched.sort((a,b) => Number(b?.liquidity?.usd || 0) - Number(a?.liquidity?.usd || 0))[0];
    if (!pair) throw new Error("No supported market found.");

    const side = chooseSide(pair);
    const resolved = tokenFromPair(pair, side);
    if (resolved.address && resolved.address !== address) {
      pairs = await fetchByToken(resolved.address);
      if (pairs.length) {
        const best = pairs.sort((a,b) => Number(b?.liquidity?.usd || 0) - Number(a?.liquidity?.usd || 0))[0];
        const bestSide = String(best?.baseToken?.address || "").toLowerCase() === resolved.address.toLowerCase() ? "base" : "quote";
        return tokenFromPair(best, bestSide);
      }
    }
    return resolved;
  }

  const best = pairs.sort((a,b) => Number(b?.liquidity?.usd || 0) - Number(a?.liquidity?.usd || 0))[0];
  const side = String(best?.baseToken?.address || "").toLowerCase() === address.toLowerCase() ? "base" : chooseSide(best);
  return tokenFromPair(best, side);
}

api.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type !== "PM_MOBILE_FETCH_MARKET") return;

  resolveMarket(String(message.address || "").trim())
    .then(token => sendResponse({ok:true, token}))
    .catch(error => sendResponse({ok:false, error:error?.message || String(error)}));

  return true;
});
