const supabase = require('../config/supabase');

const VALID_GENDERS = ['girls', 'boys', 'unisex'];
const VALID_AGES    = ['0-2', '2-4', '4-6', '6-10'];
const VALID_TYPES   = ['dress', 'tshirt', 'jacket', 'pajama', 'shoes', 'overall', 'hat'];

const getAll = async (req, res) => {
  const {
    gender,
    age,
    type,
    search,
    sale,
    page  = 1,
    limit = 20,
  } = req.query;

  // validate pagination
  const pageNum  = Math.max(1, parseInt(page, 10)  || 1);
  const pageSize = Math.min(100, parseInt(limit, 10) || 20);
  const from = (pageNum - 1) * pageSize;
  const to   = from + pageSize - 1;

  let query = supabase
    .from('products')
    .select('*', { count: 'exact' })
    .eq('active', true);

  if (gender && VALID_GENDERS.includes(gender)) {
    query = query.eq('cat', gender);
  }

  if (age && VALID_AGES.includes(age)) {
    query = query.eq('age', age);
  }

  if (type && VALID_TYPES.includes(type)) {
    query = query.eq('type', type);
  }

  if (sale === 'true') {
    query = query.not('old_price', 'is', null);
  }

  if (search?.trim()) {
    const s = search.trim();
    query = query.or(`name_en.ilike.%${s}%,name_ar.ilike.%${s}%`);
  }

  const { data, error, count } = await query
    .order('created_at', { ascending: false })
    .range(from, to);

  if (error) return res.status(500).json({ error: error.message });

  res.json({
    data,
    meta: {
      total: count,
      page: pageNum,
      limit: pageSize,
      pages: Math.ceil(count / pageSize),
    },
  });
};

const getOne = async (req, res) => {
  const { id } = req.params;

  const [productRes, reviewsRes] = await Promise.all([
    supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .eq('active', true)
      .single(),
    supabase
      .from('reviews')
      .select('id, user_id, rating, comment, created_at, profiles(name)')
      .eq('product_id', id)
      .order('created_at', { ascending: false }),
  ]);

  if (productRes.error || !productRes.data) {
    return res.status(404).json({ error: 'Product not found' });
  }

  const reviews  = reviewsRes.data ?? [];
  const avgRating = reviews.length
    ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
    : null;

  res.json({
    ...productRes.data,
    reviews,
    avg_rating:    avgRating ? parseFloat(avgRating.toFixed(1)) : null,
    review_count:  reviews.length,
  });
};

const create = async (req, res) => {
  const {
    id, name_ar, name_en, cat, age, type,
    price, old_price, img, color,
    tag_ar, tag_en, desc_ar, desc_en,
    sizes, stock,
  } = req.body;

  // required fields
  const missing = ['id','name_ar','name_en','cat','age','type','price','desc_ar','desc_en','sizes','stock']
    .filter(f => req.body[f] === undefined || req.body[f] === '');
  if (missing.length) {
    return res.status(400).json({ error: `Missing required fields: ${missing.join(', ')}` });
  }

  if (typeof price !== 'number' || price <= 0) {
    return res.status(400).json({ error: 'price must be a positive number' });
  }
  if (!Array.isArray(sizes) || sizes.length === 0) {
    return res.status(400).json({ error: 'sizes must be a non-empty array' });
  }
  if (!VALID_GENDERS.includes(cat) && !['newborn','shoes','sale'].includes(cat)) {
    return res.status(400).json({ error: `Invalid cat. Use: ${[...VALID_GENDERS,'newborn','shoes','sale'].join(', ')}` });
  }
  if (!VALID_AGES.includes(age)) {
    return res.status(400).json({ error: `Invalid age. Use: ${VALID_AGES.join(', ')}` });
  }
  if (!VALID_TYPES.includes(type)) {
    return res.status(400).json({ error: `Invalid type. Use: ${VALID_TYPES.join(', ')}` });
  }

  const { data, error } = await supabase
    .from('products')
    .insert({
      id, name_ar, name_en, cat, age, type,
      price, old_price: old_price ?? null,
      img: img ?? null,
      color: color ?? '#FFD23F',
      tag_ar: tag_ar ?? null,
      tag_en: tag_en ?? null,
      desc_ar, desc_en, sizes,
      stock: stock ?? 0,
    })
    .select()
    .single();

  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json(data);
};

const update = async (req, res) => {
  const { id } = req.params;

  // check product exists
  const { data: existing } = await supabase
    .from('products')
    .select('id')
    .eq('id', id)
    .single();

  if (!existing) return res.status(404).json({ error: 'Product not found' });

  // whitelist updatable fields
  const allowed = [
    'name_ar','name_en','cat','age','type',
    'price','old_price','img','color',
    'tag_ar','tag_en','desc_ar','desc_en',
    'sizes','stock','active',
  ];

  const patch = {};
  for (const key of allowed) {
    if (key in req.body) patch[key] = req.body[key];
  }

  if (Object.keys(patch).length === 0) {
    return res.status(400).json({ error: 'No valid fields provided' });
  }

  // per-field validation on whatever was sent
  if ('price' in patch && (typeof patch.price !== 'number' || patch.price <= 0)) {
    return res.status(400).json({ error: 'price must be a positive number' });
  }
  if ('sizes' in patch && (!Array.isArray(patch.sizes) || patch.sizes.length === 0)) {
    return res.status(400).json({ error: 'sizes must be a non-empty array' });
  }
  if ('cat' in patch && !['girls','boys','unisex','newborn','shoes','sale'].includes(patch.cat)) {
    return res.status(400).json({ error: 'Invalid cat value' });
  }
  if ('age' in patch && !VALID_AGES.includes(patch.age)) {
    return res.status(400).json({ error: 'Invalid age value' });
  }
  if ('type' in patch && !VALID_TYPES.includes(patch.type)) {
    return res.status(400).json({ error: 'Invalid type value' });
  }

  const { data, error } = await supabase
    .from('products')
    .update(patch)
    .eq('id', id)
    .select()
    .single();

  if (error) return res.status(400).json({ error: error.message });
  res.json(data);
};

const remove = async (req, res) => {
  const { id } = req.params;

  const { data: existing } = await supabase
    .from('products')
    .select('id, active')
    .eq('id', id)
    .single();

  if (!existing) return res.status(404).json({ error: 'Product not found' });
  if (!existing.active) return res.status(409).json({ error: 'Product is already deleted' });

  const { error } = await supabase
    .from('products')
    .update({ active: false })
    .eq('id', id);

  if (error) return res.status(400).json({ error: error.message });
  res.status(204).send();
};

module.exports = { getAll, getOne, create, update, remove };
