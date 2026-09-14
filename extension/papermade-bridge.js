(() => {
  if (window.__PAPERMADE_EXTENSION_BRIDGE__) return;
  window.__PAPERMADE_EXTENSION_BRIDGE__ = true;

  const script = document.createElement("script");
  script.src = chrome.runtime.getURL("bridge-page.js");
  script.onload = () => script.remove();
  (document.head || document.documentElement).appendChild(script);

  function forward() {
    const encoded = document.documentElement.getAttribute("data-papermade-extension-session");
    if (!encoded) return;

    try {
      const json = decodeURIComponent(escape(atob(encoded)));
      const payload = JSON.parse(json);

      if (payload?.connected) {
        chrome.runtime.sendMessage({
          type: "PAPERMADE_SESSION_FROM_SITE",
          payload
        });
      } else {
        chrome.runtime.sendMessage({
          type: "PAPERMADE_SITE_LOGGED_OUT"
        });
      }
    } catch (_) {}
  }

  document.addEventListener("papermade-extension-session", forward);
  setTimeout(forward, 500);
})();
