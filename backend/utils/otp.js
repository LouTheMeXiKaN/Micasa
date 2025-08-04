/**
 * OTP (One-Time Password) utility functions for phone verification
 */

/**
 * Generate a 6-digit numeric OTP
 * @returns {string} 6-digit OTP code
 */
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Get OTP expiration time (5 minutes from now)
 * @returns {Date} Expiration timestamp
 */
function getOTPExpiration() {
  return new Date(Date.now() + 5 * 60 * 1000); // 5 minutes
}

/**
 * Validate OTP against stored values
 * @param {string} storedOtp - OTP stored in database
 * @param {Date} storedExpiration - Expiration time stored in database
 * @param {string} providedOtp - OTP provided by user
 * @returns {boolean} Whether OTP is valid
 */
function validateOTP(storedOtp, storedExpiration, providedOtp) {
  // Check if OTP exists
  if (!storedOtp || !storedExpiration) {
    return false;
  }

  // Check if OTP has expired
  if (new Date() > storedExpiration) {
    return false;
  }

  // Check if OTP matches
  return storedOtp === providedOtp;
}

module.exports = {
  generateOTP,
  getOTPExpiration,
  validateOTP
};