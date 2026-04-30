const express    = require('express');
const { uploadImage } = require('../controllers/uploadController');
const authenticate  = require('../middleware/authenticate');
const requireAdmin  = require('../middleware/requireAdmin');
const upload        = require('../middleware/upload');

const router = express.Router();

router.post(
  '/',
  authenticate,
  requireAdmin,
  upload.single('image'),
  uploadImage,
);

module.exports = router;
