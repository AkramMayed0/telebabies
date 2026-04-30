// teleBabies — Login + Admin
const { TB_DATA: AD } = window;
const { fmtYER: f3, t: t3, ProductImg: PI3 } = window.TB;

// ─── LOGIN ───
//
// Production routing logic (one app, role-based):
//   1. User enters phone → backend sends OTP via SMS.
//   2. User enters OTP → backend verifies and queries the `admins` table:
//      • if phone exists in admins → returns role: 'admin'
//      • otherwise → returns role: 'customer' (creates user if new)
//   3. App routes silently based on role. Customers see customer home.
//      Admins skip the name-capture step and go to the admin panel.
//   4. The UI is identical for everyone — admins look up their own number;
//      customers never see anything that hints at admin functionality.
//
// In this prototype, the role is faked client-side: phones starting with "70"
// are treated as admin. The real app uses the backend response, never the digits.
function LoginScreen({ lang, onContinue, onSkip }) {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [name, setName] = useState('');
  const [step, setStep] = useState(1); // 1 phone, 2 otp, 3 name
  const isAdminFlow = phone.replace(/\s/g, '').startsWith('70');

  return (
    <div style={{ background: 'var(--tb-pink)', height: '100%', display: 'flex', flexDirection: 'column', position: 'relative', overflow: 'hidden' }}>
      {/* Decorative shapes */}
      <div style={{ position: 'absolute', top: -50, [lang === 'ar' ? 'left' : 'right']: -50, width: 200, height: 200, borderRadius: '50%', background: 'var(--tb-yellow)', opacity: 0.6 }} />
      <div style={{ position: 'absolute', top: 160, [lang === 'ar' ? 'right' : 'left']: -40, width: 100, height: 100, borderRadius: '50%', background: 'var(--tb-mint)', opacity: 0.5 }} />
      <I.Star size={28} style={{ position: 'absolute', top: 80, [lang === 'ar' ? 'right' : 'left']: 50, color: 'var(--tb-ink)', fill: 'var(--tb-yellow)' }} />
      <I.Sparkle size={22} style={{ position: 'absolute', top: 200, [lang === 'ar' ? 'left' : 'right']: 40, color: 'var(--tb-cream)' }} />

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', padding: '60px 24px 0', position: 'relative' }}>
        <div style={{ marginBottom: 14 }}>
          <window.TB.TbWordmark lang={lang} size={28} color="#fff" />
        </div>
        <div className="tb-display" style={{ fontSize: 36, fontWeight: 800, color: '#fff', lineHeight: 1.1, marginBottom: 10 }}>
          {t3(lang, 'ملابس صغيرة، أحلام كبيرة', 'Tiny clothes, big dreams')}
        </div>
        <div style={{ fontSize: 15, color: 'rgba(255,255,255,0.9)', lineHeight: 1.5, marginBottom: 28, maxWidth: 320 }}>
          {t3(lang,
            'تسوق أحدث ملابس الأطفال بأفضل الأسعار، توصيل لكل اليمن.',
            'Shop the freshest baby and kids fashion. Delivery across Yemen.')}
        </div>
      </div>

      <div style={{
        background: 'var(--tb-bg)',
        borderTopLeftRadius: 36, borderTopRightRadius: 36,
        padding: '28px 22px 22px',
        flexShrink: 0,
      }}>
        {step === 1 ? (
          <>
            <div className="tb-display" style={{ fontSize: 20, fontWeight: 800, marginBottom: 6 }}>
              {t3(lang, 'مرحباً بك 👋', 'Welcome 👋')}
            </div>
            <div style={{ fontSize: 13, color: 'var(--tb-ink-2)', marginBottom: 18 }}>
              {t3(lang, 'سجّل برقم الهاتف لمتابعة طلباتك', 'Sign in with your phone to track your orders')}
            </div>
            <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--tb-ink-2)', marginBottom: 6 }}>
              {t3(lang, 'رقم الهاتف', 'Phone number')}
            </div>
            <div style={{ display: 'flex', gap: 8, marginBottom: 14 }}>
              <input value={phone} onChange={e => setPhone(e.target.value)}
                placeholder="77 123 4567"
                inputMode="numeric"
                className="tb-input" style={{ flex: 1, fontFamily: 'var(--tb-font-body)', direction: 'ltr', textAlign: lang === 'ar' ? 'right' : 'left' }} />
              <div style={{
                padding: '14px 14px', background: 'var(--tb-card)',
                border: '1.5px solid var(--tb-line)', borderRadius: 14,
                fontSize: 15, fontWeight: 700, fontFamily: 'var(--tb-font-body)',
                display: 'flex', alignItems: 'center', gap: 6,
                direction: 'ltr', flexShrink: 0,
              }}>🇾🇪 +967</div>
            </div>
            <button onClick={() => setStep(2)} className="tb-btn tb-btn-primary" style={{ width: '100%', marginBottom: 10 }}>
              {t3(lang, 'متابعة', 'Continue')}
              {lang === 'ar' ? <I.ArrowL size={18} /> : <I.ArrowR size={18} />}
            </button>
            <button onClick={onSkip} className="tb-btn tb-btn-soft" style={{ width: '100%', background: 'transparent', color: 'var(--tb-ink-2)' }}>
              {t3(lang, 'تصفح بدون تسجيل', 'Browse without account')}
            </button>
            {/* No special admin entry — the SAME phone form serves everyone.
                Admin phone numbers live in the `admins` table in the DB.
                When the backend verifies the OTP, it checks if the phone is
                whitelisted and returns role: 'admin' or role: 'customer'.
                The app routes accordingly. Customers never see anything different. */}
          </>
        ) : step === 2 ? (
          <>
            <div className="tb-display" style={{ fontSize: 20, fontWeight: 800, marginBottom: 6 }}>
              {t3(lang, 'أدخل الرمز', 'Enter the code')}
            </div>
            <div style={{ fontSize: 13, color: 'var(--tb-ink-2)', marginBottom: 18 }}>
              {t3(lang, 'أرسلنا رمز تحقق إلى', 'We sent a code to')} +967 {phone || '77 123 4567'}
            </div>
            <div style={{ display: 'flex', gap: 8, marginBottom: 18, justifyContent: 'center' }}>
              {[0,1,2,3].map(i => (
                <input key={i} maxLength={1}
                  value={otp[i] || ''}
                  onChange={(e) => { const a = otp.split(''); a[i] = e.target.value; setOtp(a.join('')); }}
                  style={{
                    width: 56, height: 64, borderRadius: 16,
                    border: '1.5px solid var(--tb-line)', background: 'var(--tb-card)',
                    fontSize: 24, fontWeight: 800, textAlign: 'center',
                    fontFamily: 'var(--tb-font-body)', color: 'var(--tb-ink)',
                  }} />
              ))}
            </div>
            <button
              onClick={() => {
                if (isAdminFlow) {
                  // Backend returned role: 'admin' — skip name capture
                  onContinue && onContinue({ intent: 'admin', phone: '+967 ' + phone });
                } else {
                  setStep(3);
                }
              }}
              className="tb-btn tb-btn-primary" style={{ width: '100%', marginBottom: 10 }}>
              {t3(lang, 'تسجيل الدخول', 'Sign in')}
            </button>
            <div style={{ textAlign: 'center', fontSize: 12, color: 'var(--tb-ink-3)' }}>
              {t3(lang, 'لم يصلك الرمز؟', 'Didn\'t get a code?')}
              <span style={{ color: 'var(--tb-accent)', fontWeight: 700, marginInlineStart: 6 }}>{t3(lang, 'إعادة الإرسال', 'Resend')}</span>
            </div>
          </>
        ) : (
          <>
            <div className="tb-display" style={{ fontSize: 20, fontWeight: 800, marginBottom: 6 }}>
              {t3(lang, 'ما اسمك؟', 'What\'s your name?')}
            </div>
            <div style={{ fontSize: 13, color: 'var(--tb-ink-2)', marginBottom: 18 }}>
              {t3(lang, 'لنخصّص تجربتك ونرسل التحديثات باسمك', 'So we can personalize your experience')}
            </div>
            <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--tb-ink-2)', marginBottom: 6 }}>
              {t3(lang, 'الاسم الكامل', 'Full name')}
            </div>
            <input value={name} onChange={e => setName(e.target.value)}
              placeholder={t3(lang, 'مثال: أم عبدالله', 'e.g. Sarah Ahmed')}
              autoFocus
              className="tb-input" style={{ width: '100%', boxSizing: 'border-box', marginBottom: 14, fontFamily: 'var(--tb-font-body)' }} />
            <button
              onClick={() => onContinue && onContinue({ intent: 'customer', name: name.trim(), phone: '+967 ' + phone })}
              disabled={!name.trim()}
              className="tb-btn tb-btn-primary"
              style={{
                width: '100%', marginBottom: 10,
                opacity: name.trim() ? 1 : 0.55,
                cursor: name.trim() ? 'pointer' : 'not-allowed',
              }}>
              {t3(lang, 'ابدأ التسوق', 'Start shopping')}
              {lang === 'ar' ? <I.ArrowL size={18} /> : <I.ArrowR size={18} />}
            </button>
            <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', textAlign: 'center', lineHeight: 1.4 }}>
              {t3(lang, 'يمكنك تعديل هذه المعلومات لاحقاً من حسابك', 'You can edit this anytime in your account')}
            </div>
          </>
        )}
      </div>
    </div>
  );
}

// Helper exposed so consumers can render the OTP step content.
// (No-op — the LoginScreen above handles all three steps internally.)

// ─── ADMIN ─── 

function AdminApp({ lang, onExit }) {
  const [tab, setTab] = useState('orders');
  const [order, setOrder] = useState(null);

  return (
    <div style={{ background: 'var(--tb-bg)', height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Admin top bar */}
      <div style={{
        flexShrink: 0, padding: '14px 18px',
        background: 'var(--tb-ink)', color: 'var(--tb-cream)',
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{
          width: 36, height: 36, borderRadius: 12, background: 'var(--tb-yellow)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--tb-ink)',
        }}><I.Stars size={20} /></div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, fontWeight: 600, opacity: 0.7, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
            {t3(lang, 'لوحة الإدارة', 'Admin panel')}
          </div>
          <div style={{ fontSize: 15, fontWeight: 800 }}>teleBabies</div>
        </div>
        <button onClick={onExit} style={{
          padding: '6px 12px', borderRadius: 999,
          background: 'rgba(255,255,255,0.1)', color: 'var(--tb-cream)',
          border: 'none', cursor: 'pointer', fontFamily: 'inherit', fontSize: 12, fontWeight: 700,
        }}>{t3(lang, 'خروج', 'Exit')}</button>
      </div>

      {order ? (
        <AdminOrderDetail order={order} lang={lang} onBack={() => setOrder(null)} />
      ) : (
        <>
          <div className="tb-scroll" style={{ flex: 1 }}>
            {tab === 'overview' && <AdminOverview lang={lang} />}
            {tab === 'orders' && <AdminOrders lang={lang} onOrder={setOrder} />}
            {tab === 'products' && <AdminProducts lang={lang} />}
            {tab === 'promos' && <AdminPromos lang={lang} />}
          </div>
          <div style={{
            flexShrink: 0, background: 'var(--tb-card)',
            borderTop: '1px solid var(--tb-line)',
            padding: '8px 8px 6px', display: 'flex',
          }}>
            {[
              { id: 'overview', icon: I.Stars,   ar: 'نظرة', en: 'Overview' },
              { id: 'orders',   icon: I.Receipt, ar: 'الطلبات', en: 'Orders', badge: 2 },
              { id: 'products', icon: I.Shirt,   ar: 'المنتجات', en: 'Products' },
              { id: 'promos',   icon: I.Tag,     ar: 'الأكواد', en: 'Promos' },
            ].map(T => {
              const active = tab === T.id;
              return (
                <button key={T.id} onClick={() => setTab(T.id)} style={{
                  flex: 1, padding: '6px 4px', border: 'none', background: 'transparent',
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
                  cursor: 'pointer', position: 'relative',
                  color: active ? 'var(--tb-ink)' : 'var(--tb-ink-3)', fontFamily: 'inherit',
                }}>
                  <div style={{
                    width: 56, height: 30, borderRadius: 999,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    background: active ? 'var(--tb-yellow)' : 'transparent',
                    position: 'relative',
                  }}>
                    <T.icon size={20} strokeWidth={active ? 2.4 : 1.8} />
                    {T.badge > 0 && (
                      <span style={{
                        position: 'absolute', top: -2, [lang === 'ar' ? 'left' : 'right']: 8,
                        minWidth: 16, height: 16, borderRadius: 8, padding: '0 4px',
                        background: 'var(--tb-pink)', color: '#fff', fontSize: 9, fontWeight: 800,
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        border: '2px solid var(--tb-card)',
                      }}>{T.badge}</span>
                    )}
                  </div>
                  <span style={{ fontSize: 11, fontWeight: active ? 700 : 500 }}>
                    {t3(lang, T.ar, T.en)}
                  </span>
                </button>
              );
            })}
          </div>
        </>
      )}
    </div>
  );
}

function AdminOverview({ lang }) {
  const stats = [
    { ar: 'طلبات اليوم', en: 'Today\'s orders', v: '12', sub: '+18%', color: 'var(--tb-pink)', icon: I.Receipt },
    { ar: 'المبيعات اليومية', en: 'Daily revenue', v: f3(124500, lang), sub: '+12%', color: 'var(--tb-mint)', icon: I.Wallet },
    { ar: 'بانتظار المراجعة', en: 'Pending review', v: '2', sub: '!', color: 'var(--tb-yellow)', icon: I.Clock, dark: true },
    { ar: 'منتجات نافدة', en: 'Low stock', v: '3', sub: '⚠', color: 'var(--tb-coral)', icon: I.Box },
  ];
  return (
    <div style={{ padding: '14px 18px 24px' }}>
      <div className="tb-display" style={{ fontSize: 22, fontWeight: 800, marginBottom: 4 }}>
        {t3(lang, 'صباح الخير، خالد 👋', 'Good morning, Khaled 👋')}
      </div>
      <div style={{ fontSize: 13, color: 'var(--tb-ink-3)', marginBottom: 16 }}>
        {t3(lang, 'إليك ملخص اليوم', 'Here\'s today\'s summary')}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 16 }}>
        {stats.map((s, i) => (
          <div key={i} style={{
            padding: 14, borderRadius: 18,
            background: s.color, color: s.dark ? 'var(--tb-ink)' : (s.color === 'var(--tb-yellow)' ? 'var(--tb-ink)' : '#fff'),
            position: 'relative', overflow: 'hidden',
          }}>
            <s.icon size={20} style={{ marginBottom: 6, opacity: 0.85 }} />
            <div style={{ fontSize: 11, fontWeight: 600, opacity: 0.85, marginBottom: 2 }}>{t3(lang, s.ar, s.en)}</div>
            <div className="tb-display" style={{ fontSize: 22, fontWeight: 800 }}>{s.v}</div>
            <div style={{ fontSize: 11, fontWeight: 700, marginTop: 4, opacity: 0.85 }}>{s.sub}</div>
          </div>
        ))}
      </div>

      <div className="tb-card" style={{ padding: 16, marginBottom: 14 }}>
        <div className="tb-display" style={{ fontSize: 16, fontWeight: 800, marginBottom: 12 }}>
          {t3(lang, 'مبيعات الأسبوع', 'This week\'s sales')}
        </div>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, height: 120 }}>
          {[40, 65, 50, 80, 95, 70, 110].map((h, i) => {
            const days_ar = ['س', 'أ', 'ث', 'ر', 'خ', 'ج', 'ح'];
            const days_en = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            return (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <div style={{
                  width: '100%', height: `${h}px`, borderRadius: 8,
                  background: i === 6 ? 'var(--tb-pink)' : 'var(--tb-yellow)',
                  position: 'relative',
                }}>
                  {i === 6 && <div style={{
                    position: 'absolute', top: -20, left: '50%', transform: 'translateX(-50%)',
                    fontSize: 10, fontWeight: 800, color: 'var(--tb-pink)',
                  }}>{f3(45000, lang).split(' ')[0]}</div>}
                </div>
                <span style={{ fontSize: 10, color: 'var(--tb-ink-3)', fontWeight: 700 }}>
                  {t3(lang, days_ar[i], days_en[i])}
                </span>
              </div>
            );
          })}
        </div>
      </div>

      <div className="tb-display" style={{ fontSize: 16, fontWeight: 800, marginBottom: 10 }}>
        {t3(lang, 'الطلبات الأخيرة', 'Recent orders')}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {AD.ORDERS.slice(0, 3).map(o => (
          <div key={o.id} className="tb-card" style={{ padding: 12, display: 'flex', gap: 10, alignItems: 'center' }}>
            <div style={{
              width: 38, height: 38, borderRadius: 10, background: 'var(--tb-bg)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 11, fontWeight: 800, color: 'var(--tb-ink-2)',
            }}>{o.id.slice(-2)}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 700, whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
                {t3(lang, o.customer.name_ar, o.customer.name_en)}
              </div>
              <div style={{ fontSize: 11, color: 'var(--tb-ink-3)' }}>
                {f3(o.total, lang)} · {t3(lang, o.customer.city_ar, o.customer.city_en)}
              </div>
            </div>
            <div className="tb-tag" style={{ background: AD.STATUSES[o.status].color, color: AD.STATUSES[o.status].ink, fontSize: 10 }}>
              {t3(lang, AD.STATUSES[o.status].ar, AD.STATUSES[o.status].en)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function AdminOrders({ lang, onOrder }) {
  const [filter, setFilter] = useState('all');
  const orders = filter === 'all' ? AD.ORDERS : AD.ORDERS.filter(o => o.status === filter);

  return (
    <div style={{ padding: '14px 18px 24px' }}>
      <div className="tb-display" style={{ fontSize: 22, fontWeight: 800, marginBottom: 12 }}>
        {t3(lang, 'الطلبات', 'Orders')}
      </div>

      <div className="tb-no-scrollbar" style={{ display: 'flex', gap: 8, marginBottom: 12, overflowX: 'auto' }}>
        {[
          { id: 'all', ar: 'الكل', en: 'All', n: AD.ORDERS.length },
          { id: 'pending', ar: 'قيد المراجعة', en: 'Pending', n: 2 },
          { id: 'confirmed', ar: 'مؤكدة', en: 'Confirmed', n: 1 },
          { id: 'preparing', ar: 'قيد التجهيز', en: 'Preparing', n: 1 },
          { id: 'shipped', ar: 'مشحونة', en: 'Shipped', n: 1 },
        ].map(f => (
          <button key={f.id} onClick={() => setFilter(f.id)} className="tb-chip" data-active={filter === f.id}>
            {t3(lang, f.ar, f.en)} <span style={{ opacity: 0.7 }}>·{f.n}</span>
          </button>
        ))}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {orders.map(o => (
          <div key={o.id} onClick={() => onOrder(o)} className="tb-card" style={{ padding: 14, cursor: 'pointer' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
              <div>
                <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 600 }}>{o.id}</div>
                <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 2 }}>{t3(lang, o.customer.name_ar, o.customer.name_en)}</div>
                <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', display: 'flex', alignItems: 'center', gap: 4 }}>
                  <I.MapPin size={12} /> {t3(lang, o.customer.city_ar, o.customer.city_en)} · {o.date}
                </div>
              </div>
              <div className="tb-tag" style={{ background: AD.STATUSES[o.status].color, color: AD.STATUSES[o.status].ink, fontSize: 11 }}>
                {t3(lang, AD.STATUSES[o.status].ar, AD.STATUSES[o.status].en)}
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: 10, borderTop: '1px solid var(--tb-line)' }}>
              <div style={{ fontSize: 12, color: 'var(--tb-ink-2)', display: 'flex', alignItems: 'center', gap: 4 }}>
                <I.Receipt size={14} /> {o.items.length} {t3(lang, 'قطع', 'items')}
                {o.receipt && <span style={{ marginInlineStart: 8, color: 'var(--tb-mint)', fontWeight: 700, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                  <I.Image size={12} /> {t3(lang, 'إيصال', 'Receipt')}
                </span>}
              </div>
              <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--tb-accent)' }}>{f3(o.total, lang)}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function AdminOrderDetail({ order, lang, onBack }) {
  const [showReceipt, setShowReceipt] = useState(false);
  const status = AD.STATUSES[order.status];

  return (
    <>
      <div className="tb-scroll" style={{ flex: 1 }}>
        <window.TB.TbHeader lang={lang} onBack={onBack} title={t3(lang, `طلب ${order.id}`, `Order ${order.id}`)} />

        <div style={{ padding: '0 18px 24px' }}>
          {/* Status hero */}
          <div className="tb-card" style={{
            padding: 16, marginBottom: 12, background: status.color, color: status.ink, border: 'none',
          }}>
            <div style={{ fontSize: 11, fontWeight: 700, opacity: 0.85, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              {t3(lang, 'الحالة الحالية', 'Current status')}
            </div>
            <div className="tb-display" style={{ fontSize: 22, fontWeight: 800, marginTop: 2 }}>
              {t3(lang, status.ar, status.en)}
            </div>
          </div>

          {/* Customer */}
          <div className="tb-card" style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 8 }}>
              {t3(lang, 'العميل', 'Customer')}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
              <div style={{ width: 38, height: 38, borderRadius: '50%', background: 'var(--tb-pink)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, fontWeight: 800 }}>
                {(t3(lang, order.customer.name_ar, order.customer.name_en) || '').slice(0, 2)}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 700 }}>{t3(lang, order.customer.name_ar, order.customer.name_en)}</div>
                <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', fontFamily: 'var(--tb-font-body)' }}>{order.customer.phone}</div>
              </div>
              <button style={{ width: 36, height: 36, borderRadius: '50%', background: 'var(--tb-mint)', border: 'none', cursor: 'pointer', color: 'var(--tb-ink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <I.Phone size={16} />
              </button>
            </div>
            <div style={{ fontSize: 12, color: 'var(--tb-ink-2)', display: 'flex', alignItems: 'center', gap: 6 }}>
              <I.MapPin size={14} /> {t3(lang, order.customer.city_ar, order.customer.city_en)}
            </div>
          </div>

          {/* Receipt review */}
          {order.receipt && (
            <div className="tb-card" style={{ padding: 14, marginBottom: 12 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
                <div>
                  <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                    {t3(lang, 'إيصال الدفع', 'Payment receipt')}
                  </div>
                  <div style={{ fontSize: 13, fontWeight: 700, marginTop: 2 }}>
                    {t3(lang, AD.PAYMENTS.find(p => p.id === order.payment).ar, AD.PAYMENTS.find(p => p.id === order.payment).en)}
                  </div>
                </div>
                <button onClick={() => setShowReceipt(true)} style={{
                  padding: '8px 14px', borderRadius: 999, background: 'var(--tb-bg)',
                  border: 'none', cursor: 'pointer', fontSize: 12, fontWeight: 700, color: 'var(--tb-ink)',
                  display: 'inline-flex', gap: 6, alignItems: 'center', fontFamily: 'inherit',
                }}>
                  <I.Eye size={14} /> {t3(lang, 'عرض', 'View')}
                </button>
              </div>
              {/* Mock receipt thumbnail */}
              <div onClick={() => setShowReceipt(true)} style={{
                height: 100, borderRadius: 12, background: 'linear-gradient(135deg, #FFF7E8, #FFE2A8)',
                border: '1.5px dashed var(--tb-line)', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 11, color: 'var(--tb-ink-2)', fontWeight: 700, gap: 8,
              }}>
                <I.Image size={32} style={{ color: 'var(--tb-ink-3)' }} />
                receipt_{order.id.slice(-4)}.jpg
              </div>
              {order.status === 'pending' && (
                <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                  <button className="tb-btn tb-btn-ghost" style={{ flex: 1, padding: '12px', borderColor: '#E84A5F', color: '#E84A5F' }}>
                    <I.Close size={18} /> {t3(lang, 'رفض', 'Reject')}
                  </button>
                  <button className="tb-btn" style={{ flex: 1, padding: '12px', background: 'var(--tb-mint)', color: 'var(--tb-ink)' }}>
                    <I.Check size={18} /> {t3(lang, 'تأكيد', 'Confirm')}
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Items */}
          <div className="tb-card" style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 10 }}>
              {t3(lang, 'القطع', 'Items')}
            </div>
            {order.items.map((it, i) => {
              const p = AD.PRODUCTS.find(P => P.id === it.p);
              if (!p) return null;
              return (
                <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'center', padding: '8px 0', borderTop: i > 0 ? '1px solid var(--tb-line)' : 'none' }}>
                  <div style={{ width: 44, height: 44, borderRadius: 10, overflow: 'hidden', background: p.color, flexShrink: 0 }}>
                    <PI3 src={p.img} color={p.color} alt={p.name_en} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 700 }}>{t3(lang, p.name_ar, p.name_en)}</div>
                    <div style={{ fontSize: 11, color: 'var(--tb-ink-3)' }}>×{it.qty} · {f3(p.price, lang)}</div>
                  </div>
                  <div style={{ fontSize: 13, fontWeight: 800 }}>{f3(p.price * it.qty, lang)}</div>
                </div>
              );
            })}
            <div style={{ marginTop: 10, paddingTop: 10, borderTop: '1.5px dashed var(--tb-line)', display: 'flex', justifyContent: 'space-between', fontSize: 16, fontWeight: 800 }}>
              <span>{t3(lang, 'الإجمالي', 'Total')}</span>
              <span style={{ color: 'var(--tb-accent)' }}>{f3(order.total, lang)}</span>
            </div>
          </div>

          {/* Update status */}
          <div className="tb-card" style={{ padding: 14 }}>
            <div style={{ fontSize: 11, color: 'var(--tb-ink-3)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 10 }}>
              {t3(lang, 'تحديث الحالة', 'Update status')}
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {Object.entries(AD.STATUSES).filter(([k]) => k !== 'rejected').map(([k, s]) => (
                <button key={k} className="tb-chip" data-active={order.status === k} style={{ fontSize: 12 }}>
                  <span className="tb-dot" style={{ background: s.color }} />
                  {t3(lang, s.ar, s.en)}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Receipt modal */}
      {showReceipt && (
        <div onClick={() => setShowReceipt(false)} style={{
          position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.7)', zIndex: 10,
          display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 16,
        }}>
          <div className="tb-pop" onClick={(e) => e.stopPropagation()} style={{
            background: 'var(--tb-card)', borderRadius: 22, padding: 16, maxWidth: 320, width: '100%',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <div style={{ fontSize: 14, fontWeight: 800 }}>{t3(lang, 'إيصال الدفع', 'Payment receipt')}</div>
              <button onClick={() => setShowReceipt(false)} style={{ width: 30, height: 30, borderRadius: '50%', border: 'none', background: 'var(--tb-bg)', cursor: 'pointer', color: 'var(--tb-ink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <I.Close size={16} />
              </button>
            </div>
            <div style={{
              aspectRatio: '3/4', borderRadius: 14, padding: 16,
              background: 'linear-gradient(135deg, #FFF7E8, #FFE2A8)',
              fontFamily: 'var(--tb-font-body)', color: 'var(--tb-ink)',
              display: 'flex', flexDirection: 'column', gap: 8, justifyContent: 'space-between',
            }}>
              <div>
                <div style={{ fontSize: 11, fontWeight: 700, opacity: 0.6 }}>JAIB WALLET</div>
                <div style={{ fontSize: 16, fontWeight: 800 }}>Transfer Receipt</div>
              </div>
              <div style={{ borderTop: '1.5px dashed var(--tb-ink-2)', paddingTop: 10, fontSize: 11, lineHeight: 1.8 }}>
                <div>Ref: TRX-{order.id.slice(-6)}882</div>
                <div>From: 77 234 5678</div>
                <div>To: 77 123 4567</div>
                <div>Date: {order.date} 10:42 AM</div>
              </div>
              <div style={{ background: '#fff', padding: 12, borderRadius: 10, textAlign: 'center' }}>
                <div style={{ fontSize: 10, fontWeight: 700, opacity: 0.6 }}>AMOUNT</div>
                <div style={{ fontSize: 22, fontWeight: 800 }}>{f3(order.total, lang)}</div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

function AdminProducts({ lang }) {
  return (
    <div style={{ padding: '14px 18px 24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
        <div className="tb-display" style={{ fontSize: 22, fontWeight: 800 }}>
          {t3(lang, 'المنتجات', 'Products')}
        </div>
        <button className="tb-btn tb-btn-primary" style={{ padding: '10px 14px', fontSize: 13 }}>
          <I.Plus size={16} /> {t3(lang, 'إضافة', 'Add')}
        </button>
      </div>
      <div style={{ position: 'relative', marginBottom: 12 }}>
        <I.Search size={18} style={{ position: 'absolute', top: '50%', transform: 'translateY(-50%)', [lang === 'ar' ? 'right' : 'left']: 16, color: 'var(--tb-ink-3)' }} />
        <input className="tb-input" placeholder={t3(lang, 'بحث المنتجات...', 'Search products...')}
          style={{ [lang === 'ar' ? 'paddingRight' : 'paddingLeft']: 44 }} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {AD.PRODUCTS.map(p => (
          <div key={p.id} className="tb-card" style={{ padding: 12, display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ width: 60, height: 60, borderRadius: 12, overflow: 'hidden', background: p.color, flexShrink: 0 }}>
              <PI3 src={p.img} color={p.color} alt={p.name_en} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 2, whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
                {t3(lang, p.name_ar, p.name_en)}
              </div>
              <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', marginBottom: 4 }}>
                {p.sizes.length} {t3(lang, 'مقاسات', 'sizes')} · {t3(lang, p.age + ' سنة', p.age + ' yrs')}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontSize: 14, fontWeight: 800, color: 'var(--tb-accent)' }}>{f3(p.price, lang)}</span>
                <span className="tb-tag" style={{
                  background: p.stock < 8 ? 'var(--tb-coral)' : 'var(--tb-mint-soft)',
                  color: p.stock < 8 ? '#fff' : 'var(--tb-ink)', fontSize: 10,
                }}>
                  {t3(lang, `${p.stock} متوفر`, `${p.stock} stock`)}
                </span>
              </div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <button style={{ width: 32, height: 32, borderRadius: 10, border: '1px solid var(--tb-line)', background: 'var(--tb-card)', cursor: 'pointer', color: 'var(--tb-ink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <I.Edit size={14} />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function AdminPromos({ lang }) {
  return (
    <div style={{ padding: '14px 18px 24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
        <div className="tb-display" style={{ fontSize: 22, fontWeight: 800 }}>
          {t3(lang, 'أكواد الخصم', 'Promo codes')}
        </div>
        <button className="tb-btn tb-btn-primary" style={{ padding: '10px 14px', fontSize: 13 }}>
          <I.Plus size={16} /> {t3(lang, 'إنشاء', 'Create')}
        </button>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {AD.PROMO_CODES.map(c => (
          <div key={c.code} className="tb-card" style={{ padding: 14, position: 'relative', overflow: 'hidden', opacity: c.active ? 1 : 0.55 }}>
            <div style={{ position: 'absolute', top: -20, [lang === 'ar' ? 'left' : 'right']: -20, width: 80, height: 80, borderRadius: '50%', background: c.active ? 'var(--tb-yellow)' : 'var(--tb-line)', opacity: 0.3 }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8, position: 'relative' }}>
              <div>
                <div style={{ fontFamily: 'var(--tb-font-body)', fontSize: 18, fontWeight: 800, letterSpacing: '0.05em', color: c.active ? 'var(--tb-accent)' : 'var(--tb-ink-3)' }}>
                  {c.code}
                </div>
                <div style={{ fontSize: 13, fontWeight: 700, marginTop: 2 }}>
                  {c.type === 'percent' ? `${c.value}%` : f3(c.value, lang)} {t3(lang, 'خصم', 'off')}
                </div>
                <div style={{ fontSize: 12, color: 'var(--tb-ink-3)', marginTop: 2 }}>{t3(lang, c.ar, c.en)}</div>
              </div>
              <div style={{
                width: 40, height: 24, borderRadius: 999, background: c.active ? 'var(--tb-mint)' : 'var(--tb-line)',
                position: 'relative', cursor: 'pointer',
              }}>
                <div style={{ position: 'absolute', top: 2, [c.active ? (lang === 'ar' ? 'left' : 'right') : (lang === 'ar' ? 'right' : 'left')]: 2, width: 20, height: 20, borderRadius: '50%', background: '#fff' }} />
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: 'var(--tb-ink-3)', paddingTop: 10, borderTop: '1px dashed var(--tb-line)' }}>
              <span>{t3(lang, `استُخدم: ${c.uses}/${c.max}`, `Used: ${c.uses}/${c.max}`)}</span>
              <span>{t3(lang, 'ينتهي', 'Expires')} {c.expires}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

window.TBLogin = LoginScreen;
window.TBAdminApp = AdminApp;
