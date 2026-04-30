const supabase = require('../config/supabase');

// POST /api/reviews
const createReview = async (req, res) => {
  const { product_id, rating, comment } = req.body;

  if (!product_id) return res.status(400).json({ error: 'product_id is required' });

  const ratingInt = parseInt(rating, 10);
  if (!Number.isInteger(ratingInt) || ratingInt < 1 || ratingInt > 5) {
    return res.status(400).json({ error: 'rating must be an integer between 1 and 5' });
  }

  const { data: product, error: productErr } = await supabase
    .from('products')
    .select('id')
    .eq('id', product_id)
    .eq('active', true)
    .single();

  if (productErr || !product) return res.status(404).json({ error: 'Product not found' });

  const { data, error } = await supabase
    .from('reviews')
    .insert({
      user_id:    req.user.id,
      product_id,
      rating:     ratingInt,
      comment:    comment?.trim() || null,
    })
    .select()
    .single();

  if (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'You have already reviewed this product' });
    }
    return res.status(500).json({ error: error.message });
  }

  res.status(201).json(data);
};

// GET /api/reviews?product_id=X
const getReviews = async (req, res) => {
  const { product_id } = req.query;
  if (!product_id) return res.status(400).json({ error: 'product_id query param is required' });

  const pageNum  = Math.max(1, parseInt(req.query.page,  10) || 1);
  const pageSize = Math.min(50, parseInt(req.query.limit, 10) || 20);
  const from = (pageNum - 1) * pageSize;
  const to   = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('reviews')
    .select('id, user_id, rating, comment, created_at, profiles(name)', { count: 'exact' })
    .eq('product_id', product_id)
    .order('created_at', { ascending: false })
    .range(from, to);

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

// DELETE /api/reviews/:id  — own review or admin
const deleteReview = async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (!Number.isFinite(id)) return res.status(400).json({ error: 'Invalid review id' });

  const { data: review, error: fetchErr } = await supabase
    .from('reviews')
    .select('id, user_id')
    .eq('id', id)
    .single();

  if (fetchErr || !review) return res.status(404).json({ error: 'Review not found' });

  if (review.user_id !== req.user.id) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', req.user.id)
      .single();

    if (profile?.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }
  }

  const { error } = await supabase.from('reviews').delete().eq('id', id);
  if (error) return res.status(500).json({ error: error.message });

  res.status(204).send();
};

module.exports = { createReview, getReviews, deleteReview };
