// teleBabies — Browse / Search / Product / Cart screens

const { TB_DATA: TBD } = window;
const { fmtYER: f$, t: _t, ProductImg: PImg, Stars: SR } = window.TB;

// ─── BROWSE / SEARCH ───
function BrowseScreen({ lang, onProduct, initialCat = 'all', initialQuery = '' }) {
  const [query, setQuery] = useState(initialQuery);
  const [cat, setCat] = useState(initialCat);
  const [age, setAge] = useState(null);
  const [type, setType] = useState(null);
  const [showFilter, setShowFilter] = useState(false);

  const filtered = useMemo(() => {
    return TBD.PRODUCTS.filter(p => {
      if (cat !== 'all' && cat !== 'sale' && cat !== 'newborn' && p.cat !== cat && p.type !== cat) return false;
      if (cat === 'sale' && !p.oldPrice) return false;
      if (cat === 'newborn' && p.age !== '0-2') return false;
      if (age && p.age !== age) return false;
      if (type && p.type !== type) return false;
      if (query) {
        const q = query.toLowerCase();
        if (!p.name_en.toLowerCase().includes(q) && !p.name_ar.includes(query)) return false;
      }
      return true;
    });
  }, [cat, age, type, query]);

  return (
    <div className="tb-scroll" style={{ background: 'var(--tb-bg)' }}>
      <div style={{ padding: '12px 18px 8px' }}>
        <div className="tb-display" style={{ fontSize: 24, fontWeight: 800, marginBottom: 12 }}>
          {_t(lang, 'تسوق الكاتالوج', 'Browse catalog')}
        </div>
        {/* Search */}
        <div style={{ position: 'relative', marginBottom: 12 }}>
          <I.Search size={18} style={{
            position: 'absolute', top: '50%', transform: 'translateY(-50%)',
            [lang === 'ar' ? 'right' : 'left']: 16, color: 'var(--tb-ink-3)',
          }} />
          <input
            value={query} onChange={e => setQuery(e.target.value)}
            placeholder={_t(lang, 'ابحث عن فستان، تيشرت...', 'Search for a dress, tee...')}
            className="tb-input"
            style={{ [lang === 'ar' ? 'paddingRight' : 'paddingLeft']: 44 }} />
          <button onClick={() => setShowFilter(v => !v)} style={{
            position: 'absolute', top: '50%', transform: 'translateY(-50%)',
            [lang === 'ar' ? 'left' : 'right']: 6,
            width: 38, height: 38, borderRadius: 12,
            background: showFilter ? 'var(--tb-ink)' : 'var(--tb-bg)',
            color: showFilter ? 'var(--tb-cream)' : 'var(--tb-ink)',
            border: 'none', cursor: 'pointer',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <I.Filter size={18} />
          </button>
        </div>
      </div>

      {/* Category chips */}
      <div className="tb-no-scrollbar" style={{
        display: 'flex', gap: 8, overflowX: 'auto', padding: '4px 18px 12px',
      }}>
        {TBD.CATEGORIES.map(c => {
          const CatIcon = I[c.icon];
          return (
            <button key={c.id} onClick={() => setCat(c.id)}
              className="tb-chip" data-active={cat === c.id}>
              {CatIcon ? <CatIcon size={14} strokeWidth={2.2} /> : null}
              <span>{_t(lang, c.ar, c.en)}</span>
            </button>
          );
        })}
      </div>

      {/* Filter drawer */}
      {showFilter && (
        <div className="tb-pop" style={{
          margin: '0 18px 12px', padding: 14, borderRadius: 18,
          background: 'var(--tb-card)', border: '1px solid var(--tb-line)',
        }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--tb-ink-3)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            {_t(lang, 'الفئة العمرية', 'Age group')}
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 14 }}>
            {TBD.AGE_FILTERS.map(a => (
              <button key={a.id} onClick={() => setAge(age === a.id ? null : a.id)}
                className="tb-chip" data-active={age === a.id} style={{ fontSize: 12, padding: '6px 12px' }}>
                {_t(lang, a.ar, a.en)}
              </button>
            ))}
          </div>
          <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--tb-ink-3)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            {_t(lang, 'النوع', 'Type')}
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {TBD.TYPE_FILTERS.map(tp => (
              <button key={tp.id} onClick={() => setType(type === tp.id ? null : tp.id)}
                className="tb-chip" data-active={type === tp.id} style={{ fontSize: 12, padding: '6px 12px' }}>
                {_t(lang, tp.ar, tp.en)}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Results count */}
      <div style={{ padding: '0 18px 10px', fontSize: 13, color: 'var(--tb-ink-3)' }}>
        {_t(lang, `${filtered.length} منتج`, `${filtered.length} products`)}
      </div>

      {/* Grid */}
      <div style={{ padding: '0 18px 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {filtered.map(p => <window.TBProductCard key={p.id} p={p} lang={lang} onClick={() => onProduct(p.id)} />)}
        {filtered.length === 0 && (
          <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '40px 20px', color: 'var(--tb-ink-3)' }}>
            <div style={{ fontSize: 40, marginBottom: 8 }}>🔍</div>
            <div style={{ fontWeight: 700, marginBottom: 4 }}>{_t(lang, 'لم نجد نتائج', 'No results found')}</div>
            <div style={{ fontSize: 13 }}>{_t(lang, 'جرّب كلمة مختلفة', 'Try a different keyword')}</div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── PRODUCT DETAIL ───
function ProductScreen({ lang, productId, onBack, onAddCart, variant = 'a' }) {
  const p = TBD.PRODUCTS.find(x => x.id === productId) || TBD.PRODUCTS[0];
  const [size, setSize] = useState(p.sizes[1]);
  const [qty, setQty] = useState(1);
  const [liked, setLiked] = useState(false);

  // Variant A: hero image with overlap card
  // Variant B: full-bleed image with floating buttons
  // Variant C: split image+info with color swatches
  const isB = variant === 'b';
  const isC = variant === 'c';

  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div className="tb-scroll" style={{ flex: 1 }}>
        {/* Image area */}
        <div style={{
          height: isC ? 320 : 360,
          background: p.color,
          position: 'relative',
          borderBottomLeftRadius: isB ? 0 : 32,
          borderBottomRightRadius: isB ? 0 : 32,
          overflow: 'hidden',
        }}>
          <PImg src={p.img} color={p.color} alt={p.name_en} style={{ position: 'absolute', inset: 0 }} />
          {/* Top buttons */}
          <div style={{ position: 'absolute', top: 14, left: 14, right: 14, display: 'flex', justifyContent: 'space-between' }}>
            <button onClick={onBack} style={{
              width: 42, height: 42, borderRadius: '50%',
              background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)',
              border: 'none', cursor: 'pointer', color: 'var(--tb-ink)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{lang === 'ar' ? <I.ChevronR /> : <I.ChevronL />}</button>
            <button onClick={() => setLiked(v => !v)} style={{
              width: 42, height: 42, borderRadius: '50%',
              background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)',
              border: 'none', cursor: 'pointer',
              color: liked ? 'var(--tb-pink)' : 'var(--tb-ink)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><I.Heart strokeWidth={liked ? 0 : 2} style={{ fill: liked ? 'var(--tb-pink)' : 'transparent' }} /></button>
          </div>
          {/* Image dots */}
          <div style={{ position: 'absolute', bottom: 18, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 6 }}>
            {[0, 1, 2, 3].map(i => (
              <div key={i} style={{
                width: i === 0 ? 22 : 6, height: 6, borderRadius: 3,
                background: i === 0 ? 'var(--tb-ink)' : 'rgba(255,255,255,0.6)',
                transition: 'width 0.2s',
              }} />
            ))}
          </div>
        </div>

        {/* Content */}
        <div style={{
          padding: '20px 18px 100px',
          background: 'var(--tb-bg)',
          marginTop: isB ? -28 : 0,
          borderTopLeftRadius: isB ? 28 : 0,
          borderTopRightRadius: isB ? 28 : 0,
          position: 'relative',
        }}>
          {/* Tag + rating */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
            {p.tag_en ? (
              <div className="tb-tag" style={{ background: 'var(--tb-yellow)', color: 'var(--tb-ink)' }}>
                {_t(lang, p.tag_ar, p.tag_en)}
              </div>
            ) : <div />}
            <SR value={4.6} count={128} />
          </div>

          <div className="tb-display" style={{ fontSize: 24, fontWeight: 800, lineHeight: 1.2, marginBottom: 6 }}>
            {_t(lang, p.name_ar, p.name_en)}
          </div>
          <div style={{ fontSize: 13, color: 'var(--tb-ink-3)', marginBottom: 14 }}>
            {_t(lang, `الفئة العمرية: ${p.age} سنة`, `For ${p.age} years`)} · {_t(lang, `متوفر: ${p.stock}`, `${p.stock} in stock`)}
          </div>

          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginBottom: 18 }}>
            <span style={{ fontSize: 28, fontWeight: 800, color: 'var(--tb-accent)' }}>
              {f$(p.price, lang)}
            </span>
            {p.oldPrice && (
              <span style={{ fontSize: 16, color: 'var(--tb-ink-3)', textDecoration: 'line-through' }}>
                {f$(p.oldPrice, lang)}
              </span>
            )}
          </div>

          {/* Sizes */}
          <div style={{ marginBottom: 18 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
              <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)' }}>
                {_t(lang, 'المقاس', 'Size')}
              </div>
              <span style={{ fontSize: 12, color: 'var(--tb-accent)', fontWeight: 700 }}>
                {_t(lang, 'دليل المقاسات', 'Size guide')}
              </span>
            </div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {p.sizes.map(s => (
                <button key={s} onClick={() => setSize(s)} style={{
                  minWidth: 56, height: 44, borderRadius: 14, padding: '0 14px',
                  background: size === s ? 'var(--tb-ink)' : 'var(--tb-card)',
                  color: size === s ? 'var(--tb-cream)' : 'var(--tb-ink)',
                  border: size === s ? '1.5px solid var(--tb-ink)' : '1.5px solid var(--tb-line)',
                  fontWeight: 700, fontSize: 14, cursor: 'pointer', fontFamily: 'inherit',
                }}>{s}</button>
              ))}
            </div>
          </div>

          {/* Quantity */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
            <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)' }}>
              {_t(lang, 'الكمية', 'Quantity')}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14, background: 'var(--tb-card)', borderRadius: 999, padding: 4, border: '1px solid var(--tb-line)' }}>
              <button onClick={() => setQty(q => Math.max(1, q - 1))} style={{
                width: 36, height: 36, borderRadius: '50%', border: 'none',
                background: 'transparent', cursor: 'pointer', color: 'var(--tb-ink)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}><I.Minus size={18} /></button>
              <span style={{ minWidth: 20, textAlign: 'center', fontWeight: 800, fontSize: 16 }}>{qty}</span>
              <button onClick={() => setQty(q => Math.min(p.stock, q + 1))} style={{
                width: 36, height: 36, borderRadius: '50%', border: 'none',
                background: 'var(--tb-ink)', cursor: 'pointer', color: 'var(--tb-cream)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}><I.Plus size={18} /></button>
            </div>
          </div>

          {/* Description */}
          <div style={{ marginBottom: 16 }}>
            <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)', marginBottom: 6 }}>
              {_t(lang, 'الوصف', 'Description')}
            </div>
            <div style={{ fontSize: 14, lineHeight: 1.6, color: 'var(--tb-ink-2)' }}>
              {_t(lang, p.desc_ar, p.desc_en)}
            </div>
          </div>

          {/* Reviews */}
          <ReviewsSection lang={lang} productId={p.id} rating={p.rating} reviewCount={p.reviews} />

          {/* Delivery */}
          <div style={{ display: 'flex', gap: 10, padding: 12, borderRadius: 14, background: 'var(--tb-mint-soft)', alignItems: 'center' }}>
            <I.Truck size={22} style={{ color: 'var(--tb-ink)', flexShrink: 0 }} />
            <div style={{ fontSize: 12, color: 'var(--tb-ink)', lineHeight: 1.4 }}>
              <div style={{ fontWeight: 700 }}>{_t(lang, 'توصيل لجميع مدن اليمن', 'Delivery across Yemen')}</div>
              <div style={{ color: 'var(--tb-ink-2)' }}>{_t(lang, '٢-٤ أيام عمل', '2–4 business days')}</div>
            </div>
          </div>
        </div>
      </div>

      {/* Sticky bottom bar */}
      <div style={{
        flexShrink: 0, background: 'var(--tb-card)',
        borderTop: '1px solid var(--tb-line)',
        padding: '12px 18px',
        display: 'flex', gap: 12, alignItems: 'center',
      }}>
        <div>
          <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 600 }}>{_t(lang, 'الإجمالي', 'Total')}</div>
          <div style={{ fontSize: 18, fontWeight: 800 }}>{f$(p.price * qty, lang)}</div>
        </div>
        <button onClick={() => onAddCart(p, qty, size)} className="tb-btn tb-btn-primary" style={{ flex: 1 }}>
          <I.Bag size={18} />
          {_t(lang, 'أضف إلى السلة', 'Add to cart')}
        </button>
      </div>
    </div>
  );
}

// ─── CART ───
function CartScreen({ lang, cart, setCart, onCheckout, onProduct, variant = 'a' }) {
  const subtotal = cart.reduce((s, x) => {
    const p = TBD.PRODUCTS.find(P => P.id === x.id);
    return s + (p ? p.price * x.qty : 0);
  }, 0);
  const shipping = subtotal > 0 ? 1500 : 0;
  const [code, setCode] = useState('');
  const [applied, setApplied] = useState(null);
  const discount = applied ? (applied.type === 'percent' ? Math.round(subtotal * applied.value / 100) : applied.value) : 0;
  const total = Math.max(0, subtotal + shipping - discount);

  const apply = () => {
    const found = TBD.PROMO_CODES.find(c => c.code === code.toUpperCase() && c.active);
    if (found) setApplied(found);
  };

  if (cart.length === 0) {
    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 32, textAlign: 'center', background: 'var(--tb-bg)' }}>
        <div style={{
          width: 120, height: 120, borderRadius: '50%', background: 'var(--tb-yellow)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 56, marginBottom: 18,
        }}>🛍️</div>
        <div className="tb-display" style={{ fontSize: 22, fontWeight: 800, marginBottom: 6 }}>
          {_t(lang, 'سلتك فارغة', 'Your cart is empty')}
        </div>
        <div style={{ fontSize: 14, color: 'var(--tb-ink-2)', marginBottom: 22, maxWidth: 240 }}>
          {_t(lang, 'تسوق أحدث القطع وأضفها إلى سلتك', 'Browse our latest pieces and add them to your cart')}
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div className="tb-scroll" style={{ flex: 1 }}>
        <div style={{ padding: '12px 18px 8px' }}>
          <div className="tb-display" style={{ fontSize: 24, fontWeight: 800 }}>
            {_t(lang, 'سلتي', 'My Cart')} <span style={{ color: 'var(--tb-ink-3)', fontSize: 18, fontWeight: 600 }}>({cart.length})</span>
          </div>
        </div>

        {/* Items */}
        <div style={{ padding: '8px 18px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {cart.map((x, i) => {
            const p = TBD.PRODUCTS.find(P => P.id === x.id);
            if (!p) return null;
            return (
              <div key={i} className="tb-card" style={{ padding: 12, display: 'flex', gap: 12, alignItems: 'center' }}>
                <div onClick={() => onProduct(p.id)} style={{
                  width: 78, height: 78, borderRadius: 14, overflow: 'hidden',
                  background: p.color, flexShrink: 0, cursor: 'pointer',
                }}>
                  <PImg src={p.img} color={p.color} alt={p.name_en} />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 2,
                    whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
                    {_t(lang, p.name_ar, p.name_en)}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', marginBottom: 6 }}>
                    {_t(lang, 'المقاس:', 'Size:')} {x.size}
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--tb-accent)' }}>{f$(p.price * x.qty, lang)}</span>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--tb-bg)', borderRadius: 999, padding: 2 }}>
                      <button onClick={() => setCart(cart.map((c, j) => j === i ? { ...c, qty: Math.max(1, c.qty - 1) } : c))}
                        style={{ width: 26, height: 26, borderRadius: '50%', border: 'none', background: 'var(--tb-card)', cursor: 'pointer', color: 'var(--tb-ink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <I.Minus size={14} />
                      </button>
                      <span style={{ fontWeight: 700, fontSize: 13, minWidth: 16, textAlign: 'center' }}>{x.qty}</span>
                      <button onClick={() => setCart(cart.map((c, j) => j === i ? { ...c, qty: c.qty + 1 } : c))}
                        style={{ width: 26, height: 26, borderRadius: '50%', border: 'none', background: 'var(--tb-ink)', cursor: 'pointer', color: 'var(--tb-cream)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <I.Plus size={14} />
                      </button>
                    </div>
                  </div>
                </div>
                <button onClick={() => setCart(cart.filter((_, j) => j !== i))} style={{
                  width: 32, height: 32, borderRadius: '50%', border: 'none', background: 'transparent', cursor: 'pointer',
                  color: 'var(--tb-ink-3)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}><I.Trash size={18} /></button>
              </div>
            );
          })}
        </div>

        {/* Promo code */}
        <div style={{ padding: '14px 18px 8px' }}>
          <div className="tb-card" style={{
            padding: '6px 6px 6px 14px',
            paddingInlineStart: 14, paddingInlineEnd: 6,
            display: 'flex', gap: 10, alignItems: 'center',
            transition: 'border-color 200ms ease, box-shadow 200ms ease',
            borderColor: applied ? 'var(--tb-mint)' : undefined,
          }}>
            <I.Tag size={18} style={{ color: applied ? 'var(--tb-mint)' : 'var(--tb-accent)', flexShrink: 0 }} />
            <input value={code} onChange={e => setCode(e.target.value.toUpperCase())}
              onKeyDown={e => { if (e.key === 'Enter') apply(); }}
              placeholder={_t(lang, 'كود الخصم', 'Promo code')}
              style={{
                flex: 1, minWidth: 0,
                border: 'none', outline: 'none', background: 'transparent',
                fontSize: 14, fontWeight: 700, color: 'var(--tb-ink)', fontFamily: 'inherit',
                letterSpacing: '0.04em', textTransform: 'uppercase',
                padding: '10px 0',
              }} />
            <button onClick={apply} disabled={!code.trim()} style={{
              flexShrink: 0,
              padding: '10px 18px', borderRadius: 999, border: 'none',
              background: code.trim() ? 'var(--tb-ink)' : 'var(--tb-line)',
              color: code.trim() ? 'var(--tb-cream)' : 'var(--tb-ink-3)',
              cursor: code.trim() ? 'pointer' : 'not-allowed',
              fontSize: 13, fontWeight: 700, fontFamily: 'inherit',
              transition: 'background 180ms ease, transform 180ms ease',
            }}>{_t(lang, 'تطبيق', 'Apply')}</button>
          </div>
          {applied && (
            <div style={{ fontSize: 12, color: 'var(--tb-mint-dark, #1F8A6B)', fontWeight: 700, padding: '8px 4px', display: 'flex', alignItems: 'center', gap: 6 }}>
              <I.Check size={14} /> {_t(lang, applied.ar, applied.en)}
            </div>
          )}
        </div>

        {/* Summary */}
        <div style={{ padding: '8px 18px 24px' }}>
          <div className="tb-card" style={{ padding: 16 }}>
            <Row lang={lang} ar="المجموع الفرعي" en="Subtotal" v={f$(subtotal, lang)} />
            <Row lang={lang} ar="التوصيل" en="Delivery" v={f$(shipping, lang)} />
            {discount > 0 && <Row lang={lang} ar="الخصم" en="Discount" v={`- ${f$(discount, lang)}`} accent />}
            <div style={{ height: 1, background: 'var(--tb-line)', margin: '12px 0' }} />
            <Row lang={lang} ar="الإجمالي" en="Total" v={f$(total, lang)} big />
          </div>
        </div>
      </div>

      {/* Checkout button */}
      <div style={{ flexShrink: 0, padding: '12px 18px', background: 'var(--tb-card)', borderTop: '1px solid var(--tb-line)' }}>
        <button onClick={() => onCheckout(total)} className="tb-btn tb-btn-accent" style={{ width: '100%' }}>
          {_t(lang, 'إتمام الطلب', 'Checkout')} · {f$(total, lang)}
          {lang === 'ar' ? <I.ArrowL size={18} /> : <I.ArrowR size={18} />}
        </button>
      </div>
    </div>
  );
}

function Row({ lang, ar, en, v, big, accent }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: big ? 0 : 8 }}>
      <span style={{ fontSize: big ? 16 : 14, color: big ? 'var(--tb-ink)' : 'var(--tb-ink-2)', fontWeight: big ? 700 : 500 }}>
        {_t(lang, ar, en)}
      </span>
      <span style={{
        fontSize: big ? 20 : 14,
        fontWeight: big ? 800 : 700,
        color: accent ? 'var(--tb-mint)' : 'var(--tb-ink)',
      }}>{v}</span>
    </div>
  );
}

window.TBBrowse = BrowseScreen;
window.TBProduct = ProductScreen;
window.TBCart = CartScreen;

// ─── REVIEWS ───
function ReviewsSection({ lang, productId }) {
  const reviews = (TBD.REVIEWS && TBD.REVIEWS[productId]) || [];
  const [expanded, setExpanded] = useState(false);
  const [composing, setComposing] = useState(false);
  const [draftRating, setDraftRating] = useState(0);
  const [draftText, setDraftText] = useState('');

  if (reviews.length === 0) {
    return (
      <div style={{ marginBottom: 16, padding: 16, borderRadius: 18, background: 'var(--tb-card)', border: '1px solid var(--tb-line)', textAlign: 'center' }}>
        <div style={{ fontSize: 32, marginBottom: 6 }}>⭐</div>
        <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 4 }}>
          {_t(lang, 'كن أول من يقيّم', 'Be the first to review')}
        </div>
        <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', marginBottom: 12 }}>
          {_t(lang, 'شاركنا رأيك بعد التجربة', 'Share your thoughts after trying it')}
        </div>
        <button onClick={() => setComposing(true)} className="tb-btn tb-btn-soft" style={{ fontSize: 13 }}>
          <I.Pencil size={14} /> {_t(lang, 'اكتب تقييماً', 'Write a review')}
        </button>
      </div>
    );
  }

  const avg = reviews.reduce((s, r) => s + r.rating, 0) / reviews.length;
  const breakdown = [5, 4, 3, 2, 1].map(n => ({
    n, count: reviews.filter(r => r.rating === n).length,
  }));
  const total = reviews.length;
  const visible = expanded ? reviews : reviews.slice(0, 2);

  const submit = () => {
    if (draftRating > 0 && draftText.trim()) {
      // In a real app, POST. Here, prepend optimistically:
      reviews.unshift({
        id: 'r-new-' + Date.now(),
        name_ar: 'أنت', name_en: 'You',
        rating: draftRating,
        date_ar: 'الآن', date_en: 'Just now',
        text_ar: draftText, text_en: draftText,
        verified: true, helpful: 0,
      });
      setDraftRating(0); setDraftText(''); setComposing(false); setExpanded(true);
    }
  };

  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
        <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)' }}>
          {_t(lang, 'التقييمات', 'Reviews')}
        </div>
        <button onClick={() => setComposing(v => !v)} style={{
          background: 'none', border: 'none', color: 'var(--tb-accent)', fontWeight: 700, fontSize: 12,
          cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 4, padding: 4,
          fontFamily: 'inherit',
        }}>
          <I.Pencil size={13} />
          {_t(lang, 'اكتب تقييم', 'Write one')}
        </button>
      </div>

      {/* Summary card */}
      <div className="tb-card" style={{ padding: 14, marginBottom: 10, display: 'flex', gap: 16, alignItems: 'center' }}>
        <div style={{ textAlign: 'center', flexShrink: 0, minWidth: 64 }}>
          <div style={{ fontSize: 32, fontWeight: 800, lineHeight: 1, fontFamily: 'var(--tb-font-display)' }}>
            {avg.toFixed(1)}
          </div>
          <div style={{ marginTop: 4 }}>
            <SR value={avg} size={12} />
          </div>
          <div style={{ fontSize: 10, color: 'var(--tb-ink-3)', marginTop: 4, fontWeight: 600 }}>
            {total} {_t(lang, 'تقييم', total === 1 ? 'review' : 'reviews')}
          </div>
        </div>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
          {breakdown.map(b => {
            const pct = total ? (b.count / total) * 100 : 0;
            return (
              <div key={b.n} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--tb-ink-2)', width: 10, textAlign: 'center' }}>{b.n}</span>
                <I.Star size={10} style={{ color: 'var(--tb-yellow)', fill: 'var(--tb-yellow)', flexShrink: 0 }} />
                <div style={{ flex: 1, height: 6, background: 'var(--tb-bg)', borderRadius: 999, overflow: 'hidden' }}>
                  <div style={{ width: `${pct}%`, height: '100%', background: 'var(--tb-accent)', borderRadius: 999, transition: 'width 400ms ease' }} />
                </div>
                <span style={{ fontSize: 10, color: 'var(--tb-ink-3)', fontWeight: 600, minWidth: 14, textAlign: 'center' }}>{b.count}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Compose form */}
      {composing && (
        <div className="tb-card" style={{ padding: 14, marginBottom: 10, border: '1.5px solid var(--tb-accent)' }}>
          <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 8 }}>
            {_t(lang, 'كيف كانت تجربتك؟', 'How was your experience?')}
          </div>
          <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
            {[1,2,3,4,5].map(n => (
              <button key={n} onClick={() => setDraftRating(n)} style={{
                background: 'none', border: 'none', cursor: 'pointer', padding: 2,
                color: n <= draftRating ? 'var(--tb-yellow)' : 'var(--tb-line)',
                transition: 'transform 120ms ease',
                transform: n <= draftRating ? 'scale(1.05)' : 'scale(1)',
              }}>
                <I.Star size={26} fill={n <= draftRating ? 'var(--tb-yellow)' : 'transparent'} />
              </button>
            ))}
          </div>
          <textarea
            value={draftText} onChange={e => setDraftText(e.target.value)}
            placeholder={_t(lang, 'شاركنا تجربتك مع المنتج…', 'Tell us about the product…')}
            rows={3}
            style={{
              width: '100%', boxSizing: 'border-box',
              padding: 10, borderRadius: 12, border: '1px solid var(--tb-line)',
              background: 'var(--tb-bg)', fontSize: 13, fontFamily: 'inherit',
              resize: 'none', outline: 'none', color: 'var(--tb-ink)',
            }}
          />
          <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            <button onClick={submit} disabled={!draftRating || !draftText.trim()}
              className="tb-btn tb-btn-primary" style={{
                flex: 1, fontSize: 13, padding: '10px 14px',
                opacity: (!draftRating || !draftText.trim()) ? 0.5 : 1,
                cursor: (!draftRating || !draftText.trim()) ? 'not-allowed' : 'pointer',
              }}>
              {_t(lang, 'نشر التقييم', 'Post review')}
            </button>
            <button onClick={() => { setComposing(false); setDraftRating(0); setDraftText(''); }}
              className="tb-btn tb-btn-soft" style={{ fontSize: 13, padding: '10px 14px' }}>
              {_t(lang, 'إلغاء', 'Cancel')}
            </button>
          </div>
        </div>
      )}

      {/* Reviews list */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {visible.map(r => (
          <ReviewItem key={r.id} r={r} lang={lang} />
        ))}
      </div>

      {/* See all */}
      {reviews.length > 2 && (
        <button onClick={() => setExpanded(v => !v)} style={{
          marginTop: 10, width: '100%', padding: '11px 14px',
          background: 'transparent', border: '1.5px solid var(--tb-line)',
          borderRadius: 14, fontSize: 13, fontWeight: 700, color: 'var(--tb-ink)',
          cursor: 'pointer', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          fontFamily: 'inherit',
        }}>
          {expanded
            ? _t(lang, 'عرض أقل', 'Show less')
            : _t(lang, `عرض الكل (${reviews.length})`, `Show all (${reviews.length})`)}
          <I.ChevronDown size={14} style={{ transform: expanded ? 'rotate(180deg)' : 'none', transition: 'transform 200ms ease' }} />
        </button>
      )}
    </div>
  );
}

function ReviewItem({ r, lang }) {
  const [helpful, setHelpful] = useState(false);
  const initial = (lang === 'ar' ? r.name_ar : r.name_en).charAt(0);
  const colors = ['#FF8FB1', '#A6C8FF', '#FFD23F', '#7CE0C5', '#E8B4F8'];
  const color = colors[r.id.charCodeAt(r.id.length - 1) % colors.length];
  return (
    <div className="tb-card" style={{ padding: 14 }}>
      <div style={{ display: 'flex', gap: 10, alignItems: 'center', marginBottom: 8 }}>
        <div style={{
          width: 36, height: 36, borderRadius: '50%', background: color,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 800, color: 'var(--tb-ink)', fontSize: 14,
          fontFamily: 'var(--tb-font-display)', flexShrink: 0,
        }}>{initial}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
            <span style={{ fontSize: 13, fontWeight: 700 }}>{_t(lang, r.name_ar, r.name_en)}</span>
            {r.verified && (
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 3,
                fontSize: 10, fontWeight: 700,
                color: 'var(--tb-mint-dark, #1F8A6B)',
                background: 'var(--tb-mint-soft)',
                padding: '2px 7px', borderRadius: 999,
              }}>
                <I.Check size={10} />
                {_t(lang, 'شراء موثق', 'Verified')}
              </span>
            )}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 2 }}>
            <SR value={r.rating} size={11} />
            <span style={{ fontSize: 11, color: 'var(--tb-ink-3)' }}>· {_t(lang, r.date_ar, r.date_en)}</span>
          </div>
        </div>
      </div>
      <div style={{ fontSize: 13, lineHeight: 1.55, color: 'var(--tb-ink)', marginBottom: 10 }}>
        {_t(lang, r.text_ar, r.text_en)}
      </div>
      <button onClick={() => setHelpful(v => !v)} style={{
        background: helpful ? 'var(--tb-accent-soft, rgba(220,90,60,0.08))' : 'transparent',
        border: '1px solid', borderColor: helpful ? 'var(--tb-accent)' : 'var(--tb-line)',
        color: helpful ? 'var(--tb-accent)' : 'var(--tb-ink-2)',
        borderRadius: 999, padding: '5px 11px', fontSize: 11, fontWeight: 700,
        cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 5,
        fontFamily: 'inherit', transition: 'all 180ms ease',
      }}>
        <I.ThumbsUp size={12} fill={helpful ? 'var(--tb-accent)' : 'none'} />
        {_t(lang, 'مفيد', 'Helpful')} ({r.helpful + (helpful ? 1 : 0)})
      </button>
    </div>
  );
}
