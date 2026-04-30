const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/upload',   require('./routes/upload'));
app.use('/api/orders',          require('./routes/orders'));
app.use('/api/discount-codes',  require('./routes/discountCodes'));
app.use('/api/reviews',         require('./routes/reviews'));
app.use('/api/categories',      require('./routes/categories'));
// app.use('/api/users',    require('./routes/users'));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// multer / sharp error → JSON instead of HTML
app.use((err, _req, res, _next) => {
  const status = err.status ?? (err.code === 'LIMIT_FILE_SIZE' ? 413 : 400);
  res.status(status).json({ error: err.message });
});

module.exports = app;
