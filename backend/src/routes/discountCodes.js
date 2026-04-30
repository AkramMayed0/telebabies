const express      = require('express');
const authenticate = require('../middleware/authenticate');
const requireAdmin = require('../middleware/requireAdmin');
const { createCode, applyCode } = require('../controllers/discountCodesController');

const router = express.Router();

router.post('/', authenticate, requireAdmin, createCode);
router.post('/apply', authenticate, applyCode);

module.exports = router;
