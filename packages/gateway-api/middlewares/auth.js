// Retrieve user from Static Web Apps authentication header
function getUser(req) {
  try {
    const header = req.headers['x-ms-client-principal'];
    const principal = Buffer
      .from(header, 'base64')
      .toString('ascii');

    if (principal) {
      return JSON.parse(principal)?.userId;
    }
  } catch (error) {
    req.log.error('Cannot get user', error);
  }
  return undefined;
}

// Middleware to check if user is authenticated
function auth(req, res, next) {
  req.user = getUser(req);
  if (!req.user) {
    return res.sendStatus(401);
  }
  next();
}

module.exports = auth;
