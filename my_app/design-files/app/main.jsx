// teleBabies — Main app shell with frame, navigation, and tweaks panel

const { useState: uS, useEffect: uE, useRef: uR } = React;

// Custom Android-style frame styled to teleBabies
function TbDeviceFrame({ children, label, lang, dark, frameTone = 'dark' }) {
  const W = 392, H = 852;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
      {label && (
        <div style={{
          fontSize: 12, fontWeight: 700, color: '#1A1530',
          fontFamily: 'var(--tb-font-display)', letterSpacing: '0.04em', textTransform: 'uppercase',
        }}>{label}</div>
      )}
      <div style={{
        width: W + 16, height: H + 16,
        borderRadius: 50,
        padding: 8,
        background: frameTone === 'dark' ? '#1A1530' : '#2A2540',
        boxShadow: '0 30px 80px rgba(26, 21, 48, 0.25), 0 0 0 2px rgba(0,0,0,0.05)',
        position: 'relative',
      }}>
        <div dir={lang === 'ar' ? 'rtl' : 'ltr'} className="tb-app" style={{
          width: W, height: H, borderRadius: 42, overflow: 'hidden',
          background: 'var(--tb-bg)', position: 'relative',
          display: 'flex', flexDirection: 'column',
        }} data-theme={dark ? 'dark' : 'light'}>
          {children}
        </div>
        {/* Side buttons */}
        <div style={{ position: 'absolute', right: -2, top: 140, width: 4, height: 60, background: '#0a0816', borderRadius: 2 }} />
        <div style={{ position: 'absolute', left: -2, top: 130, width: 4, height: 30, background: '#0a0816', borderRadius: 2 }} />
        <div style={{ position: 'absolute', left: -2, top: 175, width: 4, height: 50, background: '#0a0816', borderRadius: 2 }} />
      </div>
    </div>
  );
}

// Unified App — handles login, role-based routing, customer + admin
// Production routing logic:
//   1. Login screen captures phone → OTP → (name for new customers).
//   2. After OTP, app shows a brief "verifying role" splash while the backend
//      returns user.role. Then it routes to /home (customer) or /admin (admin).
//   3. The same APK runs on both customer and admin phones — backend decides.
function CustomerApp({ lang, dark, productVariant, homeVariant, demoStart }) {
  const [route, setRoute] = uS({ name: demoStart || 'login' });
  const [tab, setTab] = uS('home');
  const [user, setUser] = uS(null); // { name, phone, role } — null = guest
  const [cart, setCart] = uS([
    { id: 'p3', qty: 2, size: '5T' },
    { id: 'p7', qty: 1, size: 'M' },
  ]);

  // Re-sync when demo controls change the start route
  uE(() => { if (demoStart) setRoute({ name: demoStart }); }, [demoStart]);

  const goHome = () => { setRoute({ name: 'tabs' }); setTab('home'); };
  const goAdmin = () => setRoute({ name: 'admin' });
  const goProduct = (id) => setRoute({ name: 'product', id });
  const goCheckout = (total) => setRoute({ name: 'checkout', total });
  const goOrder = (id) => setRoute({ name: 'order', id });
  const placeOrder = () => setRoute({ name: 'placed' });

  // Called from LoginScreen after OTP. Simulates the backend role check.
  const handleLoginContinue = (info) => {
    if (info && info.intent === 'admin') {
      setUser({ ...info, role: 'admin' });
      setRoute({ name: 'verifying', target: 'admin' });
      setTimeout(() => setRoute({ name: 'admin' }), 800);
    } else {
      setUser({ name: info?.name, phone: info?.phone, role: 'customer' });
      setRoute({ name: 'verifying', target: 'home' });
      setTimeout(() => goHome(), 700);
    }
  };

  const addToCart = (p, qty, size) => {
    setCart(prev => {
      const i = prev.findIndex(x => x.id === p.id && x.size === size);
      if (i >= 0) return prev.map((x, j) => j === i ? { ...x, qty: x.qty + qty } : x);
      return [...prev, { id: p.id, qty, size }];
    });
    setRoute({ name: 'tabs' }); setTab('cart');
  };

  const cartCount = cart.reduce((s, x) => s + x.qty, 0);

  // Login screen
  if (route.name === 'login') {
    return (
      <>
        <window.TB.TbStatusBar dark={true} lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden' }}>
          <window.TBLogin lang={lang}
            onContinue={handleLoginContinue}
            onSkip={goHome} />
        </div>
        <window.TB.TbNavBar dark={true} />
      </>
    );
  }

  // Verifying role — production: this is the moment your backend returns
  // user.role and the app routes accordingly.
  if (route.name === 'verifying') {
    const isAdmin = route.target === 'admin';
    return (
      <>
        <window.TB.TbStatusBar dark={isAdmin} lang={lang} />
        <div style={{
          flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
          background: isAdmin ? 'var(--tb-ink)' : 'var(--tb-bg)',
          color: isAdmin ? 'var(--tb-cream)' : 'var(--tb-ink)',
          gap: 18,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: '50%',
            border: '4px solid ' + (isAdmin ? 'rgba(255,255,255,0.15)' : 'var(--tb-line)'),
            borderTopColor: 'var(--tb-accent)',
            animation: 'tb-spin 0.9s linear infinite',
          }} />
          <style>{`@keyframes tb-spin { to { transform: rotate(360deg); } }`}</style>
          <div className="tb-display" style={{ fontSize: 18, fontWeight: 800 }}>
            {isAdmin
              ? (lang === 'ar' ? 'تحقق من صلاحيات المسؤول…' : 'Verifying admin access…')
              : (lang === 'ar' ? 'جاري تجهيز حسابك…' : 'Setting up your account…')}
          </div>
          <div style={{ fontSize: 12, opacity: 0.7, maxWidth: 240, textAlign: 'center', lineHeight: 1.5 }}>
            {isAdmin
              ? (lang === 'ar' ? 'نتأكد من أن لديك صلاحيات لوحة الإدارة' : 'Confirming your role with the server')
              : (lang === 'ar' ? 'لحظات وستكون جاهزاً' : 'Just a moment')}
          </div>
        </div>
        <window.TB.TbNavBar dark={isAdmin} />
      </>
    );
  }

  // Admin panel (same APK, different surface — gated by role check above)
  if (route.name === 'admin') {
    return (
      <>
        <window.TB.TbStatusBar dark={true} lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <window.TBAdminApp lang={lang} onExit={() => setRoute({ name: 'login' })} />
        </div>
        <window.TB.TbNavBar dark={true} />
      </>
    );
  }

  // Sub-routes
  if (route.name === 'product') {
    return (
      <>
        <window.TB.TbStatusBar lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <window.TBProduct lang={lang} productId={route.id}
            onBack={() => setRoute({ name: 'tabs' })}
            onAddCart={addToCart}
            variant={productVariant} />
        </div>
        <window.TB.TbNavBar />
      </>
    );
  }

  if (route.name === 'checkout') {
    return (
      <>
        <window.TB.TbStatusBar lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <window.TBCheckout lang={lang} total={route.total}
            onBack={() => { setRoute({ name: 'tabs' }); setTab('cart'); }}
            onPlaceOrder={placeOrder} />
        </div>
        <window.TB.TbNavBar />
      </>
    );
  }

  if (route.name === 'placed') {
    return (
      <>
        <window.TB.TbStatusBar lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <window.TBOrderPlaced lang={lang}
            onHome={() => { setCart([]); goHome(); }}
            onTrack={() => { setCart([]); goOrder('TB-2401'); }} />
        </div>
        <window.TB.TbNavBar />
      </>
    );
  }

  if (route.name === 'order') {
    return (
      <>
        <window.TB.TbStatusBar lang={lang} />
        <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <window.TBOrder lang={lang} orderId={route.id}
            onBack={() => { setRoute({ name: 'tabs' }); setTab('orders'); }} />
        </div>
        <window.TB.TbNavBar />
      </>
    );
  }

  // Tabs
  return (
    <>
      <window.TB.TbStatusBar lang={lang} dark={false} />
      <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        {tab === 'home' && (
          <window.TBHome lang={lang} dark={dark} user={user}
            onProduct={goProduct}
            onCategory={(c) => { setTab('search'); }}
            onSearch={() => setTab('search')}
            variant={homeVariant} />
        )}
        {tab === 'search' && (
          <window.TBBrowse lang={lang} onProduct={goProduct} />
        )}
        {tab === 'cart' && (
          <window.TBCart lang={lang} cart={cart} setCart={setCart}
            onCheckout={goCheckout} onProduct={goProduct} />
        )}
        {tab === 'orders' && (
          <window.TBOrders lang={lang} onOrder={goOrder} onShop={() => setTab('search')} />
        )}
        {tab === 'account' && (
          <window.TBAccount lang={lang} user={user} />
        )}
      </div>
      <window.TB.TbTabBar tab={tab} setTab={setTab} lang={lang} cartCount={cartCount} />
    </>
  );
}

// ─── ROOT ───
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent": "pink",
  "dark": false,
  "cardStyle": "shadow",
  "lang": "ar",
  "homeVariant": "a",
  "productVariant": "a",
  "checkoutVariant": "a"
}/*EDITMODE-END*/;

function Root() {
  const [tweaks, setTweak] = window.useTweaks(TWEAK_DEFAULTS);
  const [demoStart, setDemoStart] = uS('login'); // 'login' | 'tabs' | 'admin' — demo shortcut
  const [appKey, setAppKey] = uS(0); // bump to remount app when demoStart changes
  const lang = tweaks.lang;

  // Apply CSS vars from tweaks
  uE(() => {
    const root = document.documentElement;
    root.setAttribute('data-theme', tweaks.dark ? 'dark' : 'light');
    root.setAttribute('data-card-style', tweaks.cardStyle);

    const accents = {
      pink:   { c: '#FF4D8D', s: '#FFC2D8', ink: '#FFFFFF' },
      yellow: { c: '#F4B400', s: '#FFE99A', ink: '#1A1530' },
      mint:   { c: '#2BD9A6', s: '#BFF5E3', ink: '#1A1530' },
      blue:   { c: '#3B6BFF', s: '#C8D6FF', ink: '#FFFFFF' },
      purple: { c: '#8B5CF6', s: '#DDD0FF', ink: '#FFFFFF' },
      coral:  { c: '#FF6B4A', s: '#FFD4C5', ink: '#FFFFFF' },
    };
    const a = accents[tweaks.accent] || accents.pink;
    root.style.setProperty('--tb-accent', a.c);
    root.style.setProperty('--tb-accent-soft', a.s);
    root.style.setProperty('--tb-accent-ink', a.ink);

    document.body.dir = lang === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = lang;
  }, [tweaks, lang]);

  return (
    <div style={{
      minHeight: '100vh', padding: '32px 24px',
      background: tweaks.dark
        ? 'radial-gradient(ellipse at top, #2A2148 0%, #14102A 60%)'
        : 'radial-gradient(ellipse at top, #FFE6F0 0%, #FAF6EC 50%, #E8DCC1 100%)',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 32,
    }}>
      {/* Top bar — branding, demo shortcut, lang toggle */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap',
        background: tweaks.dark ? 'rgba(255,255,255,0.06)' : 'rgba(255,255,255,0.7)',
        backdropFilter: 'blur(20px)',
        padding: 8, borderRadius: 999, border: tweaks.dark ? '1px solid rgba(255,255,255,0.08)' : '1px solid rgba(26, 21, 48, 0.08)',
      }}>
        <window.TB.TbWordmark lang={lang} size={18} color={tweaks.dark ? '#FFF7E8' : '#1A1530'} />
        <div style={{ width: 1, height: 24, background: tweaks.dark ? 'rgba(255,255,255,0.15)' : 'rgba(26,21,48,0.1)' }} />
        {/* Demo shortcut — single APK in production; this lets reviewers preview both flows */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          padding: '4px 4px 4px 10px', borderRadius: 999,
          background: tweaks.dark ? 'rgba(0,0,0,0.3)' : '#1A1530',
        }}>
          <span style={{
            fontSize: 9, fontWeight: 800, letterSpacing: '0.08em',
            color: '#FFD23F', textTransform: 'uppercase',
            paddingInlineEnd: 2,
          }}>{lang === 'ar' ? 'وضع المعاينة' : 'Demo'}</span>
          {[
            { id: 'login', ar: 'تسجيل الدخول', en: 'Login' },
            { id: 'tabs',  ar: 'العميل',       en: 'Customer' },
            { id: 'admin', ar: 'المسؤول',      en: 'Admin' },
          ].map(v => (
            <button key={v.id}
              onClick={() => { setDemoStart(v.id); setAppKey(k => k + 1); }}
              style={{
                padding: '6px 12px', borderRadius: 999, border: 'none', cursor: 'pointer',
                background: demoStart === v.id ? '#FFD23F' : 'transparent',
                color: demoStart === v.id ? '#1A1530' : '#FFF7E8',
                fontWeight: 700, fontSize: 11,
                fontFamily: lang === 'ar' ? 'IBM Plex Sans Arabic' : 'Plus Jakarta Sans',
              }}>{lang === 'ar' ? v.ar : v.en}</button>
          ))}
        </div>
        <div style={{ width: 1, height: 24, background: tweaks.dark ? 'rgba(255,255,255,0.15)' : 'rgba(26,21,48,0.1)' }} />
        <button onClick={() => setTweak('lang', lang === 'ar' ? 'en' : 'ar')} style={{
          padding: '7px 12px', borderRadius: 999, border: 'none',
          background: 'transparent', color: tweaks.dark ? '#FFF7E8' : '#1A1530',
          cursor: 'pointer', fontWeight: 700, fontSize: 12,
          display: 'inline-flex', alignItems: 'center', gap: 6,
        }}>
          <I.Globe size={14} /> {lang === 'ar' ? 'English' : 'العربية'}
        </button>
      </div>

      {/* Frame */}
      <TbDeviceFrame
        label={lang === 'ar' ? 'تطبيق teleBabies' : 'teleBabies app'}
        lang={lang} dark={tweaks.dark}>
        <CustomerApp key={appKey}
          lang={lang} dark={tweaks.dark}
          demoStart={demoStart}
          productVariant={tweaks.productVariant}
          homeVariant={tweaks.homeVariant} />
      </TbDeviceFrame>

      <div style={{ height: 60 }} />

      {/* Tweaks panel */}
      <window.TweaksPanel title="Tweaks">
        <window.TweakSection label="Theme">
          <window.TweakToggle label="Dark mode"
            value={tweaks.dark} onChange={v => setTweak('dark', v)} />
          <window.TweakSelect label="Brand accent"
            value={tweaks.accent} onChange={v => setTweak('accent', v)}
            options={[
              { value: 'pink',   label: '🌸 Hot Pink' },
              { value: 'yellow', label: '☀️ Sunshine' },
              { value: 'mint',   label: '🌿 Mint' },
              { value: 'blue',   label: '🌊 Electric Blue' },
              { value: 'purple', label: '💜 Purple' },
              { value: 'coral',  label: '🍑 Coral' },
            ]} />
          <window.TweakRadio label="Card style"
            value={tweaks.cardStyle} onChange={v => setTweak('cardStyle', v)}
            options={[
              { value: 'flat',   label: 'Flat' },
              { value: 'shadow', label: 'Shadow' },
              { value: 'border', label: 'Border' },
            ]} />
          <window.TweakRadio label="Language"
            value={tweaks.lang} onChange={v => setTweak('lang', v)}
            options={[
              { value: 'ar', label: 'العربية' },
              { value: 'en', label: 'English' },
            ]} />
        </window.TweakSection>
        <window.TweakSection label="Variations">
          <window.TweakRadio label="Home hero"
            value={tweaks.homeVariant} onChange={v => setTweak('homeVariant', v)}
            options={[
              { value: 'a', label: 'Pink Eid' },
              { value: 'b', label: 'Mint→Blue' },
            ]} />
          <window.TweakRadio label="Product page"
            value={tweaks.productVariant} onChange={v => setTweak('productVariant', v)}
            options={[
              { value: 'a', label: 'Rounded' },
              { value: 'b', label: 'Full bleed' },
            ]} />
        </window.TweakSection>
      </window.TweaksPanel>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<Root />);
