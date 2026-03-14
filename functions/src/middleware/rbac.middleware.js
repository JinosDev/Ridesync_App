/**
 * Role-based access control middleware factory.
 * Usage: router.post('/route', rbac('admin'), handler)
 * @param {...string} roles - Allowed roles
 */
function rbac(...roles) {
  return (req, res, next) => {
    const userRole = req.user?.role;
    if (!userRole || !roles.includes(userRole)) {
      return res.status(403).json({ error: `Access denied. Required role: ${roles.join(' | ')}` });
    }
    next();
  };
}

module.exports = rbac;
