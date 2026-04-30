// teleBabies — shared utilities
const { useState, useEffect, useRef, useMemo, createContext, useContext } = React;

// Format currency — YER with Arabic numerals option
const fmtYER = (n, lang = 'ar') => {
  const s = n.toLocaleString(lang === 'ar' ? 'ar-EG' : 'en-US');
  return lang === 'ar' ? `${s} ر.ي` : `${s} YER`;
};

// Translate helper
const t = (lang, ar, en) => lang === 'ar' ? ar : en;

// Logo component — tb wordmark with smiley
function TbLogo({ size = 28, color = 'var(--tb-ink)', accent = 'var(--tb-accent)' }) {
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', flexShrink: 0 }}>
      <svg width={size} height={size} viewBox="0 0 24 24" style={{ flexShrink: 0, display: 'block' }}>
        <circle cx="12" cy="12" r="11" fill={accent} />
        <circle cx="8.5" cy="10" r="1.5" fill={color} />
        <circle cx="15.5" cy="10" r="1.5" fill={color} />
        <path d="M7.5 14.5 Q12 18.5 16.5 14.5" stroke={color} strokeWidth="1.8" fill="none" strokeLinecap="round" />
      </svg>
    </div>
  );
}

// Wordmark — full
// `color` is the main ink color. `accentColor` overrides the "babies"/"بيبيز" half;
// when not set, it defaults to --tb-accent on light, but falls back to `color` when
// the wordmark is rendered light-on-color (e.g. white on accent hero) so both
// halves remain readable.
function TbWordmark({ lang = 'ar', size = 22, color = 'var(--tb-ink)', accentColor }) {
  // If caller passes white/cream ink, assume colored hero background and reuse ink.
  const isLightInk = typeof color === 'string' && /^#?(fff|FFF|FFF7E8)/.test(color.replace('#',''));
  const accent = accentColor || (isLightInk ? color : 'var(--tb-accent)');
  return (
    <div style={{ display: 'inline-flex', alignItems: 'baseline', gap: 6, color, fontWeight: 800 }}>
      <TbLogo size={size + 4} accent={isLightInk ? 'rgba(255,255,255,0.22)' : 'var(--tb-accent)'} color={color} />
      {lang === 'ar' ? (
        <span style={{ fontSize: size, fontFamily: 'var(--tb-font-ar)', fontWeight: 800, letterSpacing: 0 }}>
          تيلي<span style={{ color: accent, opacity: isLightInk ? 0.85 : 1 }}>بيبيز</span>
        </span>
      ) : (
        <span style={{ fontSize: size, fontFamily: 'var(--tb-font-display)', fontWeight: 800, letterSpacing: '-0.02em' }}>
          tele<span style={{ color: accent, opacity: isLightInk ? 0.85 : 1 }}>babies</span>
        </span>
      )}
    </div>
  );
}

// Status bar — custom (so colors match brand)
function TbStatusBar({ dark = false, lang = 'ar' }) {
  const c = dark ? '#FFF7E8' : 'var(--tb-ink)';
  return (
    <div style={{
      height: 36, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 18px',
      position: 'relative', flexShrink: 0,
      fontFamily: 'var(--tb-font-body)', color: c, fontWeight: 600, fontSize: 13,
    }}>
      <span style={{ fontVariantNumeric: 'tabular-nums' }}>9:30</span>
      <div style={{
        position: 'absolute', left: '50%', top: 8, transform: 'translateX(-50%)',
        width: 22, height: 22, borderRadius: '50%', background: '#1A1530',
      }} />
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        <svg width="14" height="10" viewBox="0 0 14 10"><path d="M2 8 L7 2 L12 8" stroke={c} strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
        <svg width="14" height="10" viewBox="0 0 14 10"><rect x="1" y="6" width="2" height="3" fill={c} /><rect x="5" y="3.5" width="2" height="5.5" fill={c} /><rect x="9" y="1" width="2" height="8" fill={c} /></svg>
        <svg width="22" height="11" viewBox="0 0 22 11"><rect x="0.5" y="0.5" width="18" height="10" rx="2" stroke={c} fill="none" /><rect x="2" y="2" width="14" height="7" rx="1" fill={c} /><rect x="19" y="3.5" width="2" height="4" rx="0.5" fill={c} /></svg>
      </div>
    </div>
  );
}

// Bottom nav bar (gesture)
function TbNavBar({ dark = false }) {
  return (
    <div style={{ height: 22, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <div style={{ width: 110, height: 4, borderRadius: 2, background: dark ? '#FFF7E8' : 'var(--tb-ink)', opacity: 0.5 }} />
    </div>
  );
}

// Top app header — title + back, used inside individual screens
function TbHeader({ title, onBack, right, lang = 'ar', big = false }) {
  return (
    <div style={{
      padding: big ? '20px 18px 12px' : '14px 18px',
      display: 'flex', alignItems: 'center', gap: 10,
      flexShrink: 0,
    }}>
      {onBack && (
        <button onClick={onBack} style={{
          width: 40, height: 40, borderRadius: '50%',
          background: 'var(--tb-card)', border: '1px solid var(--tb-line)',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer', color: 'var(--tb-ink)', flexShrink: 0,
        }}>
          {lang === 'ar' ? <I.ChevronR /> : <I.ChevronL />}
        </button>
      )}
      <div style={{ flex: 1, fontWeight: 700, fontSize: big ? 22 : 17 }} className="tb-display">
        {title}
      </div>
      {right}
    </div>
  );
}

// Bottom tab bar
function TbTabBar({ tab, setTab, lang, cartCount = 0 }) {
  const tabs = [
    { id: 'home',    icon: I.Home,   ar: 'الرئيسية', en: 'Home' },
    { id: 'search',  icon: I.Search, ar: 'تصفح',     en: 'Browse' },
    { id: 'cart',    icon: I.Bag,    ar: 'السلة',    en: 'Cart',    badge: cartCount },
    { id: 'orders',  icon: I.Pkg,    ar: 'طلباتي',   en: 'Orders' },
    { id: 'account', icon: I.User,   ar: 'حسابي',    en: 'Profile' },
  ];
  return (
    <div style={{
      flexShrink: 0,
      background: 'var(--tb-card)',
      borderTop: '1px solid var(--tb-line)',
      padding: '8px 8px 6px',
      display: 'flex',
      justifyContent: 'space-around',
    }}>
      {tabs.map(T => {
        const active = tab === T.id;
        return (
          <button key={T.id} onClick={() => setTab(T.id)} style={{
            flex: 1, padding: '6px 4px', border: 'none', background: 'transparent',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
            cursor: 'pointer', position: 'relative',
            color: active ? 'var(--tb-ink)' : 'var(--tb-ink-3)',
            fontFamily: 'inherit',
          }}>
            <div style={{
              width: 56, height: 30, borderRadius: 999,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: active ? 'var(--tb-accent-soft)' : 'transparent',
              transition: 'background 0.18s ease',
              position: 'relative',
            }}>
              <T.icon size={22} strokeWidth={active ? 2.4 : 1.8} />
              {T.badge > 0 && (
                <div style={{
                  position: 'absolute', top: -2, [lang === 'ar' ? 'left' : 'right']: 8,
                  minWidth: 18, height: 18, borderRadius: 9, padding: '0 5px',
                  background: 'var(--tb-pink)', color: '#fff', fontSize: 10, fontWeight: 800,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  border: '2px solid var(--tb-card)',
                }}>{T.badge}</div>
              )}
            </div>
            <span style={{ fontSize: 11, fontWeight: active ? 700 : 500 }}>
              {t(lang, T.ar, T.en)}
            </span>
          </button>
        );
      })}
    </div>
  );
}

// Star rating
function Stars({ value = 4.6, size = 14, count }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: '#F4B400' }}>
      <I.Star size={size} strokeWidth={2.2} style={{ fill: '#F4B400' }} />
      <span style={{ color: 'var(--tb-ink)', fontSize: 13, fontWeight: 700 }}>{value.toFixed(1)}</span>
      {count !== undefined && <span style={{ color: 'var(--tb-ink-3)', fontSize: 12 }}>({count})</span>}
    </span>
  );
}

// SVG product image — uses a placeholder gradient if image fails
function ProductImg({ src, color, alt, style, fit = 'cover' }) {
  const [errored, setErrored] = useState(false);
  if (errored || !src) {
    return (
      <div style={{
        background: `linear-gradient(135deg, ${color}, ${color}aa)`,
        position: 'relative', overflow: 'hidden', ...style,
      }}>
        <svg viewBox="0 0 100 100" width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
          <path d="M28 35 L40 28 L45 32 Q50 36 55 32 L60 28 L72 35 L66 45 L62 42 V72 H38 V42 L34 45 Z" fill="rgba(255,255,255,0.6)" />
        </svg>
      </div>
    );
  }
  return (
    <img src={src} alt={alt} onError={() => setErrored(true)}
      style={{ width: '100%', height: '100%', objectFit: fit, display: 'block', ...style }} />
  );
}

window.TB = {
  fmtYER, t, TbLogo, TbWordmark, TbStatusBar, TbNavBar, TbHeader, TbTabBar, Stars, ProductImg,
};
