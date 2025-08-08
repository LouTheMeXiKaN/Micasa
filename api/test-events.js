const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:3000';

// Test data
const testEvent = {
  title: 'Test Community Gathering',
  description: 'A test event for our community',
  start_time: '2025-08-10T19:00:00.000Z',
  end_time: '2025-08-10T23:00:00.000Z',
  location_address: '123 Community Center St, Test City',
  location_visibility: 'immediate',
  pricing_model: 'free_rsvp',
  guest_list_visibility: 'public',
  is_invite_only: false,
  max_capacity: 50
};

let authToken = null;
let eventId = null;

async function testEventEndpoints() {
  try {
    console.log('🧪 Testing Event Endpoints...\n');

    // 1. First, we need to authenticate
    console.log('1. Authenticating user...');
    try {
      const authResponse = await axios.post(`${API_BASE_URL}/auth/login`, {
        username: 'testuser',
        password: 'testpass123'
      });
      authToken = authResponse.data.token;
      console.log('✅ Authentication successful');
    } catch (error) {
      console.log('⚠️  Using existing user or creating new one...');
      // Try to register a test user if login fails
      try {
        await axios.post(`${API_BASE_URL}/auth/register`, {
          email: 'testuser@example.com',
          username: 'testuser',
          password: 'testpass123'
        });
        console.log('✅ Test user created');
        
        const authResponse = await axios.post(`${API_BASE_URL}/auth/login`, {
          username: 'testuser',
          password: 'testpass123'
        });
        authToken = authResponse.data.token;
        console.log('✅ Authentication successful');
      } catch (registerError) {
        console.error('❌ Failed to register/login test user');
        console.error('Error:', registerError.response?.data || registerError.message);
        return;
      }
    }

    // 2. Test event creation
    console.log('\n2. Creating a new event...');
    try {
      const createResponse = await axios.post(`${API_BASE_URL}/events`, testEvent, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      eventId = createResponse.data.event_id;
      console.log('✅ Event created successfully');
      console.log('Event ID:', eventId);
      console.log('Event Title:', createResponse.data.title);
      console.log('Current User Role:', createResponse.data.current_user_role);
      console.log('Stats:', createResponse.data.stats);
    } catch (error) {
      console.error('❌ Failed to create event');
      console.error('Error:', error.response?.data || error.message);
      return;
    }

    // 3. Test event retrieval (authenticated)
    console.log('\n3. Retrieving event (authenticated)...');
    try {
      const getResponse = await axios.get(`${API_BASE_URL}/events/${eventId}`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      console.log('✅ Event retrieved successfully');
      console.log('Event Title:', getResponse.data.title);
      console.log('Current User Role:', getResponse.data.current_user_role);
      console.log('Location Visibility:', getResponse.data.location_visibility);
      console.log('Guest List Visibility:', getResponse.data.guest_list_visibility);
    } catch (error) {
      console.error('❌ Failed to retrieve event (authenticated)');
      console.error('Error:', error.response?.data || error.message);
    }

    // 4. Test event retrieval (unauthenticated)
    console.log('\n4. Retrieving event (unauthenticated)...');
    try {
      const getResponse = await axios.get(`${API_BASE_URL}/events/${eventId}`);
      
      console.log('✅ Event retrieved successfully (public access)');
      console.log('Event Title:', getResponse.data.title);
      console.log('Current User Role:', getResponse.data.current_user_role);
    } catch (error) {
      console.error('❌ Failed to retrieve event (unauthenticated)');
      console.error('Error:', error.response?.data || error.message);
    }

    // 5. Test event update
    console.log('\n5. Updating event...');
    try {
      const updateData = {
        title: 'Updated Community Gathering',
        description: 'An updated test event for our community',
        max_capacity: 75
      };
      
      const updateResponse = await axios.put(`${API_BASE_URL}/events/${eventId}`, updateData, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      console.log('✅ Event updated successfully');
      console.log('Updated Title:', updateResponse.data.title);
      console.log('Updated Max Capacity:', updateResponse.data.max_capacity);
    } catch (error) {
      console.error('❌ Failed to update event');
      console.error('Error:', error.response?.data || error.message);
    }

    // 6. Test Stage 1 constraint (should fail for non-free events)
    console.log('\n6. Testing Stage 1 constraint (should fail)...');
    try {
      const invalidEvent = {
        ...testEvent,
        title: 'Paid Event Test',
        pricing_model: 'fixed_price',
        price_fixed: 25.00
      };
      
      await axios.post(`${API_BASE_URL}/events`, invalidEvent, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      console.log('❌ Stage 1 constraint failed - paid event was allowed');
    } catch (error) {
      if (error.response?.status === 400 && 
          error.response.data.message?.includes('free_rsvp')) {
        console.log('✅ Stage 1 constraint working - paid events correctly rejected');
      } else {
        console.error('❌ Unexpected error testing Stage 1 constraint');
        console.error('Error:', error.response?.data || error.message);
      }
    }

    // 7. Test invalid event ID
    console.log('\n7. Testing invalid event ID...');
    try {
      await axios.get(`${API_BASE_URL}/events/invalid-uuid`);
      console.log('❌ Invalid UUID validation failed');
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('✅ Invalid UUID correctly rejected');
      } else {
        console.error('❌ Unexpected error for invalid UUID');
        console.error('Error:', error.response?.data || error.message);
      }
    }

    // 8. Test non-existent event
    console.log('\n8. Testing non-existent event...');
    try {
      await axios.get(`${API_BASE_URL}/events/123e4567-e89b-12d3-a456-426614174000`);
      console.log('❌ Non-existent event should return 404');
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('✅ Non-existent event correctly returns 404');
      } else {
        console.error('❌ Unexpected error for non-existent event');
        console.error('Error:', error.response?.data || error.message);
      }
    }

    console.log('\n🎉 Event endpoint testing completed!');

  } catch (error) {
    console.error('❌ Test suite failed:', error.message);
  }
}

// Check if server is running first
async function checkServer() {
  try {
    await axios.get(`${API_BASE_URL}/`);
    console.log('✅ Server is running\n');
    return true;
  } catch (error) {
    console.error('❌ Server is not running. Please start it with: npm run dev');
    return false;
  }
}

async function main() {
  const serverRunning = await checkServer();
  if (serverRunning) {
    await testEventEndpoints();
  }
}

main();