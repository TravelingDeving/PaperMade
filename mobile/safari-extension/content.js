(() => {
  if (window.__PAPERMADE_MOBILE__) return;
  window.__PAPERMADE_MOBILE__ = true;

  const api = globalThis.browser || globalThis.chrome;
  const KEY = "fomoPaperStateV01";
  const DEFAULT_STATE = {cash:100, startingBalance:100, positions:{}, trades:[], journal:[], calendarDays:{}};

  let state = {...DEFAULT_STATE};
  let token = null;
  let address = "";
  let mode = "buy";
  let timer = null;
  let syncStatus = {connected:false,signedIn:false,approved:false,discordUsername:""};

  const money = n => "$" + Number(n || 0).toFixed(2);
  const compact = n => {
    const v=Number(n||0);
    if(v>=1e9)return "$"+(v/1e9).toFixed(2)+"B";
    if(v>=1e6)return "$"+(v/1e6).toFixed(2)+"M";
    if(v>=1e3)return "$"+(v/1e3).toFixed(1)+"K";
    return money(v);
  };

  function findAddress() {
    const text = location.href + " " + location.pathname + " " + location.search;
    const evm = text.match(/0x[a-fA-F0-9]{40}/);
    if (evm) return evm[0];

    const parts = decodeURIComponent(location.pathname + " " + location.search)
      .split(/[^1-9A-HJ-NP-Za-km-z]+/)
      .filter(Boolean);

    const sol = parts.find(x => x.length >= 32 && x.length <= 44 && /^[1-9A-HJ-NP-Za-km-z]+$/.test(x));
    return sol || "";
  }

  function position() {
    return state.positions?.[address] || null;
  }

  function metrics() {
    const pos=position();
    if(!pos) return {value:0,pnl:0,pct:0};
    let ratio=1;
    if(Number(token?.marketCap)>0 && Number(pos.avgEntryMc)>0) ratio=Number(token.marketCap)/Number(pos.avgEntryMc);
    else if(Number(token?.priceUsd)>0 && Number(pos.avgEntryPrice)>0) ratio=Number(token.priceUsd)/Number(pos.avgEntryPrice);
    if(!Number.isFinite(ratio)||ratio<=0) ratio=1;
    const value=Number(pos.netExposureBasis ?? pos.costBasis)*ratio;
    const pnl=value-Number(pos.costBasis||0);
    const pct=Number(pos.costBasis||0)>0 ? pnl/Number(pos.costBasis)*100 : 0;
    return {value,pnl,pct};
  }

  function runtimeMessage(payload) {
    return new Promise(resolve => {
      let settled=false;
      const done=value=>{if(!settled){settled=true;resolve(value||{});}};
      try {
        const maybe=api.runtime.sendMessage(payload, done);
        if (maybe && typeof maybe.then === "function") {
          maybe.then(done).catch(()=>done({}));
        }
      } catch (_) {
        done({});
      }
    });
  }

  async function refreshSyncStatus() {
    const status=await runtimeMessage({type:"GET_PAPERMADE_SYNC_STATUS"});
    syncStatus={
      connected:Boolean(status?.connected),
      signedIn:Boolean(status?.signedIn),
      approved:Boolean(status?.approved),
      discordUsername:status?.discordUsername||""
    };
    return syncStatus;
  }

  async function load() {
    const got=await api.storage.local.get(KEY);
    state={...DEFAULT_STATE,...(got?.[KEY]||{})};

    await refreshSyncStatus();

    if (syncStatus.connected) {
      const remote=await runtimeMessage({type:"PULL_PAPERMADE_STATE"});
      if (remote?.ok && remote?.row?.state) {
        state={...DEFAULT_STATE,...remote.row.state};
        await api.storage.local.set({[KEY]:state});
      } else if (remote?.ok && !remote?.row && (state.trades?.length || Object.keys(state.positions||{}).length)) {
        await runtimeMessage({type:"PUSH_PAPERMADE_STATE",state});
      }
    }
  }

  async function save() {
    await api.storage.local.set({[KEY]:state});
    if (syncStatus.connected) {
      await runtimeMessage({type:"PUSH_PAPERMADE_STATE",state});
    }
  }

  function shell() {
    const pill=document.createElement("button");
    pill.id="pm-mobile-pill";
    pill.innerHTML='<span class="pm-logo">P</span><span id="pm-pill-token">PaperMade</span><strong id="pm-pill-pnl" class="pm-up">PAPER</strong>';

    const sheet=document.createElement("section");
    sheet.id="pm-mobile-sheet";
    sheet.innerHTML=`
      <div class="pm-grabber"></div>
      <div class="pm-head">
        <div>
          <div class="pm-token"><strong id="pm-symbol">TOKEN</strong><span id="pm-chain" class="pm-chain">detecting</span></div>
          <div id="pm-address" class="pm-address">Looking for token…</div>
        </div>
        <div class="pm-head-right"><strong id="pm-balance" class="pm-balance">$100.00 available</strong><span class="pm-live">LIVE</span></div>
      </div>
      <div class="pm-stats">
        <div class="pm-stat"><span>PRICE</span><strong id="pm-price">—</strong></div>
        <div class="pm-stat"><span>MARKET CAP</span><strong id="pm-mc">—</strong></div>
        <div class="pm-stat"><span>LIQUIDITY</span><strong id="pm-liq">—</strong></div>
        <div class="pm-stat"><span>INVESTED</span><strong id="pm-invested">$0.00</strong></div>
        <div class="pm-stat"><span>POSITION VALUE</span><strong id="pm-value">$0.00</strong></div>
        <div class="pm-stat"><span>AVG BUY MC</span><strong id="pm-avg">—</strong></div>
      </div>
      <div class="pm-pnl"><span>OPEN P&L</span><strong id="pm-pnl">$0.00 (0.00%)</strong><b id="pm-pnl-short">$0.00</b></div>
      <div class="pm-tabs"><button class="pm-tab pm-active" data-mode="buy">Buy</button><button class="pm-tab" data-mode="sell">Sell</button></div>
      <div class="pm-amount"><span>$</span><input id="pm-input" inputmode="decimal" placeholder="0"><small>Amount</small></div>
      <div class="pm-quick" id="pm-quick"></div>
      <div class="pm-row"><span>Paper only • no wallet signing</span><button class="pm-max" id="pm-max">Max</button></div>
      <button id="pm-trade" class="pm-trade">Paper Buy</button>
      <button id="pm-account" class="pm-account">Connect PaperMade account</button>
      <div id="pm-note" class="pm-note">Mobile alpha • paper only</div>
    `;

    document.documentElement.append(pill,sheet);

    pill.addEventListener("click",()=>{sheet.classList.add("pm-open");pill.style.display="none";});
    sheet.querySelector(".pm-grabber").addEventListener("click",()=>{sheet.classList.remove("pm-open");pill.style.display="flex";});
    sheet.querySelectorAll(".pm-tab").forEach(btn=>btn.addEventListener("click",()=>{mode=btn.dataset.mode;render();}));
    sheet.querySelector("#pm-max").addEventListener("click",()=>{
      const input=sheet.querySelector("#pm-input");
      input.value=mode==="buy"?Number(state.cash||0).toFixed(2):Number(metrics().value||0).toFixed(2);
    });
    sheet.querySelector("#pm-trade").addEventListener("click",trade);
    sheet.querySelector("#pm-account").addEventListener("click",async()=>{
      if (syncStatus.connected) return;
      await runtimeMessage({type:"OPEN_PAPERMADE_LOGIN"});
    });
  }

  function quickButtons() {
    const el=document.querySelector("#pm-quick");
    if(!el) return;
    const values=mode==="buy"?[3,5,10,15]:[25,50,75,100];
    el.innerHTML=values.map(v=>`<button data-q="${v}">${mode==="buy"?"$"+v:v+"%"}</button>`).join("");
    el.querySelectorAll("button").forEach(btn=>btn.addEventListener("click",()=>{
      if(mode==="buy") document.querySelector("#pm-input").value=btn.dataset.q;
      else {
        const value=metrics().value;
        document.querySelector("#pm-input").value=(value*(Number(btn.dataset.q)/100)).toFixed(2);
      }
    }));
  }

  async function trade() {
    if(!token||!address) return;
    const input=document.querySelector("#pm-input");
    const amount=Number(input.value||0);
    if(!Number.isFinite(amount)||amount<=0) return;

    if(mode==="buy") {
      if(amount>state.cash) return;
      const old=position()||{symbol:token.symbol,qty:0,costBasis:0,netExposureBasis:0,avgEntryPrice:0,avgEntryMc:0,firstEntryAt:Date.now()};
      const oldCost=Number(old.costBasis||0);
      const price=Number(token.priceUsd||0);
      const qty=price>0?amount/price:0;
      const newCost=oldCost+amount;
      old.qty=Number(old.qty||0)+qty;
      old.costBasis=newCost;
      old.netExposureBasis=Number(old.netExposureBasis||0)+amount;
      old.avgEntryPrice=old.qty>0?Number(old.netExposureBasis)/old.qty:0;
      old.avgEntryMc=newCost>0?((Number(old.avgEntryMc||0)*oldCost)+(Number(token.marketCap||0)*amount))/newCost:Number(token.marketCap||0);
      old.symbol=token.symbol;
      state.positions[address]=old;
      state.cash-=amount;
      state.trades.push({type:"BUY",address,symbol:token.symbol,usd:amount,marketCap:Number(token.marketCap||0),at:Date.now()});
    } else {
      const pos=position();
      if(!pos) return;
      const m=metrics();
      const requested=Math.min(amount,m.value);
      const fraction=m.value>0?Math.min(1,requested/m.value):0;
      if(fraction<=0) return;
      const hard=fraction>=0.999999;
      const proceeds=hard?m.value:m.value*fraction;
      const costRemoved=hard?Number(pos.costBasis||0):Number(pos.costBasis||0)*fraction;
      const realized=proceeds-costRemoved;
      state.cash+=proceeds;
      state.trades.push({type:"SELL",address,symbol:token.symbol,usd:proceeds,marketCap:Number(token.marketCap||0),realizedPnl:realized,at:Date.now()});
      if(hard){delete state.positions[address];}
      else {
        pos.costBasis=Math.max(0,Number(pos.costBasis||0)-costRemoved);
        pos.netExposureBasis=Math.max(0,Number(pos.netExposureBasis||0)*(1-fraction));
        pos.qty=Math.max(0,Number(pos.qty||0)*(1-fraction));
        state.positions[address]=pos;
      }
    }

    input.value="";
    await save();
    render();
  }

  function render() {
    const pos=position();
    const m=metrics();
    const symbol=token?.symbol||"TOKEN";
    const pnlPositive=m.pnl>=0;

    document.querySelector("#pm-symbol").textContent="$"+symbol;
    document.querySelector("#pm-chain").textContent=token?.chainId||"detecting";
    document.querySelector("#pm-address").textContent=address?address.slice(0,7)+"…"+address.slice(-5):"Looking for token…";
    document.querySelector("#pm-balance").textContent=money(state.cash)+" available";
    document.querySelector("#pm-price").textContent=Number(token?.priceUsd)>0?"$"+Number(token.priceUsd).toLocaleString(undefined,{maximumSignificantDigits:5}):"—";
    document.querySelector("#pm-mc").textContent=Number(token?.marketCap)>0?compact(token.marketCap):"—";
    document.querySelector("#pm-liq").textContent=Number(token?.liquidityUsd)>0?compact(token.liquidityUsd):"—";
    document.querySelector("#pm-invested").textContent=money(pos?.costBasis||0);
    document.querySelector("#pm-value").textContent=money(m.value);
    document.querySelector("#pm-avg").textContent=Number(pos?.avgEntryMc)>0?compact(pos.avgEntryMc):"—";

    const pnl=document.querySelector("#pm-pnl");
    pnl.textContent=`${money(m.pnl)} (${m.pct>=0?"+":""}${m.pct.toFixed(2)}%)`;
    pnl.style.color=pnlPositive?"#2af08b":"#ff6470";
    const short=document.querySelector("#pm-pnl-short");
    short.textContent=(m.pnl>=0?"+":"")+money(m.pnl);
    short.style.color=pnlPositive?"#2af08b":"#ff6470";

    document.querySelector("#pm-pill-token").textContent="$"+symbol;
    document.querySelector("#pm-pill-pnl").textContent=pos?`${m.pct>=0?"+":""}${m.pct.toFixed(2)}%`:"PAPER";

    const account=document.querySelector("#pm-account");
    if (account) {
      if (syncStatus.connected) {
        account.textContent=`Synced • ${syncStatus.discordUsername||"PaperMade"}`;
        account.classList.add("pm-synced");
      } else if (syncStatus.signedIn && !syncStatus.approved) {
        account.textContent="PaperMadeTester access required";
        account.classList.remove("pm-synced");
      } else {
        account.textContent="Connect PaperMade account";
        account.classList.remove("pm-synced");
      }
    }

    document.querySelectorAll(".pm-tab").forEach(btn=>btn.classList.toggle("pm-active",btn.dataset.mode===mode));
    const tradeBtn=document.querySelector("#pm-trade");
    tradeBtn.textContent=mode==="buy"?`Paper Buy $${symbol}`:`Paper Sell $${symbol}`;
    tradeBtn.classList.toggle("pm-sell",mode==="sell");
    quickButtons();
  }

  async function refreshMarket() {
    const next=findAddress();
    if(next && next!==address) address=next;
    if(!address){render();return;}

    api.runtime.sendMessage({type:"PM_MOBILE_FETCH_MARKET",address},response=>{
      if(response?.ok){
        token=response.token;
        if(token?.address) address=token.address;
        render();
      }
    });
  }

  async function start() {
    await load();
    shell();
    render();
    await refreshMarket();
    clearInterval(timer);
    timer=setInterval(refreshMarket,5000);
    setInterval(async()=>{
      const before=syncStatus.connected;
      await refreshSyncStatus();
      if (!before && syncStatus.connected) {
        const remote=await runtimeMessage({type:"PULL_PAPERMADE_STATE"});
        if (remote?.ok && remote?.row?.state) {
          state={...DEFAULT_STATE,...remote.row.state};
          await api.storage.local.set({[KEY]:state});
        }
      }
      render();
    },5000);
  }

  start().catch(()=>{});
})();
