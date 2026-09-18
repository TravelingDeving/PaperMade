const sheet=document.getElementById("sheet");
const pill=document.getElementById("pill");
const tabs=[...document.querySelectorAll(".tab")];
const input=document.getElementById("amountInput");
const tradeBtn=document.getElementById("tradeBtn");
const maxBtn=document.getElementById("maxBtn");
let mode="buy";

pill.addEventListener("click",()=>{
  sheet.classList.add("open");
  sheet.setAttribute("aria-hidden","false");
  pill.style.display="none";
});

document.querySelector(".grabber").addEventListener("click",()=>{
  sheet.classList.remove("open");
  sheet.setAttribute("aria-hidden","true");
  pill.style.display="flex";
});

tabs.forEach(tab=>tab.addEventListener("click",()=>{
  tabs.forEach(t=>t.classList.remove("active"));
  tab.classList.add("active");
  mode=tab.dataset.mode;
  tradeBtn.textContent=mode==="buy"?"Paper Buy $SWOGE":"Paper Sell $SWOGE";
  tradeBtn.classList.toggle("sell",mode==="sell");
}));

document.querySelectorAll("[data-amt]").forEach(btn=>{
  btn.addEventListener("click",()=>{ input.value=btn.dataset.amt; });
});

maxBtn.addEventListener("click",()=>{
  input.value=mode==="buy"?"256.31":"11.31";
});
