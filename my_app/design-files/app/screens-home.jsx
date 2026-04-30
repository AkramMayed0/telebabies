// teleBabies — Customer screens
const { useState: uSh } = React;
const { TB_DATA } = window;
const { fmtYER, t, TbLogo, TbWordmark, TbStatusBar, TbNavBar, TbHeader, TbTabBar, Stars, ProductImg } = window.TB;

// ─── HOME SCREEN ───
function HomeScreen({ lang, dark, user, onProduct, onCategory, onSearch, variant = 'a' }) {
  const featured = TB_DATA.PRODUCTS.slice(0, 4);
  const trending = TB_DATA.PRODUCTS.slice(2, 6);
  const displayName = user && user.name
    ? user.name
    : t(lang, 'أم عبدالله', 'Umm Abdullah');

  return (
    <div className="tb-scroll" style={{ padding: '0 0 24px', background: 'var(--tb-bg)' }}>
      {/* Top header — greeting */}
      <div style={{
        padding: '12px 18px 14px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div>
          <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', fontWeight: 600 }}>
            {t(lang, 'مرحباً، 👋', 'Welcome back, 👋')}
          </div>
          <div className="tb-display" style={{ fontSize: 20, fontWeight: 800, color: 'var(--tb-ink)' }}>
            {displayName}
          </div>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <button style={{
            width: 42, height: 42, borderRadius: '50%',
            background: 'var(--tb-card)', border: '1px solid var(--tb-line)',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer', color: 'var(--tb-ink)', position: 'relative',
          }}>
            <I.Bell size={20} />
            <span style={{
              position: 'absolute', top: 8, [lang === 'ar' ? 'left' : 'right']: 10,
              width: 8, height: 8, borderRadius: '50%', background: 'var(--tb-pink)',
              border: '2px solid var(--tb-card)',
            }} />
          </button>
        </div>
      </div>

      {/* Hero — bright illustrative banner with sale offer */}
      <div style={{ padding: '0 18px 18px' }}>
        <div style={{
          background: variant === 'b'
            ? 'linear-gradient(135deg, var(--tb-mint) 0%, var(--tb-blue) 100%)'
            : 'var(--tb-pink)',
          borderRadius: 'var(--tb-radius-lg)',
          padding: '22px 22px 20px',
          color: '#fff',
          position: 'relative', overflow: 'hidden',
          minHeight: 170,
        }}>
          {/* Decorative shapes */}
          <div style={{ position: 'absolute', top: -28, [lang === 'ar' ? 'left' : 'right']: -28, width: 130, height: 130, borderRadius: '50%', background: 'rgba(255,255,255,0.18)' }} />
          <div style={{ position: 'absolute', bottom: -45, [lang === 'ar' ? 'left' : 'right']: 45, width: 90, height: 90, borderRadius: '50%', background: 'rgba(255,255,255,0.12)' }} />
          <I.Star size={20} style={{ position: 'absolute', top: 18, [lang === 'ar' ? 'left' : 'right']: 80, fill: 'var(--tb-yellow)', stroke: 'var(--tb-yellow)' }} />
          <I.Star size={14} style={{ position: 'absolute', top: 60, [lang === 'ar' ? 'left' : 'right']: 30, fill: 'var(--tb-yellow)', stroke: 'var(--tb-yellow)' }} />

          <div style={{ display: 'inline-block', padding: '5px 12px', background: 'var(--tb-yellow)', color: 'var(--tb-ink)', borderRadius: 999, fontSize: 11, fontWeight: 800, letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 10 }}>
            {t(lang, '🎁 عيد سعيد', '🎁 Eid offer')}
          </div>
          <div className="tb-display" style={{ fontSize: 26, fontWeight: 800, lineHeight: 1.1, marginBottom: 6, maxWidth: '70%' }}>
            {t(lang, 'خصم ٢٠٪ على فساتين العيد', '20% off Eid dresses')}
          </div>
          <div style={{ fontSize: 13, opacity: 0.9, marginBottom: 14, maxWidth: '70%' }}>
            {t(lang, 'استخدم الكود EID2026', 'Use code EID2026')}
          </div>
          <button onClick={onSearch} style={{
            background: 'var(--tb-ink)', color: '#fff', border: 'none',
            padding: '10px 18px', borderRadius: 999, fontWeight: 700, fontSize: 13,
            cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 6,
            fontFamily: 'inherit',
          }}>
            {t(lang, 'تسوق الآن', 'Shop now')}
            {lang === 'ar' ? <I.ArrowL size={14} /> : <I.ArrowR size={14} />}
          </button>
        </div>
      </div>

      {/* Categories */}
      <div style={{ padding: '0 0 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', padding: '0 18px 12px' }}>
          <div className="tb-display" style={{ fontSize: 18, fontWeight: 800 }}>
            {t(lang, 'تصفح حسب الفئة', 'Shop by category')}
          </div>
          <span style={{ fontSize: 12, color: 'var(--tb-ink-3)', fontWeight: 600 }}>
            {t(lang, 'الكل', 'See all')}
          </span>
        </div>
        <div className="tb-no-scrollbar" style={{
          display: 'flex', gap: 12, overflowX: 'auto', padding: '0 18px 4px',
        }}>
          {TB_DATA.CATEGORIES.map(c => {
            const CatIcon = I[c.icon];
            // Pick contrasting ink color for icon based on background
            const isDark = ['#FF4D8D', '#3B6BFF', '#8B5CF6', '#FF6B4A'].includes(c.color);
            return (
              <button key={c.id} onClick={() => onCategory(c.id)} style={{
                flexShrink: 0, width: 78, padding: 0, border: 'none', background: 'transparent',
                cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                fontFamily: 'inherit',
              }}>
                <div style={{
                  width: 64, height: 64, borderRadius: 22,
                  background: c.color, display: 'flex', alignItems: 'center', justifyContent: 'center',
                  boxShadow: '0 4px 12px rgba(26,21,48,0.10)',
                  color: isDark ? '#FFF7E8' : 'var(--tb-ink)',
                }}>
                  {CatIcon ? <CatIcon size={30} strokeWidth={2.2} /> : null}
                </div>
                <span style={{ fontSize: 12, fontWeight: 600, color: 'var(--tb-ink)' }}>
                  {t(lang, c.ar, c.en)}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Featured — large card list */}
      <div style={{ padding: '20px 18px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
          <div className="tb-display" style={{ fontSize: 18, fontWeight: 800 }}>
            {t(lang, 'وصل حديثاً', 'New arrivals')}
          </div>
          <span style={{ fontSize: 12, color: 'var(--tb-ink-3)', fontWeight: 600 }}>
            {t(lang, 'مشاهدة الكل', 'See all')}
          </span>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {featured.map(p => <ProductCard key={p.id} p={p} lang={lang} onClick={() => onProduct(p.id)} />)}
        </div>
      </div>

      {/* Trending strip */}
      <div style={{ padding: '24px 0 0' }}>
        <div style={{ padding: '0 18px 12px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <div className="tb-display" style={{ fontSize: 18, fontWeight: 800, display: 'flex', alignItems: 'center', gap: 6 }}>
            {t(lang, 'الأكثر رواجاً', 'Trending now')}
            <span style={{ fontSize: 18 }}>🔥</span>
          </div>
        </div>
        <div className="tb-no-scrollbar" style={{
          display: 'flex', gap: 12, overflowX: 'auto', padding: '0 18px 4px',
        }}>
          {trending.map(p => (
            <div key={p.id} onClick={() => onProduct(p.id)} className="tb-card" style={{
              flexShrink: 0, width: 150, cursor: 'pointer', overflow: 'hidden',
            }}>
              <div style={{ height: 150, background: p.color, position: 'relative' }}>
                <ProductImg src={p.img} color={p.color} alt={p.name_en}
                  style={{ position: 'absolute', inset: 0 }} />
              </div>
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 2, lineHeight: 1.2,
                  whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
                  {t(lang, p.name_ar, p.name_en)}
                </div>
                <div style={{ fontSize: 13, fontWeight: 800, color: 'var(--tb-accent)' }}>
                  {fmtYER(p.price, lang)}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function ProductCard({ p, lang, onClick }) {
  const [hover, setHover] = uSh(false);
  const [liked, setLiked] = uSh(false);
  return (
    <div
      onClick={onClick}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      className="tb-card tb-product-card"
      style={{
        cursor: 'pointer', overflow: 'hidden', display: 'flex', flexDirection: 'column',
        transition: 'transform 260ms cubic-bezier(.2,.8,.2,1), box-shadow 260ms ease, border-color 260ms ease',
        transform: hover ? 'translateY(-4px)' : 'translateY(0)',
        boxShadow: hover
          ? '0 18px 36px -16px rgba(26,21,48,0.28), 0 4px 10px -4px rgba(26,21,48,0.10)'
          : '0 1px 2px rgba(26,21,48,0.04)',
        willChange: 'transform',
      }}
    >
      <div style={{ aspectRatio: '1 / 1.05', background: p.color, position: 'relative', overflow: 'hidden' }}>
        <ProductImg src={p.img} color={p.color} alt={t(lang, p.name_ar, p.name_en)}
          style={{
            position: 'absolute', inset: 0,
            transition: 'transform 500ms cubic-bezier(.2,.8,.2,1)',
            transform: hover ? 'scale(1.06)' : 'scale(1)',
          }} />
        {p.tag_en && (
          <div className="tb-tag" style={{
            position: 'absolute', top: 10, [lang === 'ar' ? 'right' : 'left']: 10,
            background: 'var(--tb-ink)', color: 'var(--tb-cream)',
            transition: 'transform 220ms ease',
            transform: hover ? 'translateY(-1px)' : 'translateY(0)',
          }}>{t(lang, p.tag_ar, p.tag_en)}</div>
        )}
        <button style={{
          position: 'absolute', top: 10, [lang === 'ar' ? 'left' : 'right']: 10,
          width: 34, height: 34, borderRadius: '50%',
          background: liked ? 'var(--tb-accent)' : 'rgba(255,255,255,0.92)',
          backdropFilter: 'blur(8px)',
          border: 'none', cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          color: liked ? '#fff' : 'var(--tb-ink)',
          transition: 'transform 220ms cubic-bezier(.2,.8,.2,1), background 220ms ease, opacity 220ms ease',
          transform: hover ? 'scale(1.08)' : 'scale(1)',
          boxShadow: hover ? '0 6px 14px -4px rgba(26,21,48,0.25)' : '0 2px 6px rgba(26,21,48,0.10)',
        }}
        onClick={(e) => { e.stopPropagation(); setLiked(v => !v); }}>
          <I.Heart size={18} fill={liked ? '#fff' : 'none'} />
        </button>
        {/* Quick-view "tap to view" affordance */}
        <div style={{
          position: 'absolute', left: 0, right: 0, bottom: 0,
          padding: '20px 12px 10px',
          background: 'linear-gradient(to top, rgba(26,21,48,0.55), rgba(26,21,48,0))',
          color: '#fff', fontSize: 11, fontWeight: 700, letterSpacing: '0.02em',
          textAlign: 'center', pointerEvents: 'none',
          opacity: hover ? 1 : 0,
          transform: hover ? 'translateY(0)' : 'translateY(6px)',
          transition: 'opacity 220ms ease, transform 220ms ease',
        }}>
          {t(lang, 'اضغط لعرض التفاصيل', 'Tap to view details')}
        </div>
      </div>
      <div style={{ padding: 12 }}>
        <div style={{ fontSize: 14, fontWeight: 700, lineHeight: 1.25,
          display: '-webkit-box', WebkitLineClamp: 1, WebkitBoxOrient: 'vertical',
          overflow: 'hidden', marginBottom: 4,
          color: hover ? 'var(--tb-accent)' : 'var(--tb-ink)',
          transition: 'color 220ms ease',
        }}>
          {t(lang, p.name_ar, p.name_en)}
        </div>
        <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', marginBottom: 6 }}>
          {t(lang, `${p.age} سنة`, `${p.age} yrs`)} · {p.sizes.length} {t(lang, 'مقاسات', 'sizes')}
        </div>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
          <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--tb-accent)' }}>
            {fmtYER(p.price, lang)}
          </span>
          {p.oldPrice && (
            <span style={{ fontSize: 12, color: 'var(--tb-ink-3)', textDecoration: 'line-through' }}>
              {fmtYER(p.oldPrice, lang)}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

window.TBHome = HomeScreen;
window.TBProductCard = ProductCard;
