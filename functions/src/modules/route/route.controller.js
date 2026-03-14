const express   = require('express');
const router    = express.Router();
const Joi       = require('joi');
const NodeCache = require('node-cache');
const rbac      = require('../../middleware/rbac.middleware');
const validate  = require('../../middleware/validate.middleware');
const routeService = require('./route.service');

const cache = new NodeCache({ stdTTL: parseInt(process.env.CACHE_TTL_SECONDS) || 3600 });

// GET /api/routes — Public: list all routes
router.get('/', async (req, res, next) => {
  try {
    const cached = cache.get('all_routes');
    if (cached) return res.json({ data: cached, cached: true });

    const routes = await routeService.getAllRoutes();
    cache.set('all_routes', routes);
    res.json({ data: routes });
  } catch (err) { next(err); }
});

// GET /api/routes/:id — Get single route
router.get('/:id', async (req, res, next) => {
  try {
    const route = await routeService.getRouteById(req.params.id);
    if (!route) return res.status(404).json({ error: 'Route not found' });
    res.json({ data: route });
  } catch (err) { next(err); }
});

// POST /api/routes — Admin only
const routeSchema = Joi.object({
  name:      Joi.string().required(),
  startPoint: Joi.string().required(),
  endPoint:   Joi.string().required(),
  stops: Joi.array().items(Joi.object({
    name:            Joi.string().required(),
    distFromStartKm: Joi.number().required(),
  })).min(2).required(),
  totalKm:   Joi.number().positive().required(),
});

router.post('/', rbac('admin'), validate(routeSchema), async (req, res, next) => {
  try {
    const route = await routeService.createRoute(req.body);
    cache.del('all_routes');
    res.status(201).json({ data: route });
  } catch (err) { next(err); }
});

// PUT /api/routes/:id — Admin only
router.put('/:id', rbac('admin'), async (req, res, next) => {
  try {
    await routeService.updateRoute(req.params.id, req.body);
    cache.del('all_routes');
    res.json({ message: 'Route updated' });
  } catch (err) { next(err); }
});

module.exports = router;
