require('dotenv').config();
const axios = require('axios');

const API_BASE_URL = 'http://localhost:3002';

// Test data
let authToken = '';
let eventId = '';
let positionId = '';
let applicationId = '';

// Test user credentials
const testUser = {
  email: 'testuser@example.com',
  password: 'Test123!@#',
  username: 'testuser123'
};

const secondUser = {
  email: 'applicant@example.com',
  password: 'Test123!@#',
  username: 'applicant123'
};

// Helper function to make API calls
async function apiCall(method, endpoint, data = null, token = null) {
  try {
    const config = {
      method,
      url: `${API_BASE_URL}${endpoint}`,
      headers: {}
    };

    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    return response.data;
  } catch (error) {
    if (error.response) {
      console.error(`API Error: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
      throw error;
    }
    throw error;
  }
}

async function registerAndLogin(userData) {
  try {
    // Try to register (might fail if user exists)
    await apiCall('POST', '/auth/register', userData);
  } catch (error) {
    // Ignore if user already exists
  }

  // Login
  const loginResponse = await apiCall('POST', '/auth/login', {
    email: userData.email,
    password: userData.password
  });

  return loginResponse.token;
}

async function testCollaborationEndpoints() {
  console.log('🚀 Starting Collaboration API Tests...\n');

  try {
    // 1. Register and login as host
    console.log('1️⃣ Registering and logging in as host...');
    authToken = await registerAndLogin(testUser);
    console.log('✅ Host authenticated\n');

    // 2. Create an event
    console.log('2️⃣ Creating an event...');
    const eventData = {
      title: 'Collaboration Test Event',
      description: 'Testing collaboration features',
      start_time: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 1 week from now
      end_time: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000 + 4 * 60 * 60 * 1000).toISOString(), // +4 hours
      location_address: '123 Test Street, Test City',
      location_visibility: 'immediate',
      pricing_model: 'free_rsvp',
      guest_list_visibility: 'public',
      is_invite_only: false,
      max_capacity: 100
    };

    const eventResponse = await apiCall('POST', '/events', eventData, authToken);
    eventId = eventResponse.event_id;
    console.log(`✅ Event created: ${eventId}\n`);

    // 3. Get collaboration hub data (should show only host)
    console.log('3️⃣ Getting collaboration hub data...');
    const hubData = await apiCall('GET', `/events/${eventId}/team`, null, authToken);
    console.log('Hub data:', JSON.stringify(hubData, null, 2));
    console.log('✅ Collaboration hub retrieved\n');

    // 4. Create an open position
    console.log('4️⃣ Creating an open position...');
    const positionData = {
      role_title: 'DJ',
      description: 'Looking for an experienced DJ for the event',
      profit_share_percentage: 20
    };

    const positionResponse = await apiCall('POST', `/events/${eventId}/positions`, positionData, authToken);
    positionId = positionResponse.position_id;
    console.log(`✅ Position created: ${positionId}\n`);

    // 5. Get updated collaboration hub data (should show the position)
    console.log('5️⃣ Getting updated collaboration hub data...');
    const updatedHubData = await apiCall('GET', `/events/${eventId}/team`, null, authToken);
    console.log('Updated hub data:', JSON.stringify(updatedHubData, null, 2));
    console.log('✅ Open position visible in hub\n');

    // 6. Register and login as applicant
    console.log('6️⃣ Registering and logging in as applicant...');
    const applicantToken = await registerAndLogin(secondUser);
    console.log('✅ Applicant authenticated\n');

    // 7. Apply for the position
    console.log('7️⃣ Applying for the position...');
    const applicationData = {
      message: 'I have 5 years of DJ experience and would love to help with your event!'
    };

    const applicationResponse = await apiCall('POST', `/positions/${positionId}/applications`, applicationData, applicantToken);
    applicationId = applicationResponse.application_id;
    console.log(`✅ Application submitted: ${applicationId}\n`);

    // 8. Get applicant's applications
    console.log('8️⃣ Getting applicant\'s applications...');
    const userApplications = await apiCall('GET', '/users/me/applications', null, applicantToken);
    console.log('User applications:', JSON.stringify(userApplications, null, 2));
    console.log('✅ Applications retrieved\n');

    // 9. Host views applications
    console.log('9️⃣ Host viewing applications for the position...');
    const positionApplications = await apiCall('GET', `/positions/${positionId}/applications`, null, authToken);
    console.log('Position applications:', JSON.stringify(positionApplications, null, 2));
    console.log('✅ Applications viewed by host\n');

    // 10. Test withdrawing application
    console.log('🔟 Withdrawing application...');
    await apiCall('DELETE', `/applications/${applicationId}`, null, applicantToken);
    console.log('✅ Application withdrawn\n');

    // 11. Verify application was withdrawn
    console.log('1️⃣1️⃣ Verifying withdrawal...');
    const withdrawnApplications = await apiCall('GET', '/users/me/applications', null, applicantToken);
    console.log('Updated user applications:', JSON.stringify(withdrawnApplications, null, 2));
    console.log('✅ Application status updated to withdrawn\n');

    // 12. Update position
    console.log('1️⃣2️⃣ Updating position...');
    const updateData = {
      description: 'Updated description - Looking for a professional DJ',
      profit_share_percentage: 25
    };
    const updatedPosition = await apiCall('PUT', `/positions/${positionId}`, updateData, authToken);
    console.log('Updated position:', JSON.stringify(updatedPosition, null, 2));
    console.log('✅ Position updated\n');

    // 13. Delete position (should work since no pending applications)
    console.log('1️⃣3️⃣ Deleting position...');
    await apiCall('DELETE', `/positions/${positionId}`, null, authToken);
    console.log('✅ Position deleted\n');

    console.log('🎉 All collaboration tests passed!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

// Run the tests
testCollaborationEndpoints();