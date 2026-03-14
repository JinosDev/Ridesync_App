/**
 * Centralised error handler — last middleware in Express chain.
 * Maps known error types to HTTP status codes.
 */
function errorHandler(err, req, res, next) {
  console.error('[ERROR]', err.message, err.stack);

  if (err.name === 'ValidationError') {
    return res.status(422).json({ error: err.message });
  }
  if (err.code === 'permission-denied' || err.code === 'unauthenticated') {
    return res.status(403).json({ error: 'Permission denied' });
  }
  if (err.status) {
    return res.status(err.status).json({ error: err.message });
  }

  return res.status(500).json({ error: 'Internal server error' });
}

module.exports = { errorHandler };
