const { randomUUID } = require("crypto");

const headerName = 'x-correlation-id';

// Middleware to check if user is authenticated
function correlation(req, res, next) {
  let correlationId = req.get(headerName);
  if (!correlationId) {
    correlationId = randomUUID();
    req.set(headerName);
  }
  req.correlationId = correlationId;
  next();
}

module.exports = correlation;