const express      = require('express');
const authenticate = require('../middleware/authenticate');
const { createReview, getReviews, deleteReview } = require('../controllers/reviewsController');

const router = express.Router();

router.post('/',    authenticate, createReview);
router.get('/',     getReviews);
router.delete('/:id', authenticate, deleteReview);

module.exports = router;
