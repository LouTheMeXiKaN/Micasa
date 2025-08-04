const { verifyToken } = require('../utils/jwt');

/**
 * Middleware to authenticate JWT tokens from the Authorization header
 * Expects format: "Bearer <token>"
 * Adds req.userId to the request object if authentication is successful
 */
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      error_code: 'UNAUTHORIZED',
      message: 'Authentication token is required',
    });
  }

  try {
    const decoded = verifyToken(token);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    if (error.message === 'Token has expired') {
      return res.status(401).json({
        error_code: 'TOKEN_EXPIRED',
        message: 'Authentication token has expired',
      });
    }
    
    return res.status(401).json({
      error_code: 'INVALID_TOKEN',
      message: 'Invalid authentication token',
    });
  }
}

module.exports = {
  authenticateToken,
};