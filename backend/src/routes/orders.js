const express      = require('express');
const authenticate = require('../middleware/authenticate');
const requireAdmin = require('../middleware/requireAdmin');
const upload       = require('../middleware/upload');
const {
  createOrder, getMyOrders, getOrders, getOrder, updateStatus, getInvoice,
} = require('../controllers/ordersController');

const router = express.Router();

router.post(
  '/',
  authenticate,
  upload.single('receipt'),
  createOrder,
);

router.get('/my', authenticate, getMyOrders);

router.get('/', authenticate, requireAdmin, getOrders);

router.get('/:id', authenticate, getOrder);

router.put(
  '/:id/status',
  authenticate,
  requireAdmin,
  updateStatus,
);

router.get('/:id/invoice', authenticate, getInvoice);

module.exports = router;
