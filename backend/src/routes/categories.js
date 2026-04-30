const express      = require('express');
const authenticate = require('../middleware/authenticate');
const requireAdmin = require('../middleware/requireAdmin');
const { getAll, getOne, create, update, remove } = require('../controllers/categoriesController');

const router = express.Router();

router.get('/',    getAll);
router.get('/:id', getOne);
router.post('/',      authenticate, requireAdmin, create);
router.put('/:id',    authenticate, requireAdmin, update);
router.delete('/:id', authenticate, requireAdmin, remove);

module.exports = router;
