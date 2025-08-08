const jwt = require('jsonwebtoken');

/**
 * Generates a JWT token for a user
 * @param {string} userId - The user's ID
 * @returns {string} The generated JWT token
 */
function generateToken(userId) {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is not set');
  }

  const payload = {
    userId,
    iat: Math.floor(Date.now() / 1000),
  };

  const options = {
    expiresIn: '7d', // Token expires in 7 days
  };

  return jwt.sign(payload, process.env.JWT_SECRET, options);
}

/**
 * Verifies and decodes a JWT token
 * @param {string} token - The JWT token to verify
 * @returns {Object} The decoded token payload
 * @throws {Error} If the token is invalid or expired
 */
function verifyToken(token) {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is not set');
  }

  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('Token has expired');
    } else if (error.name === 'JsonWebTokenError') {
      throw new Error('Invalid token');
    }
    throw error;
  }
}

module.exports = {
  generateToken,
  verifyToken,
};