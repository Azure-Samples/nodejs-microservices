// Retrieve user from Static Web Apps authentication header
function getUser(req) {
  try {
    const principal = Buffer
      .from(req.headers['x-ms-client-principal'], 'base64')
      .toString('ascii');

    if (principal) {
      return JSON.parse(principal)?.userDetails;
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
    return res.status(401).send('Unauthorized');
  }
  next();
}

module.exports = auth;
