const supabase = require('../config/supabase');

const VALID_TYPES = ['age_group', 'gender', 'clothing_type'];

// GET /api/categories
const getAll = async (req, res) => {
  let query = supabase
    .from('categories')
    .select('*')
    .order('type')
    .order('name');

  if (req.query.type && VALID_TYPES.includes(req.query.type)) {
    query = query.eq('type', req.query.type);
  }

  if (req.query.active !== undefined) {
    query = query.eq('is_active', req.query.active === 'true');
  }

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: error.message });

  res.json(data);
};

// GET /api/categories/:id
const getOne = async (req, res) => {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .eq('id', req.params.id)
    .single();

  if (error || !data) return res.status(404).json({ error: 'Category not found' });

  res.json(data);
};

// POST /api/categories
const create = async (req, res) => {
  const { type, name, is_active } = req.body;

  if (!VALID_TYPES.includes(type)) {
    return res.status(400).json({ error: `type must be one of: ${VALID_TYPES.join(', ')}` });
  }

  const trimmedName = name?.trim();
  if (!trimmedName) return res.status(400).json({ error: 'name is required' });

  const { data, error } = await supabase
    .from('categories')
    .insert({
      type,
      name:      trimmedName,
      is_active: is_active !== undefined ? Boolean(is_active) : true,
    })
    .select()
    .single();

  if (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'A category with this type and name already exists' });
    }
    return res.status(500).json({ error: error.message });
  }

  res.status(201).json(data);
};

// PUT /api/categories/:id
const update = async (req, res) => {
  const allowed = {};

  if (req.body.type !== undefined) {
    if (!VALID_TYPES.includes(req.body.type)) {
      return res.status(400).json({ error: `type must be one of: ${VALID_TYPES.join(', ')}` });
    }
    allowed.type = req.body.type;
  }

  if (req.body.name !== undefined) {
    const trimmedName = req.body.name.trim();
    if (!trimmedName) return res.status(400).json({ error: 'name cannot be empty' });
    allowed.name = trimmedName;
  }

  if (req.body.is_active !== undefined) {
    allowed.is_active = Boolean(req.body.is_active);
  }

  if (Object.keys(allowed).length === 0) {
    return res.status(400).json({ error: 'No fields to update' });
  }

  const { data, error } = await supabase
    .from('categories')
    .update(allowed)
    .eq('id', req.params.id)
    .select()
    .single();

  if (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'A category with this type and name already exists' });
    }
    return res.status(500).json({ error: error.message });
  }

  if (!data) return res.status(404).json({ error: 'Category not found' });

  res.json(data);
};

// DELETE /api/categories/:id
const remove = async (req, res) => {
  const { data, error } = await supabase
    .from('categories')
    .delete()
    .eq('id', req.params.id)
    .select()
    .single();

  if (error || !data) return res.status(404).json({ error: 'Category not found' });

  res.status(204).send();
};

module.exports = { getAll, getOne, create, update, remove };
