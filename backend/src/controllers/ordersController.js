const sharp            = require('sharp');
const crypto           = require('crypto');
const supabase         = require('../config/supabase');
const sendNotification = require('../utils/sendNotification');

const BUCKET  = 'receipts';
const MAX_DIM = 2000;   // keep receipt legible
const QUALITY = 80;

async function _uploadReceipt(buffer) {
  const compressed = await sharp(buffer)
    .rotate()
    .resize(MAX_DIM, MAX_DIM, { fit: 'inside', withoutEnlargement: true })
    .webp({ quality: QUALITY })
    .toBuffer();

  const filename = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}.webp`;
  const path     = `${filename}`;

  const { error } = await supabase.storage
    .from(BUCKET)
    .upload(path, compressed, {
      contentType:  'image/webp',
      cacheControl: '3600',
      upsert:       false,
    });

  if (error) throw new Error(error.message);

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return { url: data.publicUrl, path };
}

// POST /api/orders
// Body (multipart/form-data):
//   name, phone, city, address  – delivery info
//   payment                     – jaib | cremi | bank
//   subtotal, shipping, discount, total  – integers (YER)
//   promo_code                  – optional
//   items                       – JSON string: [{product_id, size, qty, unit_price}]
//   receipt                     – image file (required)
const createOrder = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Receipt image is required' });
  }

  // delivery fields
  const name    = req.body.name?.trim();
  const phone   = req.body.phone?.trim();
  const city    = req.body.city?.trim();
  const address = req.body.address?.trim();
  if (!name || !phone || !city || !address) {
    return res.status(400).json({ error: 'name, phone, city and address are required' });
  }

  // payment
  const payment = req.body.payment?.trim();
  if (!['jaib', 'cremi', 'bank'].includes(payment)) {
    return res.status(400).json({ error: 'payment must be jaib, cremi or bank' });
  }

  // totals
  const subtotal = parseInt(req.body.subtotal, 10);
  const shipping = parseInt(req.body.shipping, 10);
  const discount = parseInt(req.body.discount ?? 0, 10);
  const total    = parseInt(req.body.total, 10);
  if (!Number.isFinite(subtotal) || subtotal < 0) return res.status(400).json({ error: 'subtotal must be a non-negative integer' });
  if (!Number.isFinite(shipping) || shipping < 0) return res.status(400).json({ error: 'shipping must be a non-negative integer' });
  if (!Number.isFinite(discount) || discount < 0) return res.status(400).json({ error: 'discount must be a non-negative integer' });
  if (!Number.isFinite(total)    || total    <= 0) return res.status(400).json({ error: 'total must be a positive integer' });

  // items
  let items;
  try {
    items = typeof req.body.items === 'string' ? JSON.parse(req.body.items) : req.body.items;
  } catch {
    return res.status(400).json({ error: 'items must be valid JSON' });
  }
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'items must be a non-empty array' });
  }
  for (const [i, item] of items.entries()) {
    if (!item.product_id) return res.status(400).json({ error: `items[${i}]: product_id is required` });
    if (!item.size)        return res.status(400).json({ error: `items[${i}]: size is required` });
    if (!Number.isInteger(item.qty) || item.qty < 1)            return res.status(400).json({ error: `items[${i}]: qty must be a positive integer` });
    if (!Number.isInteger(item.unit_price) || item.unit_price <= 0) return res.status(400).json({ error: `items[${i}]: unit_price must be a positive integer` });
  }

  // upload receipt image
  let receiptUrl;
  try {
    ({ url: receiptUrl } = await _uploadReceipt(req.file.buffer));
  } catch (err) {
    return res.status(500).json({ error: `Receipt upload failed: ${err.message}` });
  }

  // insert order
  const { data: order, error: orderErr } = await supabase
    .from('orders')
    .insert({
      user_id:    req.user.id,
      name, phone, city, address,
      payment,
      subtotal, shipping, discount, total,
      promo_code: req.body.promo_code?.trim() || null,
      receipt_url: receiptUrl,
    })
    .select()
    .single();

  if (orderErr) return res.status(500).json({ error: orderErr.message });

  // insert order items
  const { error: itemsErr } = await supabase
    .from('order_items')
    .insert(items.map(item => ({
      order_id:   order.id,
      product_id: item.product_id,
      size:       item.size,
      qty:        item.qty,
      unit_price: item.unit_price,
    })));

  if (itemsErr) {
    // roll back the order header to keep data consistent
    await supabase.from('orders').delete().eq('id', order.id);
    return res.status(500).json({ error: itemsErr.message });
  }

  res.status(201).json({ ...order, order_items: items });

  // notify all admins — fire-and-forget, never blocks the response
  supabase
    .from('profiles')
    .select('fcm_token')
    .eq('role', 'admin')
    .not('fcm_token', 'is', null)
    .then(({ data: admins }) => {
      const tokens = admins?.map(a => a.fcm_token).filter(Boolean) ?? [];
      if (!tokens.length) return;
      return sendNotification({
        token: tokens,
        title: 'طلب جديد',
        body:  `${order.id} — ${order.total.toLocaleString()} ر.ي`,
        data:  { order_id: order.id, screen: 'order_detail' },
      });
    })
    .catch(() => {});   // notification failure must never surface to the client
};

// GET /api/orders/my  – always scoped to the authenticated user
// Query params: status, page, limit
const getMyOrders = async (req, res) => {
  const VALID_STATUS = ['pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'rejected'];

  const pageNum  = Math.max(1, parseInt(req.query.page,  10) || 1);
  const pageSize = Math.min(50, parseInt(req.query.limit, 10) || 20);
  const from = (pageNum - 1) * pageSize;
  const to   = from + pageSize - 1;

  let query = supabase
    .from('orders')
    .select('*', { count: 'exact' })
    .eq('user_id', req.user.id)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (req.query.status && VALID_STATUS.includes(req.query.status)) {
    query = query.eq('status', req.query.status);
  }

  const { data, error, count } = await query;
  if (error) return res.status(500).json({ error: error.message });

  res.json({
    data,
    meta: {
      total: count,
      page:  pageNum,
      limit: pageSize,
      pages: Math.ceil(count / pageSize),
    },
  });
};

// GET /api/orders  – admin only
// Query params: status, search (order id / name / phone), page, limit
const getOrders = async (req, res) => {
  const VALID_STATUS = ['pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'rejected'];

  const pageNum  = Math.max(1, parseInt(req.query.page,  10) || 1);
  const pageSize = Math.min(100, parseInt(req.query.limit, 10) || 20);
  const from = (pageNum - 1) * pageSize;
  const to   = from + pageSize - 1;

  let query = supabase
    .from('orders')
    .select('*, order_items(*)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);

  if (req.query.status && VALID_STATUS.includes(req.query.status)) {
    query = query.eq('status', req.query.status);
  }

  const search = req.query.search?.trim();
  if (search) {
    query = query.or(`id.ilike.%${search}%,name.ilike.%${search}%,phone.ilike.%${search}%`);
  }

  const { data, error, count } = await query;
  if (error) return res.status(500).json({ error: error.message });

  res.json({
    data,
    meta: {
      total: count,
      page:  pageNum,
      limit: pageSize,
      pages: Math.ceil(count / pageSize),
    },
  });
};

// GET /api/orders/:id
const getOrder = async (req, res) => {
  const { data, error } = await supabase
    .from('orders')
    .select('*, order_items(*)')
    .eq('id', req.params.id)
    .single();

  if (error || !data) return res.status(404).json({ error: 'Order not found' });

  if (req.user.role !== 'admin' && data.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  res.json(data);
};

const STATUS_COPY = {
  confirmed: { title: 'تم تأكيد طلبك',       body: 'سنبدأ بتحضيره قريباً.' },
  preparing: { title: 'طلبك قيد التحضير',     body: 'جاري تجهيز طلبك الآن.' },
  shipped:   { title: 'طلبك في الطريق إليك', body: 'سيصلك قريباً، شكراً لثقتك بنا!' },
  delivered: { title: 'تم تسليم طلبك',        body: 'نتمنى أن ينال إعجابك.' },
  rejected:  { title: 'تعذّر تأكيد طلبك',     body: 'يرجى التواصل معنا لمزيد من التفاصيل.' },
};

// PUT /api/orders/:id/status  – admin only
const updateStatus = async (req, res) => {
  const VALID = Object.keys(STATUS_COPY).concat('pending');
  const { status } = req.body;

  if (!VALID.includes(status)) {
    return res.status(400).json({ error: `status must be one of: ${VALID.join(', ')}` });
  }

  const { data: order, error } = await supabase
    .from('orders')
    .update({ status })
    .eq('id', req.params.id)
    .select()
    .single();

  if (error || !order) return res.status(404).json({ error: 'Order not found' });

  res.json(order);

  // notify the customer — fire-and-forget
  const copy = STATUS_COPY[status];
  if (!copy) return;   // 'pending' has no customer-facing message

  supabase
    .from('profiles')
    .select('fcm_token')
    .eq('id', order.user_id)
    .single()
    .then(({ data: profile }) => {
      if (!profile?.fcm_token) return;
      return sendNotification({
        token: profile.fcm_token,
        title: copy.title,
        body:  `${order.id} — ${copy.body}`,
        data:  { order_id: order.id, screen: 'order_detail' },
      });
    })
    .catch(() => {});
};

// GET /api/orders/:id/invoice  — own order or admin; confirmed+ only
const getInvoice = async (req, res) => {
  const { data: order, error } = await supabase
    .from('orders')
    .select('*, order_items(product_id, size, qty, unit_price)')
    .eq('id', req.params.id)
    .single();

  if (error || !order) return res.status(404).json({ error: 'Order not found' });

  if (req.user.role !== 'admin' && order.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const CONFIRMED_STATUSES = ['confirmed', 'preparing', 'shipped', 'delivered'];
  if (!CONFIRMED_STATUSES.includes(order.status)) {
    return res.status(400).json({ error: 'Invoice is only available after the order is confirmed' });
  }

  // enrich items with product names
  const productIds = [...new Set(order.order_items.map(i => i.product_id))];
  const { data: products } = await supabase
    .from('products')
    .select('id, name_ar, name_en, img')
    .in('id', productIds);

  const productMap = Object.fromEntries((products ?? []).map(p => [p.id, p]));

  const invoice = {
    invoice_number: order.id,
    issued_at:      new Date().toISOString(),
    status:         order.status,
    customer: {
      name:    order.name,
      phone:   order.phone,
      city:    order.city,
      address: order.address,
    },
    payment_method: order.payment,
    items: order.order_items.map(item => ({
      product_id:  item.product_id,
      name_ar:     productMap[item.product_id]?.name_ar ?? null,
      name_en:     productMap[item.product_id]?.name_en ?? null,
      img:         productMap[item.product_id]?.img ?? null,
      size:        item.size,
      qty:         item.qty,
      unit_price:  item.unit_price,
      line_total:  item.qty * item.unit_price,
    })),
    subtotal:   order.subtotal,
    shipping:   order.shipping,
    discount:   order.discount,
    promo_code: order.promo_code ?? null,
    total:      order.total,
  };

  res.json(invoice);
};

module.exports = { createOrder, getMyOrders, getOrders, getOrder, updateStatus, getInvoice };
