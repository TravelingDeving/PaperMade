(() => {
  if (window.__PAPERMADE_MOBILE_BRIDGE__) return;
  window.__PAPERMADE_MOBILE_BRIDGE__ = true;

  const api = globalThis.browser || globalThis.chrome;
  const script = document.createElement("script");
  script.src = api.runtime.getURL("bridge-page.js");
  script.onload = () => script.remove();
  (document.head || document.documentElement).appendChild(script);

  function forward() {
    const encoded = document.documentElement.getAttribute("data-papermade-extension-session");
    if (!encoded) return;

    try {
      const json = decodeURIComponent(escape(atob(encoded)));
      const payload = JSON.parse(json);

      if (payload?.connected) {
        api.runtime.sendMessage({type:"PAPERMADE_SESSION_FROM_SITE",payload});
      } else if (payload?.explicitLogout) {
        api.runtime.sendMessage({type:"PAPERMADE_SITE_LOGGED_OUT",origin:payload?.origin||""});
      }
    } catch (_) {}
  }

  document.addEventListener("papermade-extension-session", forward);
  setTimeout(forward, 500);
})();
