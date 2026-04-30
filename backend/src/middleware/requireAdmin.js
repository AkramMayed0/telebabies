const supabase = require('../config/supabase');

const requireAdmin = async (req, res, next) => {
  const { data, error } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', req.user.id)
    .single();

  if (error || !data) {
    return res.status(403).json({ error: 'Could not verify role' });
  }

  if (data.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }

  req.user.role = 'admin';
  next();
};

module.exports = requireAdmin;
