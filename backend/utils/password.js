const bcrypt = require('bcrypt');

const SALT_ROUNDS = 10;

/**
 * Hashes a plain text password using bcrypt
 * @param {string} plainPassword - The plain text password to hash
 * @returns {Promise<string>} The hashed password
 */
async function hashPassword(plainPassword) {
  if (!plainPassword || plainPassword.length < 8) {
    throw new Error('Password must be at least 8 characters long');
  }

  return await bcrypt.hash(plainPassword, SALT_ROUNDS);
}

/**
 * Compares a plain text password with a hashed password
 * @param {string} plainPassword - The plain text password to compare
 * @param {string} hashedPassword - The hashed password to compare against
 * @returns {Promise<boolean>} True if passwords match, false otherwise
 */
async function comparePassword(plainPassword, hashedPassword) {
  if (!plainPassword || !hashedPassword) {
    return false;
  }

  return await bcrypt.compare(plainPassword, hashedPassword);
}

module.exports = {
  hashPassword,
  comparePassword,
};