(() => {
  if (window.__PAPERMADE_EXTENSION_BRIDGE_PAGE__) return;
  window.__PAPERMADE_EXTENSION_BRIDGE_PAGE__ = true;

  function findSession() {
    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (!key || !/^sb-.*-auth-token$/i.test(key)) continue;
        const raw = localStorage.getItem(key);
        if (!raw) continue;
        try {
          const parsed = JSON.parse(raw);
          const session = parsed?.currentSession || parsed?.session || parsed;
          if (session?.access_token && session?.refresh_token) return session;
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  function consumeExplicitLogout() {
    try {
      const key = "papermade_explicit_logout_at";
      const raw = localStorage.getItem(key);
      if (!raw) return false;
      localStorage.removeItem(key);
      const at = Number(raw);
      return Number.isFinite(at) && Math.abs(Date.now() - at) <= 60_000;
    } catch (_) {
      return false;
    }
  }

  function emit() {
    const cfg = window.PAPERMADE_CONFIG || {};
    const session = findSession();
    const connected = Boolean(session?.access_token && session?.user?.id);

    const payload = {
      supabaseUrl: cfg.SUPABASE_URL || "",
      anonKey: cfg.SUPABASE_ANON_KEY || "",
      accessToken: session?.access_token || "",
      refreshToken: session?.refresh_token || "",
      user: session?.user || null,
      connected,
      explicitLogout: !connected && consumeExplicitLogout(),
      origin: location.origin
    };

    try {
      document.documentElement.setAttribute(
        "data-papermade-extension-session",
        btoa(unescape(encodeURIComponent(JSON.stringify(payload))))
      );
      document.dispatchEvent(new CustomEvent("papermade-extension-session"));
    } catch (_) {}
  }

  emit();
  setInterval(emit, 2500);
  window.addEventListener("storage", emit);
})();
