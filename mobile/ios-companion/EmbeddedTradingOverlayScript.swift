import Foundation

enum EmbeddedTradingOverlayScript {
    static let source = #"""
(() => {
  if (window.__PAPERMADE_EMBEDDED_IOS__) return;
  window.__PAPERMADE_EMBEDDED_IOS__ = true;

  const host = document.createElement("div");
  host.id = "papermade-ios-host";
  host.style.cssText = "position:fixed;inset:0;z-index:2147483647;pointer-events:none;";
  document.documentElement.appendChild(host);

  const shadow = host.attachShadow({mode:"open"});
  shadow.innerHTML = `
    <style>
      *{box-sizing:border-box;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
      button,input{font:inherit}
      #pill{pointer-events:auto;position:fixed;left:50%;bottom:calc(14px + env(safe-area-inset-bottom));transform:translateX(-50%);display:flex;align-items:center;gap:8px;padding:8px 12px;border:1px solid #25784d;border-radius:999px;background:rgba(5,13,8,.97);color:#fff;box-shadow:0 12px 34px rgba(0,0,0,.5);font-size:13px;font-weight:800}
      .logo{width:27px;height:27px;border:1px solid #2af08b;border-radius:8px;display:grid;place-items:center;color:#2af08b;font-weight:1000}
      #pillPnl,.green{color:#2af08b}.red{color:#ff6470}
      #sheet{pointer-events:auto;position:fixed;left:0;right:0;bottom:0;max-height:86vh;overflow:auto;padding:8px 14px calc(14px + env(safe-area-inset-bottom));border:1px solid #173122;border-bottom:0;border-radius:24px 24px 0 0;background:#07100a;color:#fff;box-shadow:0 -20px 55px rgba(0,0,0,.65);transform:translateY(110%);transition:transform .22s ease}
      #sheet.open{transform:translateY(0)}
      #grab{width:48px;height:5px;border-radius:99px;background:#314438;margin:2px auto 12px}
      .head{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
      .token{font-size:18px;font-weight:950}.chain{font-size:10px;color:#7a8980;margin-left:6px}
      .address{font-size:10px;color:#6c7b72;margin-top:4px}
      .headRight{display:flex;align-items:center;gap:6px;flex-wrap:wrap;justify-content:flex-end}
      .balance{font-size:14px;font-weight:950;padding:6px 8px;border:1px solid #224832;border-radius:10px;background:#0a1710}
      .live{font-size:9px;font-weight:950;color:#2af08b;padding:5px 7px;border:1px solid #1f6b43;border-radius:999px}
      .stats{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px}
      .stat{padding:10px;border:1px solid #162a1d;border-radius:13px;background:#0a130d}
      .label{display:block;color:#738178;font-size:9px;font-weight:850;letter-spacing:.05em;margin-bottom:4px}
      .stat strong{font-size:16px}
      .pnl{margin-top:8px;padding:11px;border:1px solid #173021;border-radius:13px;background:#09150e}
      .pnl strong{font-size:20px}
      .tabs{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:11px}
      .tab{height:43px;border:1px solid #203329;border-radius:11px;background:#0b130e;color:#819087;font-weight:900}
      .tab.active.buy{border-color:#2aa666;background:#0d2517;color:#2af08b}
      .tab.active.sell{border-color:#a8323c;background:#261015;color:#ff6470}
      .amount{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:7px;margin-top:8px;padding:10px 12px;border:1px solid #1a2a20;border-radius:13px;background:#0b130e}
      .amount b{font-size:27px;color:#89978e}.amount input{width:100%;border:0;outline:0;background:transparent;color:#fff;font-size:27px;font-weight:850}.amount small{color:#77857c}
      .quick{display:grid;grid-template-columns:repeat(4,1fr);gap:7px;margin-top:8px}
      .quick button{height:37px;border:1px solid #21372b;border-radius:10px;background:#101a14;color:#fff;font-weight:900}
      .row{display:flex;justify-content:space-between;align-items:center;margin:7px 2px;color:#718077;font-size:11px}
      #max{border:0;background:transparent;color:#2af08b;font-weight:900}
      #trade{width:100%;height:48px;border:1px solid #2af08b;border-radius:13px;background:#0d2818;color:#2af08b;font-size:15px;font-weight:1000}
      #trade.sell{border-color:#ff4e5b;background:#2a0d11;color:#ff6470}
      #status{min-height:16px;margin-top:7px;text-align:center;color:#75847b;font-size:10px}
      .site{font-size:10px;font-weight:900;color:#9ca9a1}
    </style>
    <button id="pill"><span class="logo">P</span><span id="pillToken">PaperMade</span><strong id="pillPnl">PAPER</strong></button>
    <section id="sheet">
      <div id="grab"></div>
      <div class="head">
        <div>
          <div><span class="token" id="symbol">TOKEN</span><span class="chain" id="chain">detecting</span></div>
          <div class="address" id="address">Open a token page</div>
        </div>
        <div class="headRight"><strong class="balance" id="balance">$100.00 available</strong><span class="live">LIVE</span><span class="site">FOMO</span></div>
      </div>
      <div class="stats">
        <div class="stat"><span class="label">PRICE</span><strong id="price">—</strong></div>
        <div class="stat"><span class="label">MARKET CAP</span><strong id="mc">—</strong></div>
        <div class="stat"><span class="label">LIQUIDITY</span><strong id="liq">—</strong></div>
        <div class="stat"><span class="label">INVESTED</span><strong id="invested">$0.00</strong></div>
        <div class="stat"><span class="label">POSITION VALUE</span><strong id="value">$0.00</strong></div>
        <div class="stat"><span class="label">AVG BUY MC</span><strong id="avg">—</strong></div>
      </div>
      <div class="pnl"><span class="label">OPEN P&L</span><strong id="pnl">$0.00 (0.00%)</strong></div>
      <div class="tabs"><button id="buyTab" class="tab buy active">Buy</button><button id="sellTab" class="tab sell">Sell</button></div>
      <div class="amount"><b>$</b><input id="amount" inputmode="decimal" placeholder="0"><small>Amount</small></div>
      <div class="quick" id="quick"></div>
      <div class="row"><span>Paper only • no wallet signing</span><button id="max">Max</button></div>
      <button id="trade">Paper Buy</button>
      <div id="status">Embedded FOMO alpha</div>
    </section>
  `;

  const $ = id => shadow.getElementById(id);
  let mode = "buy";
  let model = {
    token:null,
    cash:100,
    invested:0,
    value:0,
    pnl:0,
    pct:0,
    avgEntryMc:0
  };

  const money = n => "$" + Number(n||0).toFixed(2);
  const compact = n => {
    const v=Number(n||0);
    if(v>=1e9)return "$"+(v/1e9).toFixed(2)+"B";
    if(v>=1e6)return "$"+(v/1e6).toFixed(2)+"M";
    if(v>=1e3)return "$"+(v/1e3).toFixed(1)+"K";
    return v>0?money(v):"—";
  };

  function send(payload){
    try{ window.webkit.messageHandlers.papermade.postMessage(payload); }catch(e){}
  }

  function renderQuick(){
    const values = mode==="buy" ? [3,5,10,15] : [25,50,75,100];
    $("quick").innerHTML = values.map(v=>`<button data-v="${v}">${mode==="buy"?"$"+v:v+"%"}</button>`).join("");
    [...$("quick").querySelectorAll("button")].forEach(btn=>btn.onclick=()=>{
      const v=Number(btn.dataset.v||0);
      $("amount").value = mode==="buy" ? String(v) : (model.value*(v/100)).toFixed(2);
    });
  }

  function render(){
    const t=model.token;
    $("symbol").textContent = t ? "$"+t.symbol : "TOKEN";
    $("chain").textContent = t?.chainId || "detecting";
    $("address").textContent = t?.address ? t.address.slice(0,7)+"…"+t.address.slice(-5) : "Open a token page";
    $("balance").textContent = money(model.cash)+" available";
    $("price").textContent = t?.priceUsd>0 ? "$"+Number(t.priceUsd).toLocaleString(undefined,{maximumSignificantDigits:5}) : "—";
    $("mc").textContent = compact(t?.marketCap);
    $("liq").textContent = compact(t?.liquidityUsd);
    $("invested").textContent = money(model.invested);
    $("value").textContent = money(model.value);
    $("avg").textContent = compact(model.avgEntryMc);
    $("pnl").textContent = (model.pnl>=0?"+":"")+money(model.pnl)+" ("+(model.pct>=0?"+":"")+Number(model.pct||0).toFixed(2)+"%)";
    $("pnl").className = model.pnl>=0?"green":"red";
    $("pillToken").textContent = t ? "$"+t.symbol : "PaperMade";
    $("pillPnl").textContent = model.invested>0 ? (model.pct>=0?"+":"")+Number(model.pct||0).toFixed(2)+"%" : "PAPER";
    $("pillPnl").className = model.pnl>=0?"green":"red";

    $("buyTab").classList.toggle("active", mode==="buy");
    $("sellTab").classList.toggle("active", mode==="sell");
    $("trade").textContent = mode==="buy"
      ? "Paper Buy"+(t?" $"+t.symbol:"")
      : "Paper Sell"+(t?" $"+t.symbol:"");
    $("trade").classList.toggle("sell", mode==="sell");
    renderQuick();
  }

  $("pill").onclick=()=>{$("sheet").classList.add("open");$("pill").style.display="none";send({type:"overlayOpen"});};
  $("grab").onclick=()=>{$("sheet").classList.remove("open");$("pill").style.display="flex";};
  $("buyTab").onclick=()=>{mode="buy";render();};
  $("sellTab").onclick=()=>{mode="sell";render();};
  $("max").onclick=()=>{$("amount").value=(mode==="buy"?model.cash:model.value).toFixed(2);};
  $("trade").onclick=()=>{
    const amount=Number($("amount").value||0);
    if(!model.token){$("status").textContent="Open a supported token page first.";return;}
    if(!Number.isFinite(amount)||amount<=0){$("status").textContent="Enter a paper amount above zero.";return;}
    $("status").textContent="Processing paper trade…";
    send({type:"trade",mode,amount});
  };

  window.PaperMadeNative = {
    update(next){
      model={...model,...next};
      render();
    },
    status(text,kind){
      $("status").textContent=String(text||"");
      $("status").style.color=kind==="error"?"#ff6470":kind==="ok"?"#2af08b":"#75847b";
    }
  };

  send({type:"ready",url:location.href});
  render();
})();
"""#
}
