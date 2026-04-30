const supabase = require('../config/supabase');

// POST /api/discount-codes
const createCode = async (req, res) => {
  const { code, type, value, min_order, max_uses, expires_at } = req.body;

  // required
  if (!code || typeof code !== 'string' || !code.trim()) {
    return res.status(400).json({ error: 'code is required' });
  }
  if (!['percent', 'fixed'].includes(type)) {
    return res.status(400).json({ error: 'type must be "percent" or "fixed"' });
  }
  if (typeof value !== 'number' || !Number.isInteger(value) || value <= 0) {
    return res.status(400).json({ error: 'value must be a positive integer' });
  }
  if (type === 'percent' && value > 100) {
    return res.status(400).json({ error: 'percent value cannot exceed 100' });
  }

  // optional with validation
  if (min_order !== undefined && (!Number.isInteger(min_order) || min_order < 0)) {
    return res.status(400).json({ error: 'min_order must be a non-negative integer' });
  }
  if (max_uses !== undefined && max_uses !== null && (!Number.isInteger(max_uses) || max_uses < 1)) {
    return res.status(400).json({ error: 'max_uses must be a positive integer or null' });
  }
  if (expires_at !== undefined && expires_at !== null && isNaN(Date.parse(expires_at))) {
    return res.status(400).json({ error: 'expires_at must be a valid ISO date' });
  }

  const { data, error } = await supabase
    .from('discount_codes')
    .insert({
      code:       code.trim().toUpperCase(),
      type,
      value,
      min_order:  min_order  ?? 0,
      max_uses:   max_uses   ?? null,
      expires_at: expires_at ?? null,
    })
    .select()
    .single();

  if (error) {
    const status = error.code === '23505' ? 409 : 400;
    return res.status(status).json({ error: error.code === '23505' ? 'Code already exists' : error.message });
  }

  res.status(201).json(data);
};

// POST /api/discount-codes/apply
// Body: { code, subtotal }
// Validates the code and returns the discount amount.
// Does NOT increment uses — that happens when the order is saved.
const applyCode = async (req, res) => {
  const code = req.body.code?.trim().toUpperCase();
  const subtotal = req.body.subtotal;

  if (!code) {
    return res.status(400).json({ error: 'code is required' });
  }
  if (!Number.isInteger(subtotal) || subtotal < 0) {
    return res.status(400).json({ error: 'subtotal must be a non-negative integer' });
  }

  const { data, error } = await supabase
    .from('discount_codes')
    .select('id, code, type, value, min_order, max_uses, uses, expires_at')
    .eq('code', code)
    .eq('active', true)
    .single();

  if (error || !data) {
    return res.status(404).json({ error: 'Invalid or inactive discount code' });
  }

  if (data.expires_at && new Date(data.expires_at) <= new Date()) {
    return res.status(422).json({ error: 'Discount code has expired' });
  }
  if (data.max_uses !== null && data.uses >= data.max_uses) {
    return res.status(422).json({ error: 'Discount code has reached its usage limit' });
  }
  if (subtotal < data.min_order) {
    return res.status(422).json({
      error: `Minimum order of ${data.min_order} YER required for this code`,
      min_order: data.min_order,
    });
  }

  const discount = data.type === 'percent'
    ? Math.round(subtotal * data.value / 100)
    : Math.min(data.value, subtotal);   // fixed never exceeds subtotal

  res.json({
    code:      data.code,
    type:      data.type,
    value:     data.value,
    discount,
    subtotal,
  });
};

module.exports = { createCode, applyCode };
