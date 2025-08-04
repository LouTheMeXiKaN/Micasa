/**
 * SMS service wrapper for Twilio integration
 */

const twilio = require('twilio');

// Initialize Twilio client
const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

/**
 * Send OTP via SMS using Twilio
 * @param {string} phoneNumber - Recipient's phone number (with country code)
 * @param {string} otp - OTP code to send
 * @returns {Promise<Object>} Twilio message object
 * @throws {Error} If SMS sending fails
 */
async function sendOTP(phoneNumber, otp) {
  try {
    const message = `Your Micasa verification code is: ${otp}. This code expires in 5 minutes.`;
    
    const result = await client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phoneNumber
    });

    return result;
  } catch (error) {
    console.error('Failed to send SMS:', error);
    throw new Error('SMS_SEND_FAILED');
  }
}

/**
 * Format phone number to E.164 format if not already
 * @param {string} phoneNumber - Phone number to format
 * @returns {string} Formatted phone number
 */
function formatPhoneNumber(phoneNumber) {
  // Basic formatting - ensure it starts with +
  // In production, use a library like libphonenumber-js for proper validation
  if (!phoneNumber.startsWith('+')) {
    // Assume US number if no country code
    return `+1${phoneNumber.replace(/\D/g, '')}`;
  }
  return phoneNumber;
}

module.exports = {
  sendOTP,
  formatPhoneNumber
};