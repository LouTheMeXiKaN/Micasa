/**
 * Simple test script for authentication endpoints
 * Run with: JWT_SECRET=your-secret-key node test-auth.js
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testAuth() {
  console.log('Testing Authentication Endpoints...\n');

  // Test data
  const testEmail = `test_${Date.now()}@example.com`;
  const testPassword = 'SecurePass123';
  let authToken = '';

  try {
    // Test 1: Register a new user
    console.log('1. Testing POST /auth/register');
    const registerResponse = await axios.post(`${BASE_URL}/auth/register`, {
      email: testEmail,
      password: testPassword,
    });
    
    console.log('✓ Registration successful');
    console.log('  Response:', {
      token: registerResponse.data.token ? 'JWT token received' : 'No token',
      user: registerResponse.data.user,
    });
    
    authToken = registerResponse.data.token;

    // Test 2: Try to register with same email (should fail)
    console.log('\n2. Testing duplicate registration (should fail)');
    try {
      await axios.post(`${BASE_URL}/auth/register`, {
        email: testEmail,
        password: testPassword,
      });
      console.log('✗ Duplicate registration succeeded (this is wrong!)');
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('✓ Duplicate registration correctly rejected');
        console.log('  Error:', error.response.data);
      } else {
        throw error;
      }
    }

    // Test 3: Login with correct credentials
    console.log('\n3. Testing POST /auth/login with correct credentials');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: testEmail,
      password: testPassword,
    });
    
    console.log('✓ Login successful');
    console.log('  Response:', {
      token: loginResponse.data.token ? 'JWT token received' : 'No token',
      user: loginResponse.data.user,
    });

    // Test 4: Login with wrong password (should fail)
    console.log('\n4. Testing login with wrong password (should fail)');
    try {
      await axios.post(`${BASE_URL}/auth/login`, {
        email: testEmail,
        password: 'WrongPassword',
      });
      console.log('✗ Login with wrong password succeeded (this is wrong!)');
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('✓ Login with wrong password correctly rejected');
        console.log('  Error:', error.response.data);
      } else {
        throw error;
      }
    }

    // Test 5: Test validation errors
    console.log('\n5. Testing validation errors');
    
    // Invalid email format
    try {
      await axios.post(`${BASE_URL}/auth/register`, {
        email: 'invalid-email',
        password: testPassword,
      });
      console.log('✗ Invalid email accepted (this is wrong!)');
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('✓ Invalid email format correctly rejected');
      }
    }

    // Short password
    try {
      await axios.post(`${BASE_URL}/auth/register`, {
        email: 'another@example.com',
        password: 'short',
      });
      console.log('✗ Short password accepted (this is wrong!)');
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('✓ Short password correctly rejected');
      }
    }

    console.log('\n✅ All authentication tests passed!');
    
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

// Check if server is running
axios.get(BASE_URL)
  .then(() => {
    console.log(`Server is running at ${BASE_URL}`);
    testAuth();
  })
  .catch(() => {
    console.error(`Server is not running at ${BASE_URL}`);
    console.error('Please start the server with: JWT_SECRET=your-secret-key npm start');
  });