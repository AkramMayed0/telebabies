// teleBabies — Checkout, Order tracking, Account, Login
const { TB_DATA: D2 } = window;
const { fmtYER: fY, t: tt, ProductImg: PI } = window.TB;

// ─── CHECKOUT ───
function CheckoutScreen({ lang, total, onBack, onPlaceOrder, variant = 'a' }) {
  const [step, setStep] = useState(1); // 1 address, 2 payment, 3 receipt
  const [city, setCity] = useState(D2.CITIES[0]);
  const [name, setName] = useState(lang === 'ar' ? 'أم عبدالله' : 'Umm Abdullah');
  const [phone, setPhone] = useState('+967 77 123 4567');
  const [addr, setAddr] = useState(lang === 'ar' ? 'حي الصافية، شارع الستين' : 'Safiya district, 60th street');
  const [pay, setPay] = useState('jaib');
  const [receipt, setReceipt] = useState(null);

  const Steps = () => (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, padding: '6px 18px 14px' }}>
      {[1, 2, 3].map(s => (
        <React.Fragment key={s}>
          <div style={{
            width: 28, height: 28, borderRadius: '50%',
            background: s <= step ? 'var(--tb-ink)' : 'var(--tb-card)',
            color: s <= step ? 'var(--tb-cream)' : 'var(--tb-ink-3)',
            border: s <= step ? 'none' : '1.5px solid var(--tb-line)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, fontWeight: 800,
          }}>{s < step ? <I.Check size={14} /> : s}</div>
          {s < 3 && <div style={{ width: 36, height: 2, background: s < step ? 'var(--tb-ink)' : 'var(--tb-line)' }} />}
        </React.Fragment>
      ))}
    </div>
  );

  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <window.TB.TbHeader lang={lang} onBack={step === 1 ? onBack : () => setStep(step - 1)}
        title={tt(lang, 'إتمام الطلب', 'Checkout')} />
      <Steps />

      <div className="tb-scroll" style={{ flex: 1, padding: '0 18px 16px' }}>
        {step === 1 && (
          <>
            <div className="tb-display" style={{ fontSize: 18, fontWeight: 800, marginBottom: 14 }}>
              {tt(lang, 'عنوان التوصيل', 'Delivery address')}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              <Field lang={lang} ar="الاسم الكامل" en="Full name" value={name} onChange={setName} />
              <Field lang={lang} ar="رقم الهاتف" en="Phone number" value={phone} onChange={setPhone} />
              <div>
                <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 6, color: 'var(--tb-ink-2)' }}>
                  {tt(lang, 'المدينة', 'City')}
                </div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                  {D2.CITIES.map(c => (
                    <button key={c.en} onClick={() => setCity(c)} className="tb-chip" data-active={city.en === c.en}>
                      <I.MapPin size={14} /> {tt(lang, c.ar, c.en)}
                    </button>
                  ))}
                </div>
              </div>
              <Field lang={lang} ar="العنوان التفصيلي" en="Street address" value={addr} onChange={setAddr} />
            </div>
          </>
        )}

        {step === 2 && (
          <>
            <div className="tb-display" style={{ fontSize: 18, fontWeight: 800, marginBottom: 14 }}>
              {tt(lang, 'طريقة الدفع', 'Payment method')}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {D2.PAYMENTS.map(P => (
                <button key={P.id} onClick={() => setPay(P.id)} className="tb-card" style={{
                  padding: 14, display: 'flex', alignItems: 'center', gap: 12,
                  border: pay === P.id ? '2px solid var(--tb-ink)' : '1px solid var(--tb-line)',
                  cursor: 'pointer', textAlign: lang === 'ar' ? 'right' : 'left', fontFamily: 'inherit',
                  background: 'var(--tb-card)',
                }}>
                  <div style={{
                    width: 44, height: 44, borderRadius: 14, background: P.color,
                    display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22,
                  }}>{P.icon}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 15, fontWeight: 700 }}>{tt(lang, P.ar, P.en)}</div>
                    <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', fontFamily: 'var(--tb-font-body)' }}>{P.acct}</div>
                  </div>
                  <div style={{
                    width: 22, height: 22, borderRadius: '50%',
                    border: pay === P.id ? '6px solid var(--tb-ink)' : '2px solid var(--tb-line)',
                    background: 'var(--tb-card)',
                  }} />
                </button>
              ))}
            </div>
            <div style={{ marginTop: 16, padding: 14, borderRadius: 14, background: 'var(--tb-yellow)', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
              <I.Wallet size={20} style={{ color: 'var(--tb-ink)', flexShrink: 0, marginTop: 2 }} />
              <div style={{ fontSize: 12, color: 'var(--tb-ink)', lineHeight: 1.5 }}>
                <div style={{ fontWeight: 800, marginBottom: 2 }}>
                  {tt(lang, 'كيف يعمل الدفع؟', 'How payment works')}
                </div>
                {tt(lang,
                  'حوّل المبلغ إلى الحساب أعلاه، ثم ارفع صورة الإيصال. سنؤكد طلبك خلال ساعة.',
                  'Transfer to the account above, then upload the receipt. We\'ll confirm your order within an hour.')}
              </div>
            </div>
          </>
        )}

        {step === 3 && (
          <>
            <div className="tb-display" style={{ fontSize: 18, fontWeight: 800, marginBottom: 6 }}>
              {tt(lang, 'رفع إيصال الدفع', 'Upload payment receipt')}
            </div>
            <div style={{ fontSize: 13, color: 'var(--tb-ink-2)', marginBottom: 18, lineHeight: 1.5 }}>
              {tt(lang,
                `حوّل ${fY(total, lang)} إلى ${D2.PAYMENTS.find(p => p.id === pay).acct} وارفع صورة الإيصال.`,
                `Transfer ${fY(total, lang)} to ${D2.PAYMENTS.find(p => p.id === pay).acct} and upload your receipt.`)}
            </div>

            <label htmlFor="receipt-file" style={{
              display: 'block', padding: '32px 20px',
              borderRadius: 22,
              border: receipt ? 'none' : '2px dashed var(--tb-ink-3)',
              background: receipt ? 'var(--tb-mint-soft)' : 'var(--tb-card)',
              textAlign: 'center', cursor: 'pointer',
              transition: 'all 0.2s',
            }}>
              {receipt ? (
                <div>
                  <div style={{
                    width: 68, height: 68, borderRadius: 16, background: 'var(--tb-ink)',
                    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                    color: 'var(--tb-cream)', marginBottom: 10,
                  }}><I.Check size={32} strokeWidth={3} /></div>
                  <div style={{ fontWeight: 800, fontSize: 15, marginBottom: 4 }}>
                    {tt(lang, 'تم رفع الإيصال', 'Receipt uploaded')}
                  </div>
                  <div style={{ fontSize: 13, color: 'var(--tb-ink-2)' }}>
                    receipt_{Date.now().toString().slice(-6)}.jpg · 1.2 MB
                  </div>
                  <div onClick={(e) => { e.preventDefault(); setReceipt(null); }} style={{ fontSize: 12, color: 'var(--tb-accent)', fontWeight: 700, marginTop: 10, textDecoration: 'underline' }}>
                    {tt(lang, 'استبدال الصورة', 'Replace image')}
                  </div>
                </div>
              ) : (
                <div>
                  <div style={{
                    width: 68, height: 68, borderRadius: 16, background: 'var(--tb-yellow)',
                    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                    color: 'var(--tb-ink)', marginBottom: 10,
                  }}><I.Camera size={32} /></div>
                  <div style={{ fontWeight: 800, fontSize: 15, marginBottom: 4 }}>
                    {tt(lang, 'اضغط لرفع صورة الإيصال', 'Tap to upload receipt')}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--tb-ink-3)' }}>
                    {tt(lang, 'JPG أو PNG، حتى ٥ ميجا', 'JPG or PNG, up to 5MB')}
                  </div>
                </div>
              )}
              <input id="receipt-file" type="file" accept="image/*" style={{ display: 'none' }}
                onChange={(e) => { if (e.target.files?.[0]) setReceipt(e.target.files[0]); }} />
            </label>

            {/* Order summary */}
            <div className="tb-card" style={{ padding: 14, marginTop: 18 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ color: 'var(--tb-ink-3)', fontSize: 13 }}>{tt(lang, 'المبلغ', 'Amount')}</span>
                <span style={{ fontWeight: 700 }}>{fY(total, lang)}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--tb-ink-3)', fontSize: 13 }}>{tt(lang, 'الطريقة', 'Method')}</span>
                <span style={{ fontWeight: 700 }}>{tt(lang, D2.PAYMENTS.find(p => p.id === pay).ar, D2.PAYMENTS.find(p => p.id === pay).en)}</span>
              </div>
            </div>
          </>
        )}
      </div>

      <div style={{ flexShrink: 0, padding: '12px 18px', background: 'var(--tb-card)', borderTop: '1px solid var(--tb-line)' }}>
        <button onClick={() => {
          if (step < 3) setStep(step + 1);
          else onPlaceOrder({ name, phone, city, addr, pay, receipt });
        }} className="tb-btn tb-btn-primary" style={{ width: '100%' }}
        disabled={step === 3 && !receipt}>
          {step < 3
            ? tt(lang, 'التالي', 'Next')
            : tt(lang, 'تأكيد الطلب', 'Confirm order')}
          {lang === 'ar' ? <I.ArrowL size={18} /> : <I.ArrowR size={18} />}
        </button>
      </div>
    </div>
  );
}

function Field({ lang, ar, en, value, onChange }) {
  return (
    <div>
      <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 6, color: 'var(--tb-ink-2)' }}>
        {tt(lang, ar, en)}
      </div>
      <input className="tb-input" value={value} onChange={e => onChange(e.target.value)} />
    </div>
  );
}

// ─── ORDER TRACKING ───
function OrderScreen({ lang, orderId, onBack }) {
  const order = D2.ORDERS.find(o => o.id === orderId) || D2.ORDERS[0];
  const stages = [
    { key: 'pending',   ar: 'قيد المراجعة', en: 'Pending review',  icon: I.Clock,    desc_ar: 'جارٍ التحقق من الإيصال', desc_en: 'Verifying receipt' },
    { key: 'confirmed', ar: 'تم التأكيد',   en: 'Confirmed',       icon: I.Check,    desc_ar: 'تم تأكيد طلبك', desc_en: 'Your order is confirmed' },
    { key: 'preparing', ar: 'قيد التجهيز',  en: 'Preparing',       icon: I.Box,      desc_ar: 'نحضّر القطع', desc_en: 'Packing your items' },
    { key: 'shipped',   ar: 'تم الشحن',     en: 'Shipped',         icon: I.Truck,    desc_ar: 'في الطريق إليك', desc_en: 'On the way to you' },
    { key: 'delivered', ar: 'تم التوصيل',    en: 'Delivered',       icon: I.Smile,    desc_ar: 'استمتعوا!', desc_en: 'Enjoy!' },
  ];
  const currentIdx = stages.findIndex(s => s.key === order.status);

  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <window.TB.TbHeader lang={lang} onBack={onBack} title={tt(lang, 'تتبع الطلب', 'Track order')} />
      <div className="tb-scroll" style={{ flex: 1, padding: '0 18px 24px' }}>
        {/* Order header card */}
        <div className="tb-card" style={{ padding: 16, marginBottom: 14 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <div>
              <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                {tt(lang, 'رقم الطلب', 'Order')}
              </div>
              <div style={{ fontSize: 18, fontWeight: 800, fontFamily: 'var(--tb-font-body)' }}>{order.id}</div>
            </div>
            <div className="tb-tag" style={{
              background: D2.STATUSES[order.status].color,
              color: D2.STATUSES[order.status].ink,
              fontSize: 12, padding: '6px 12px',
            }}>
              {tt(lang, D2.STATUSES[order.status].ar, D2.STATUSES[order.status].en)}
            </div>
          </div>
          <div style={{ fontSize: 13, color: 'var(--tb-ink-3)' }}>
            {tt(lang, 'تاريخ الطلب', 'Placed on')} · {order.date}
          </div>
        </div>

        {/* Timeline */}
        <div className="tb-card" style={{ padding: 18, marginBottom: 14 }}>
          <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)', marginBottom: 16 }}>
            {tt(lang, 'مراحل الطلب', 'Order stages')}
          </div>
          {stages.map((s, idx) => {
            const done = idx <= currentIdx;
            const active = idx === currentIdx;
            return (
              <div key={s.key} style={{ display: 'flex', gap: 14, position: 'relative', paddingBottom: idx === stages.length - 1 ? 0 : 18 }}>
                {/* Connector line */}
                {idx < stages.length - 1 && (
                  <div style={{
                    position: 'absolute', [lang === 'ar' ? 'right' : 'left']: 19,
                    top: 38, bottom: 0, width: 2,
                    background: idx < currentIdx ? D2.STATUSES[stages[idx + 1].key].color : 'var(--tb-line)',
                  }} />
                )}
                <div style={{
                  width: 40, height: 40, borderRadius: '50%', flexShrink: 0,
                  background: done ? D2.STATUSES[s.key].color : 'var(--tb-bg)',
                  color: done ? D2.STATUSES[s.key].ink : 'var(--tb-ink-3)',
                  border: done ? 'none' : '1.5px solid var(--tb-line)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  boxShadow: active ? `0 0 0 5px ${D2.STATUSES[s.key].color}33` : 'none',
                }}>
                  <s.icon size={18} strokeWidth={2.4} />
                </div>
                <div style={{ flex: 1, paddingTop: 4 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: done ? 'var(--tb-ink)' : 'var(--tb-ink-3)' }}>
                    {tt(lang, s.ar, s.en)}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', marginTop: 2 }}>
                    {tt(lang, s.desc_ar, s.desc_en)}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Items */}
        <div className="tb-card" style={{ padding: 14, marginBottom: 14 }}>
          <div style={{ fontSize: 13, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', color: 'var(--tb-ink-2)', marginBottom: 10 }}>
            {tt(lang, 'القطع', 'Items')}
          </div>
          {order.items.map((it, i) => {
            const p = D2.PRODUCTS.find(P => P.id === it.p);
            if (!p) return null;
            return (
              <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'center', padding: '8px 0', borderTop: i > 0 ? '1px solid var(--tb-line)' : 'none' }}>
                <div style={{ width: 48, height: 48, borderRadius: 10, overflow: 'hidden', background: p.color, flexShrink: 0 }}>
                  <PI src={p.img} color={p.color} alt={p.name_en} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 700 }}>{tt(lang, p.name_ar, p.name_en)}</div>
                  <div style={{ fontSize: 11, color: 'var(--tb-ink-3)' }}>×{it.qty}</div>
                </div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>{fY(p.price * it.qty, lang)}</div>
              </div>
            );
          })}
          <div style={{ marginTop: 12, paddingTop: 12, borderTop: '1.5px dashed var(--tb-line)', display: 'flex', justifyContent: 'space-between', fontSize: 16, fontWeight: 800 }}>
            <span>{tt(lang, 'الإجمالي', 'Total')}</span>
            <span style={{ color: 'var(--tb-accent)' }}>{fY(order.total, lang)}</span>
          </div>
        </div>

        {/* Customer support */}
        <button className="tb-btn tb-btn-soft" style={{ width: '100%' }}>
          <I.Phone size={18} />
          {tt(lang, 'تواصل مع خدمة العملاء', 'Contact customer support')}
        </button>
      </div>
    </div>
  );
}

// ─── ORDERS LIST ───
function OrdersListScreen({ lang, onOrder, onShop }) {
  return (
    <div className="tb-scroll" style={{ background: 'var(--tb-bg)' }}>
      <div style={{ padding: '12px 18px 8px' }}>
        <div className="tb-display" style={{ fontSize: 24, fontWeight: 800 }}>
          {tt(lang, 'طلباتي', 'My orders')}
        </div>
      </div>
      <div style={{ padding: '8px 18px 24px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {D2.ORDERS.slice(0, 4).map(o => (
          <div key={o.id} onClick={() => onOrder(o.id)} className="tb-card" style={{ padding: 14, cursor: 'pointer' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
              <div>
                <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 600 }}>{o.id}</div>
                <div style={{ fontSize: 13, color: 'var(--tb-ink-2)' }}>{o.date}</div>
              </div>
              <div className="tb-tag" style={{
                background: D2.STATUSES[o.status].color,
                color: D2.STATUSES[o.status].ink,
                fontSize: 11, padding: '5px 10px',
              }}>
                {tt(lang, D2.STATUSES[o.status].ar, D2.STATUSES[o.status].en)}
              </div>
            </div>
            <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
              {o.items.slice(0, 4).map((it, i) => {
                const p = D2.PRODUCTS.find(P => P.id === it.p);
                if (!p) return null;
                return (
                  <div key={i} style={{ width: 44, height: 44, borderRadius: 10, background: p.color, overflow: 'hidden' }}>
                    <PI src={p.img} color={p.color} alt={p.name_en} />
                  </div>
                );
              })}
              <div style={{ flex: 1 }} />
              <div style={{ textAlign: lang === 'ar' ? 'left' : 'right' }}>
                <div style={{ fontSize: 11, color: 'var(--tb-ink-3)' }}>{o.items.length} {tt(lang, 'قطع', 'items')}</div>
                <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--tb-accent)' }}>{fY(o.total, lang)}</div>
              </div>
            </div>
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="tb-btn tb-btn-soft" style={{ padding: '8px 14px', fontSize: 12, flex: 1 }}>
                {tt(lang, 'تتبع الطلب', 'Track order')}
                {lang === 'ar' ? <I.ArrowL size={14} /> : <I.ArrowR size={14} />}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── ACCOUNT ───
function AccountScreen({ lang, user }) {
  const displayName = (user && user.name) || (lang === 'ar' ? 'أم عبدالله' : 'Umm Abdullah');
  const displayPhone = (user && user.phone) || '+967 77 123 4567';
  // Avatar initials — first 2 chars (handles latin, falls back to first 2 of name)
  const initials = (() => {
    const n = displayName.trim();
    const parts = n.split(/\s+/);
    if (parts.length >= 2) return (parts[0][0] || '') + (parts[1][0] || '');
    return n.slice(0, 2);
  })();
  const items = [
    { icon: I.Pkg,      ar: 'طلباتي',         en: 'My orders' },
    { icon: I.Heart,    ar: 'المفضلة',        en: 'Wishlist' },
    { icon: I.MapPin,   ar: 'العناوين',       en: 'Addresses' },
    { icon: I.Wallet,   ar: 'طرق الدفع',      en: 'Payment methods' },
    { icon: I.Tag,      ar: 'أكواد الخصم',    en: 'Promo codes' },
    { icon: I.Bell,     ar: 'الإشعارات',     en: 'Notifications' },
    { icon: I.Globe,    ar: 'اللغة',          en: 'Language' },
    { icon: I.Settings, ar: 'الإعدادات',     en: 'Settings' },
  ];
  return (
    <div className="tb-scroll" style={{ background: 'var(--tb-bg)' }}>
      <div style={{ padding: '14px 18px 0' }}>
        <div className="tb-card" style={{ padding: 18, display: 'flex', alignItems: 'center', gap: 14, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -30, [lang === 'ar' ? 'left' : 'right']: -30, width: 100, height: 100, borderRadius: '50%', background: 'var(--tb-yellow)', opacity: 0.3 }} />
          <div style={{
            width: 64, height: 64, borderRadius: '50%',
            background: 'var(--tb-pink)', color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 26, fontWeight: 800, flexShrink: 0,
          }}>{initials}</div>
          <div style={{ flex: 1, position: 'relative' }}>
            <div style={{ fontWeight: 800, fontSize: 17, marginBottom: 2 }}>{displayName}</div>
            <div style={{ fontSize: 13, color: 'var(--tb-ink-3)', fontFamily: 'var(--tb-font-body)' }}>{displayPhone}</div>
          </div>
          <button style={{ width: 36, height: 36, borderRadius: '50%', border: '1px solid var(--tb-line)', background: 'transparent', cursor: 'pointer', color: 'var(--tb-ink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <I.Edit size={16} />
          </button>
        </div>
      </div>

      <div style={{ padding: '14px 18px 24px' }}>
        <div className="tb-card" style={{ overflow: 'hidden' }}>
          {items.map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 14,
              padding: '14px 16px', cursor: 'pointer',
              borderBottom: i < items.length - 1 ? '1px solid var(--tb-line)' : 'none',
            }}>
              <div style={{
                width: 38, height: 38, borderRadius: 12, background: 'var(--tb-bg)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--tb-ink)',
              }}><it.icon size={18} /></div>
              <span style={{ flex: 1, fontSize: 14, fontWeight: 600 }}>{tt(lang, it.ar, it.en)}</span>
              {lang === 'ar' ? <I.ChevronL size={18} style={{ color: 'var(--tb-ink-3)' }} /> : <I.ChevronR size={18} style={{ color: 'var(--tb-ink-3)' }} />}
            </div>
          ))}
        </div>

        <button className="tb-btn tb-btn-ghost" style={{ width: '100%', marginTop: 16, color: '#E84A5F', borderColor: '#E84A5F' }}>
          <I.Logout size={18} />
          {tt(lang, 'تسجيل الخروج', 'Sign out')}
        </button>
      </div>
    </div>
  );
}

// ─── ORDER PLACED CONFIRMATION ───
function OrderPlacedScreen({ lang, onTrack, onHome }) {
  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 32, textAlign: 'center', position: 'relative', overflow: 'hidden' }}>
        {/* Confetti */}
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          <I.Star size={20} style={{ position: 'absolute', top: '15%', left: '10%', color: 'var(--tb-yellow)', fill: 'var(--tb-yellow)' }} />
          <I.Star size={14} style={{ position: 'absolute', top: '25%', right: '15%', color: 'var(--tb-pink)', fill: 'var(--tb-pink)' }} />
          <I.Sparkle size={18} style={{ position: 'absolute', bottom: '20%', left: '18%', color: 'var(--tb-mint)' }} />
          <I.Star size={16} style={{ position: 'absolute', bottom: '30%', right: '12%', color: 'var(--tb-blue)', fill: 'var(--tb-blue)' }} />
        </div>

        <div className="tb-pop" style={{
          width: 140, height: 140, borderRadius: '50%',
          background: 'var(--tb-mint)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          marginBottom: 20, position: 'relative',
          boxShadow: '0 14px 40px rgba(43, 217, 166, 0.35)',
        }}>
          <I.Check size={68} strokeWidth={3} style={{ color: 'var(--tb-ink)' }} />
        </div>
        <div className="tb-display" style={{ fontSize: 26, fontWeight: 800, marginBottom: 8 }}>
          {tt(lang, 'تم استلام طلبك! 🎉', 'Order placed! 🎉')}
        </div>
        <div style={{ fontSize: 14, color: 'var(--tb-ink-2)', maxWidth: 280, lineHeight: 1.5, marginBottom: 24 }}>
          {tt(lang,
            'سنراجع إيصال الدفع ونؤكد طلبك خلال ساعة. ستصلك إشعارات بكل تحديث.',
            'We\'ll review your receipt and confirm your order within an hour. You\'ll get notified at every step.')}
        </div>
        <div className="tb-card" style={{ padding: 14, marginBottom: 20, minWidth: 220 }}>
          <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 600 }}>{tt(lang, 'رقم الطلب', 'Order ID')}</div>
          <div style={{ fontSize: 18, fontWeight: 800, fontFamily: 'var(--tb-font-body)' }}>TB-2406</div>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '12px 18px', display: 'flex', gap: 10 }}>
        <button onClick={onHome} className="tb-btn tb-btn-soft" style={{ flex: 1 }}>
          {tt(lang, 'العودة للرئيسية', 'Back to home')}
        </button>
        <button onClick={onTrack} className="tb-btn tb-btn-primary" style={{ flex: 1 }}>
          {tt(lang, 'تتبع الطلب', 'Track order')}
        </button>
      </div>
    </div>
  );
}

window.TBCheckout = CheckoutScreen;
window.TBOrder = OrderScreen;
window.TBOrders = OrdersListScreen;
window.TBAccount = AccountScreen;
window.TBOrderPlaced = OrderPlacedScreen;
