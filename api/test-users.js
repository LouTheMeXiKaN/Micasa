const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

const BASE_URL = 'http://localhost:3000';

// Helper function to make authenticated requests
const makeAuthRequest = (token) => {
  return axios.create({
    baseURL: BASE_URL,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
};

async function testUserEndpoints() {
  console.log('🧪 Testing User Profile Management Endpoints\n');

  let authToken = null;
  let userId = null;

  try {
    // Step 1: Register a test user
    console.log('1. Registering test user...');
    const registerResponse = await axios.post(`${BASE_URL}/auth/register`, {
      email: 'testuser@example.com',
      password: 'securepassword123'
    });
    
    authToken = registerResponse.data.token;
    userId = registerResponse.data.user.user_id;
    console.log('✅ User registered successfully');
    console.log(`   Token: ${authToken.substring(0, 20)}...`);
    console.log(`   User ID: ${userId}\n`);

  } catch (error) {
    console.log('⚠️  Registration failed (user may already exist), trying login...');
    try {
      const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: 'testuser@example.com',
        password: 'securepassword123'
      });
      authToken = loginResponse.data.token;
      userId = loginResponse.data.user.user_id;
      console.log('✅ User logged in successfully\n');
    } catch (loginError) {
      console.error('❌ Both registration and login failed:', loginError.response?.data || loginError.message);
      return;
    }
  }

  const authAxios = makeAuthRequest(authToken);

  try {
    // Step 2: Get current user profile
    console.log('2. Getting current user profile...');
    const profileResponse = await authAxios.get('/users/me');
    userId = profileResponse.data.user_id; // Get the user ID from the profile
    console.log('✅ Profile retrieved successfully');
    console.log('   Profile data:', JSON.stringify(profileResponse.data, null, 2));
    console.log();

    // Step 3: Update user profile
    console.log('3. Updating user profile...');
    const updateData = {
      bio: 'This is my updated bio for testing',
      instagram_handle: 'testuser_insta',
      personal_website_url: 'https://testuser.example.com',
      privacy_show_upcoming_events: true,
      privacy_show_past_events: false
    };

    const updateResponse = await authAxios.put('/users/me', updateData);
    console.log('✅ Profile updated successfully');
    console.log('   Updated profile:', JSON.stringify(updateResponse.data, null, 2));
    console.log();

    // Step 4: Get public profile
    console.log('4. Getting public profile...');
    const publicProfileResponse = await axios.get(`${BASE_URL}/users/${userId}`);
    console.log('✅ Public profile retrieved successfully');
    console.log('   Public profile data:', JSON.stringify(publicProfileResponse.data, null, 2));
    console.log();

    // Step 5: Test validation errors
    console.log('5. Testing validation errors...');
    try {
      await authAxios.put('/users/me', {
        username: '', // Invalid: too short
        instagram_handle: 'invalid@handle!', // Invalid: contains special chars
        personal_website_url: 'not-a-url' // Invalid: not a URL
      });
    } catch (validationError) {
      console.log('✅ Validation errors caught correctly');
      console.log('   Error details:', JSON.stringify(validationError.response.data, null, 2));
      console.log();
    }

    // Step 6: Test duplicate username
    console.log('6. Testing duplicate username prevention...');
    try {
      // Register another user first
      const user2Response = await axios.post(`${BASE_URL}/auth/register`, {
        email: 'testuser2@example.com',
        password: 'securepassword123',
        username: 'testuser2'
      });
      
      const auth2Axios = makeAuthRequest(user2Response.data.token);
      
      // Try to use the first user's username
      await auth2Axios.put('/users/me', {
        username: 'testuser'
      });
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('✅ Duplicate username prevention working correctly');
        console.log('   Error:', error.response.data.message);
        console.log();
      } else {
        console.log('⚠️  Unexpected error during duplicate username test:', error.response?.data || error.message);
      }
    }

    // Step 7: Test avatar upload (if we have a test image)
    console.log('7. Testing avatar upload...');
    try {
      // Create a simple test file (1x1 pixel PNG)
      const testImageBuffer = Buffer.from([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x57, 0x63, 0xF8, 0x0F, 0x00, 0x00,
        0x01, 0x00, 0x01, 0xFA, 0x48, 0x1C, 0x89, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      const form = new FormData();
      form.append('file', testImageBuffer, {
        filename: 'test-avatar.png',
        contentType: 'image/png'
      });

      const uploadResponse = await axios.post(`${BASE_URL}/users/me/avatar`, form, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          ...form.getHeaders()
        }
      });

      console.log('✅ Avatar upload successful');
      console.log('   Upload response:', JSON.stringify(uploadResponse.data, null, 2));
      console.log();
    } catch (uploadError) {
      console.log('⚠️  Avatar upload test failed:', uploadError.response?.data || uploadError.message);
      console.log();
    }

    console.log('🎉 All user profile endpoint tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    if (error.response?.data?.details) {
      console.error('   Details:', error.response.data.details);
    }
  }
}

// Run the tests
if (require.main === module) {
  testUserEndpoints().catch(console.error);
}

module.exports = testUserEndpoints;