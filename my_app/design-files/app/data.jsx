// teleBabies — sample data
// Real product photos via Unsplash source; bilingual labels

// Curated Unsplash photo IDs for kids' clothing
// Using direct Unsplash CDN URLs with photo IDs
const img = (id) => `https://images.unsplash.com/photo-${id}?w=600&auto=format&fit=crop&q=80`;

const PRODUCTS = [
  { id: 'p1', name_ar: 'فستان زهري بالكشكش', name_en: 'Pink Ruffle Dress',
    cat: 'girls', age: '2-4', type: 'dress',
    price: 8500, oldPrice: 12000, currency: 'YER',
    img: img('1518831959646-742c3a14ebf7'),
    color: '#FF8FB1', tag_ar: 'جديد', tag_en: 'NEW',
    desc_ar: 'فستان قطني ناعم بكشكش زهري لطيف، مثالي للمناسبات والإطلالات اليومية.',
    desc_en: 'Soft cotton dress with playful pink ruffles. Perfect for parties and everyday wear.',
    sizes: ['18M', '2T', '3T', '4T'], stock: 14 },
  { id: 'p2', name_ar: 'بدلة دنيم زرقاء',  name_en: 'Blue Denim Overall',
    cat: 'boys', age: '0-2', type: 'overall',
    price: 11000, currency: 'YER',
    img: img('1622290291468-a28f7a7dc6a8'),
    color: '#A6C8FF', tag_ar: 'مميز', tag_en: 'POPULAR',
    desc_ar: 'بدلة دنيم متينة وأنيقة بأحزمة قابلة للتعديل.',
    desc_en: 'Sturdy, stylish denim overalls with adjustable straps.',
    sizes: ['6M', '12M', '18M', '24M'], stock: 8 },
  { id: 'p3', name_ar: 'تيشيرت قوس قزح',    name_en: 'Rainbow Tee',
    cat: 'unisex', age: '4-6', type: 'tshirt',
    price: 4500, currency: 'YER',
    img: img('1503944583220-79d8926ad5e2'),
    color: '#FFD23F',
    desc_ar: 'تيشيرت قطني خفيف مع طبعة قوس قزح بألوان مرحة.',
    desc_en: 'Light cotton tee with a happy rainbow print.',
    sizes: ['4T', '5T', '6T'], stock: 24 },
  { id: 'p4', name_ar: 'بيجامة نجوم خضراء', name_en: 'Mint Star Pajama',
    cat: 'unisex', age: '2-4', type: 'pajama',
    price: 7000, currency: 'YER',
    img: img('1622290291165-d341f1938345'),
    color: '#BFF5E3',
    desc_ar: 'بيجامة دافئة بطبعة نجوم على قماش قطني ناعم.',
    desc_en: 'Cozy pajamas with a starry print on soft cotton.',
    sizes: ['2T', '3T', '4T'], stock: 17 },
  { id: 'p5', name_ar: 'حذاء صفير صغير',    name_en: 'Little Sneakers',
    cat: 'boys', age: '0-2', type: 'shoes',
    price: 9500, currency: 'YER',
    img: img('1607522370275-f14206abe5d3'),
    color: '#FFE2A8',
    desc_ar: 'أحذية رياضية مرنة وخفيفة لخطواته الأولى.',
    desc_en: 'Flexible, lightweight sneakers for first steps.',
    sizes: ['18', '19', '20', '21'], stock: 6 },
  { id: 'p6', name_ar: 'فستان توتو أصفر',  name_en: 'Yellow Tutu Dress',
    cat: 'girls', age: '4-6', type: 'dress',
    price: 13500, currency: 'YER',
    img: img('1519278409-1f56fdda7fe5'),
    color: '#FFE066', tag_ar: 'الأكثر مبيعاً', tag_en: 'BESTSELLER',
    desc_ar: 'فستان توتو منفوش بطبقات لإطلالة الأميرة الصغيرة.',
    desc_en: 'Layered tutu dress for your little princess.',
    sizes: ['4T', '5T', '6T'], stock: 5 },
  { id: 'p7', name_ar: 'قبعة دب لطيفة',     name_en: 'Bear Beanie',
    cat: 'unisex', age: '0-2', type: 'hat',
    price: 3000, currency: 'YER',
    img: img('1519689680058-324335c77eba'),
    color: '#D4B896',
    desc_ar: 'قبعة محبوكة على شكل دب صغير بأذنين.',
    desc_en: 'Knit beanie shaped like a tiny bear with ears.',
    sizes: ['S', 'M', 'L'], stock: 22 },
  { id: 'p8', name_ar: 'جاكيت وردي شتوي',  name_en: 'Pink Winter Jacket',
    cat: 'girls', age: '4-6', type: 'jacket',
    price: 18000, currency: 'YER',
    img: img('1503919005314-30d93d07d823'),
    color: '#FF4D8D',
    desc_ar: 'جاكيت دافئ ومبطن لأيام الشتاء الباردة.',
    desc_en: 'Warm, padded jacket for chilly winter days.',
    sizes: ['4T', '5T', '6T'], stock: 11 },
];

const CATEGORIES = [
  { id: 'all',     ar: 'الكل',       en: 'All',      icon: 'CatAll',     color: '#FFD23F' },
  { id: 'girls',   ar: 'بنات',      en: 'Girls',    icon: 'CatGirls',   color: '#FF4D8D' },
  { id: 'boys',    ar: 'أولاد',     en: 'Boys',     icon: 'CatBoys',    color: '#3B6BFF' },
  { id: 'newborn', ar: 'مواليد',    en: 'Newborn',  icon: 'CatNewborn', color: '#2BD9A6' },
  { id: 'shoes',   ar: 'أحذية',     en: 'Shoes',    icon: 'CatShoes',   color: '#8B5CF6' },
  { id: 'sale',    ar: 'تخفيضات',   en: 'Sale',     icon: 'CatSale',    color: '#FF6B4A' },
];

const AGE_FILTERS = [
  { id: '0-2',  ar: '٠-٢ سنة',  en: '0–2 yrs' },
  { id: '2-4',  ar: '٢-٤ سنة',  en: '2–4 yrs' },
  { id: '4-6',  ar: '٤-٦ سنة',  en: '4–6 yrs' },
  { id: '6-10', ar: '٦-١٠ سنة', en: '6–10 yrs' },
];

const TYPE_FILTERS = [
  { id: 'dress',   ar: 'فساتين',    en: 'Dresses' },
  { id: 'tshirt',  ar: 'تيشرتات',   en: 'T-shirts' },
  { id: 'jacket',  ar: 'جواكت',     en: 'Jackets' },
  { id: 'pajama',  ar: 'بيجامات',   en: 'Pajamas' },
  { id: 'shoes',   ar: 'أحذية',     en: 'Shoes' },
  { id: 'overall', ar: 'بدلات',     en: 'Overalls' },
  { id: 'hat',     ar: 'قبعات',     en: 'Hats' },
];

const ORDERS = [
  { id: 'TB-2401', date: '2026-04-24', status: 'shipped', total: 23500,
    items: [{ p: 'p1', qty: 1 }, { p: 'p3', qty: 2 }],
    customer: { name_ar: 'أحلام السقاف', name_en: 'Ahlam Al-Saqaf', phone: '+967 71 234 5678', city_ar: 'صنعاء', city_en: 'Sana\'a' },
    payment: 'jaib', receipt: true },
  { id: 'TB-2402', date: '2026-04-25', status: 'pending', total: 11000,
    items: [{ p: 'p2', qty: 1 }],
    customer: { name_ar: 'مروان الحضرمي', name_en: 'Marwan Al-Hadrami', phone: '+967 73 998 1122', city_ar: 'عدن', city_en: 'Aden' },
    payment: 'cremi', receipt: true },
  { id: 'TB-2403', date: '2026-04-26', status: 'confirmed', total: 31500,
    items: [{ p: 'p6', qty: 1 }, { p: 'p4', qty: 1 }, { p: 'p7', qty: 4 }],
    customer: { name_ar: 'هناء عامر', name_en: 'Hanaa Amer', phone: '+967 77 445 9090', city_ar: 'تعز', city_en: 'Ta\'iz' },
    payment: 'bank', receipt: true },
  { id: 'TB-2404', date: '2026-04-26', status: 'preparing', total: 9500,
    items: [{ p: 'p5', qty: 1 }],
    customer: { name_ar: 'سلمى الخولاني', name_en: 'Salma Al-Khoulani', phone: '+967 71 661 2030', city_ar: 'الحديدة', city_en: 'Hodeidah' },
    payment: 'jaib', receipt: true },
  { id: 'TB-2405', date: '2026-04-26', status: 'pending', total: 18000,
    items: [{ p: 'p8', qty: 1 }],
    customer: { name_ar: 'فيصل المنصوري', name_en: 'Faisal Al-Mansouri', phone: '+967 78 220 4411', city_ar: 'إب', city_en: 'Ibb' },
    payment: 'cremi', receipt: false },
];

const STATUSES = {
  pending:   { ar: 'قيد المراجعة', en: 'Pending review',  color: '#FFD23F', ink: '#1A1530' },
  confirmed: { ar: 'تم التأكيد',   en: 'Confirmed',       color: '#3B6BFF', ink: '#FFFFFF' },
  preparing: { ar: 'قيد التجهيز',  en: 'Preparing',       color: '#8B5CF6', ink: '#FFFFFF' },
  shipped:   { ar: 'تم الشحن',     en: 'Shipped',         color: '#FF6B4A', ink: '#FFFFFF' },
  delivered: { ar: 'تم التوصيل',    en: 'Delivered',       color: '#2BD9A6', ink: '#1A1530' },
  rejected:  { ar: 'مرفوض',        en: 'Rejected',         color: '#E84A5F', ink: '#FFFFFF' },
};

const PROMO_CODES = [
  { code: 'BABY10', type: 'percent', value: 10, ar: 'خصم ١٠٪ على أول طلب', en: '10% off your first order', uses: 47, max: 200, expires: '2026-06-30', active: true },
  { code: 'EID2026', type: 'amount', value: 5000, ar: 'خصم ٥٠٠٠ ريال للعيد', en: '5,000 YER off for Eid', uses: 12, max: 100, expires: '2026-05-15', active: true },
  { code: 'SUMMER',  type: 'percent', value: 20, ar: 'خصم ٢٠٪ تشكيلة الصيف', en: '20% off summer collection', uses: 0, max: 50, expires: '2026-08-01', active: false },
];

const CITIES = [
  { ar: 'صنعاء', en: 'Sana\'a' }, { ar: 'عدن', en: 'Aden' },
  { ar: 'تعز', en: 'Ta\'iz' }, { ar: 'الحديدة', en: 'Hodeidah' },
  { ar: 'إب', en: 'Ibb' }, { ar: 'المكلا', en: 'Mukalla' },
  { ar: 'حضرموت', en: 'Hadhramaut' }, { ar: 'ذمار', en: 'Dhamar' },
];

const PAYMENTS = [
  { id: 'jaib',  ar: 'محفظة جيب',      en: 'Jaib Wallet',    color: '#FFD23F', icon: '📱', acct: '+967 77 123 4567' },
  { id: 'cremi', ar: 'كريمي',          en: 'Cremi',          color: '#FF4D8D', icon: '💳', acct: '+967 73 998 0011' },
  { id: 'bank',  ar: 'حوالة بنكية',    en: 'Bank Transfer',  color: '#3B6BFF', icon: '🏦', acct: 'IBAN: YE12 3456 7890' },
];

const REVIEWS = {
  p1: [
    { id: 'r1', name_ar: 'أم محمد', name_en: 'Umm Mohammed', rating: 5, date_ar: 'قبل ٣ أيام', date_en: '3 days ago',
      text_ar: 'الفستان رائع جداً، القماش ناعم على بشرة بنتي والمقاس مضبوط. أنصح به بشدة! ❤️',
      text_en: 'Beautiful dress, very soft fabric and the sizing is spot on. Highly recommend!',
      verified: true, helpful: 12 },
    { id: 'r2', name_ar: 'سارة الحضرمي', name_en: 'Sara Al-Hadrami', rating: 5, date_ar: 'قبل أسبوع', date_en: '1 week ago',
      text_ar: 'لبسته بنتي في عيد ميلادها وكانت أحلى بنت في الحفلة. الكشكش لطيف والخياطة ممتازة.',
      text_en: 'My daughter wore it for her birthday and looked adorable. Lovely ruffles, great stitching.',
      verified: true, helpful: 8 },
    { id: 'r3', name_ar: 'فاطمة ع.', name_en: 'Fatima A.', rating: 4, date_ar: 'قبل أسبوعين', date_en: '2 weeks ago',
      text_ar: 'اللون أجمل من الصور. اللبسة شوي كبيرة، فيتنصح بأخذ مقاس أصغر.',
      text_en: 'Color is even prettier in person. Runs a bit large — size down if possible.',
      verified: true, helpful: 5 },
  ],
  p2: [
    { id: 'r4', name_ar: 'أبو يوسف', name_en: 'Abu Yousef', rating: 5, date_ar: 'قبل ٥ أيام', date_en: '5 days ago',
      text_ar: 'دنيم متين جداً وشكله أنيق على ولدي. الأحزمة قابلة للتعديل ومريحة.',
      text_en: 'Sturdy denim and looks great on my son. Adjustable straps are super handy.',
      verified: true, helpful: 9 },
    { id: 'r5', name_ar: 'هدى الزبيدي', name_en: 'Huda Al-Zubaidi', rating: 5, date_ar: 'قبل ١٠ أيام', date_en: '10 days ago',
      text_ar: 'وصل بسرعة والتغليف ممتاز. القطعة تستاهل السعر.',
      text_en: 'Arrived fast, lovely packaging. Worth every riyal.',
      verified: true, helpful: 4 },
  ],
};

window.TB_DATA = { PRODUCTS, CATEGORIES, AGE_FILTERS, TYPE_FILTERS, ORDERS, STATUSES, PROMO_CODES, CITIES, PAYMENTS, REVIEWS };
