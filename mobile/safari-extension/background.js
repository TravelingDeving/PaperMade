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


const ACCOUNT_KEY = "papermadeAccountV01";
const STATE_KEY = "fomoPaperStateV01";
const LOGIN_URL = "https://papermade.xyz/login.html";

async function getAccount() {
  const stored = await api.storage.local.get(ACCOUNT_KEY);
  return stored?.[ACCOUNT_KEY] || null;
}

async function setAccount(account) {
  await api.storage.local.set({[ACCOUNT_KEY]: account});
}

async function clearAccount() {
  await api.storage.local.remove(ACCOUNT_KEY);
}

function accountConfigured(account) {
  return Boolean(
    account?.supabaseUrl &&
    account?.anonKey &&
    account?.accessToken &&
    account?.refreshToken &&
    account?.user?.id
  );
}

async function refreshAccount(account) {
  if (!accountConfigured(account)) return null;

  const response = await fetch(
    `${account.supabaseUrl}/auth/v1/token?grant_type=refresh_token`,
    {
      method: "POST",
      headers: {
        "apikey": account.anonKey,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({refresh_token: account.refreshToken})
    }
  );

  if (!response.ok) {
    if (response.status === 400 || response.status === 401) await clearAccount();
    return null;
  }

  const data = await response.json();
  const next = {
    ...account,
    accessToken: data.access_token || account.accessToken,
    refreshToken: data.refresh_token || account.refreshToken,
    user: data.user || account.user,
    refreshedAt: Date.now()
  };
  await setAccount(next);
  return next;
}

async function supabaseFetch(account, path, options = {}, retry = true) {
  const headers = new Headers(options.headers || {});
  headers.set("apikey", account.anonKey);
  headers.set("Authorization", `Bearer ${account.accessToken}`);
  if (options.body && !headers.has("Content-Type")) headers.set("Content-Type","application/json");

  let response = await fetch(`${account.supabaseUrl}${path}`, {...options, headers});
  if (response.status === 401 && retry) {
    const refreshed = await refreshAccount(account);
    if (refreshed) return supabaseFetch(refreshed, path, options, false);
  }
  return response;
}

async function checkAccess(account) {
  if (!accountConfigured(account)) return {approved:false,signedIn:false,reason:"PaperMade login required"};

  const userId=encodeURIComponent(account.user.id);
  const response=await supabaseFetch(
    account,
    `/rest/v1/papermade_access?select=approved,discord_username,reason&user_id=eq.${userId}&limit=1`,
    {method:"GET"}
  );

  if (!response.ok) return {approved:false,signedIn:true,reason:`Access check failed (${response.status})`};
  const rows=await response.json();
  const row=Array.isArray(rows)&&rows.length?rows[0]:null;
  return {
    approved:Boolean(row?.approved),
    signedIn:true,
    discordUsername:row?.discord_username||"",
    reason:row?.reason||(row?.approved?"PaperMade access approved":"PaperMadeTester access required")
  };
}

async function pullState() {
  const account=await getAccount();
  if (!accountConfigured(account)) return {ok:false,connected:false};

  const access=await checkAccess(account);
  if (!access.approved) return {ok:false,connected:false,signedIn:true,approved:false,error:access.reason};

  const userId=encodeURIComponent(account.user.id);
  const response=await supabaseFetch(
    account,
    `/rest/v1/paper_states?select=state,updated_at&user_id=eq.${userId}&limit=1`,
    {method:"GET"}
  );
  if (!response.ok) return {ok:false,connected:true,error:`Sync read failed (${response.status})`};
  const rows=await response.json();
  return {ok:true,connected:true,approved:true,row:Array.isArray(rows)&&rows.length?rows[0]:null};
}

async function pushState(state) {
  const account=await getAccount();
  if (!accountConfigured(account)) return {ok:false,connected:false};

  const access=await checkAccess(account);
  if (!access.approved) return {ok:false,connected:false,signedIn:true,approved:false,error:access.reason};

  const response=await supabaseFetch(
    account,
    "/rest/v1/paper_states?on_conflict=user_id",
    {
      method:"POST",
      headers:{"Prefer":"resolution=merge-duplicates,return=minimal"},
      body:JSON.stringify({
        user_id:account.user.id,
        state,
        updated_at:new Date().toISOString()
      })
    }
  );

  if (!response.ok) return {ok:false,connected:true,error:`Sync failed (${response.status})`};
  return {ok:true,connected:true,approved:true};
}


api.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (!message?.type) return;

  if (message.type === "PM_MOBILE_FETCH_MARKET") {
    resolveMarket(String(message.address || "").trim())
      .then(token => sendResponse({ok:true, token}))
      .catch(error => sendResponse({ok:false, error:error?.message || String(error)}));
    return true;
  }

  if (message.type === "PAPERMADE_SESSION_FROM_SITE") {
    const p=message.payload||{};
    if (!p.connected || !p.user?.id || !p.supabaseUrl || !p.anonKey) {
      sendResponse?.({ok:false});
      return;
    }
    setAccount({
      supabaseUrl:p.supabaseUrl,
      anonKey:p.anonKey,
      accessToken:p.accessToken,
      refreshToken:p.refreshToken,
      user:p.user,
      connectedAt:Date.now()
    }).then(()=>sendResponse?.({ok:true})).catch(()=>sendResponse?.({ok:false}));
    return true;
  }

  if (message.type === "PAPERMADE_SITE_LOGGED_OUT") {
    clearAccount().then(()=>sendResponse?.({ok:true}));
    return true;
  }

  if (message.type === "GET_PAPERMADE_SYNC_STATUS") {
    getAccount().then(async account=>{
      const configured=accountConfigured(account);
      const access=configured?await checkAccess(account):{approved:false,signedIn:false,reason:"PaperMade login required"};
      sendResponse?.({
        ok:true,
        connected:Boolean(configured&&access.approved),
        signedIn:Boolean(configured),
        approved:Boolean(access.approved),
        discordUsername:access.discordUsername||"",
        reason:access.reason||"",
        user:account?.user?{id:account.user.id,email:account.user.email||""}:null
      });
    });
    return true;
  }

  if (message.type === "PULL_PAPERMADE_STATE") {
    pullState().then(sendResponse).catch(error=>sendResponse?.({ok:false,error:error?.message||String(error)}));
    return true;
  }

  if (message.type === "PUSH_PAPERMADE_STATE") {
    pushState(message.state).then(sendResponse).catch(error=>sendResponse?.({ok:false,error:error?.message||String(error)}));
    return true;
  }

  if (message.type === "OPEN_PAPERMADE_LOGIN") {
    if (api.tabs?.create) api.tabs.create({url:LOGIN_URL});
    sendResponse?.({ok:true,url:LOGIN_URL});
    return;
  }

  if (message.type === "DISCONNECT_PAPERMADE_ACCOUNT") {
    clearAccount().then(()=>sendResponse?.({ok:true}));
    return true;
  }
});
