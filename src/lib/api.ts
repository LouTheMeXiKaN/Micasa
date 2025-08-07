// src/lib/api.ts
import { EventDetails, UserEventContext, ProposalDetails, User, AuthResponse, ErrorResponse } from '@/types/index';

// Base API URL - should be configured via environment variable in production
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.micasa.events/v1';

// Helper function to get auth token from localStorage/cookies
const getAuthToken = (): string | null => {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('auth_token');
  }
  return null;
};

// Helper function to handle API responses
const handleApiResponse = async <T>(response: Response): Promise<T> => {
  if (!response.ok) {
    const errorData: ErrorResponse = await response.json().catch(() => ({
      error_code: 'UNKNOWN_ERROR',
      message: `HTTP error! status: ${response.status}`
    }));
    throw new Error(errorData.message || `API Error: ${response.status}`);
  }
  return response.json();
};

// Helper function to build headers
const buildHeaders = (includeAuth: boolean = false): HeadersInit => {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
  };
  
  if (includeAuth) {
    const token = getAuthToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
  }
  
  return headers;
};

// --- Authentication & User Context ---

export const getCurrentUser = async (): Promise<User | null> => {
  try {
    const token = getAuthToken();
    if (!token) return null;
    
    const response = await fetch(`${API_BASE_URL}/users/me`, {
      headers: buildHeaders(true),
    });
    
    if (response.status === 401) return null;
    
    return handleApiResponse<User>(response);
  } catch (error) {
    console.error('Error fetching current user:', error);
    return null;
  }
};

// W-1: Fetch Event Details and User Context
export const getEventDetails = async (eventId: string): Promise<{ details: EventDetails, context: UserEventContext }> => {
  try {
    const token = getAuthToken();
    const response = await fetch(`${API_BASE_URL}/events/${eventId}`, {
      headers: buildHeaders(!!token),
    });
    
    const eventData = await handleApiResponse<EventDetails>(response);
    
    // Determine user context based on the response
    // The backend should include current_user_role in the response
    const context: UserEventContext = {
      is_authenticated: !!token,
      role: eventData.current_user_role === 'co-host' ? 'cohost' : 
            (eventData.current_user_role as 'host' | 'collaborator' | 'attendee' | 'public') || 'public',
      has_applied_to_position_ids: [], // This would need a separate API call or be included in response
      rsvp_status: null, // This would need to be included in the response
    };
    
    return { details: eventData, context };
  } catch (error) {
    console.error('Error fetching event details:', error);
    throw error;
  }
};

// --- W-4: Applications ---

// API Endpoint: POST /positions/:position_id/applications
export const submitApplication = async (positionId: string, message: string): Promise<{ success: boolean }> => {
  try {
    const response = await fetch(`${API_BASE_URL}/positions/${positionId}/applications`, {
      method: 'POST',
      headers: buildHeaders(true),
      body: JSON.stringify({ message }),
    });
    
    if (response.status === 409) {
      throw new Error('You have already applied for this position.');
    }
    
    await handleApiResponse(response);
    return { success: true };
  } catch (error) {
    console.error('Error submitting application:', error);
    throw error;
  }
};

// --- W-8 & W-9: Onboarding ---

// API Endpoint: GET /collaborations/:collaborationId (Public details for onboarding context)
export const getProposalDetails = async (proposalId: string): Promise<ProposalDetails> => {
  try {
    const response = await fetch(`${API_BASE_URL}/collaborations/${proposalId}`, {
      headers: buildHeaders(),
    });
    
    return handleApiResponse<ProposalDetails>(response);
  } catch (error) {
    console.error('Error fetching proposal details:', error);
    throw error;
  }
};

// W-8 Step 1: Account Creation
export const createProvisionalAccount = async (
  provider: 'google' | 'apple' | 'email', 
  credentials?: { email: string; password: string }
): Promise<{ userId: string; token: string }> => {
  try {
    let response: Response;
    
    if (provider === 'email' && credentials) {
      // Email/Password registration
      response = await fetch(`${API_BASE_URL}/auth/register`, {
        method: 'POST',
        headers: buildHeaders(),
        body: JSON.stringify(credentials),
      });
    } else {
      // OAuth flow - in production, this would involve redirecting to OAuth provider
      // For now, we'll simulate with a direct API call
      response = await fetch(`${API_BASE_URL}/auth/oauth`, {
        method: 'POST',
        headers: buildHeaders(),
        body: JSON.stringify({ 
          provider,
          // In production, include OAuth token here
          token: 'mock_oauth_token' 
        }),
      });
    }
    
    const authData = await handleApiResponse<AuthResponse>(response);
    
    // Store the token
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', authData.token);
    }
    
    return { 
      userId: authData.user.user_id, 
      token: authData.token 
    };
  } catch (error) {
    console.error('Error creating account:', error);
    throw error;
  }
};

// W-8 Step 2: Send OTP
export const sendOTP = async (phoneNumber: string): Promise<void> => {
  try {
    const response = await fetch(`${API_BASE_URL}/auth/phone/send-otp`, {
      method: 'POST',
      headers: buildHeaders(true),
      body: JSON.stringify({ phone_number: phoneNumber }),
    });
    
    await handleApiResponse(response);
  } catch (error) {
    console.error('Error sending OTP:', error);
    throw error;
  }
};

// W-8 Step 2: Verify OTP, Update Profile, Accept Proposal
export const verifyAndFinalizeOnboarding = async (
  userId: string, 
  proposalId: string, 
  username: string, 
  otp: string
): Promise<{ success: boolean }> => {
  try {
    // Step 1: Verify OTP
    const verifyResponse = await fetch(`${API_BASE_URL}/auth/phone/verify-otp`, {
      method: 'POST',
      headers: buildHeaders(true),
      body: JSON.stringify({ otp }),
    });
    
    await handleApiResponse(verifyResponse);
    
    // Step 2: Update username
    const updateResponse = await fetch(`${API_BASE_URL}/users/me`, {
      method: 'PUT',
      headers: buildHeaders(true),
      body: JSON.stringify({ username }),
    });
    
    await handleApiResponse(updateResponse);
    
    // Step 3: Accept proposal
    const acceptResponse = await fetch(`${API_BASE_URL}/collaborations/${proposalId}/respond`, {
      method: 'POST',
      headers: buildHeaders(true),
      body: JSON.stringify({ action: 'accept' }),
    });
    
    await handleApiResponse(acceptResponse);
    
    return { success: true };
  } catch (error) {
    console.error('Error in verification flow:', error);
    return { success: false };
  }
};

// W-9 / W-4 Step 2: Update Profile (Bio/Avatar)
export const updateProfile = async (
  userId: string, 
  data: { bio?: string, avatarFile?: File }
): Promise<{ success: boolean }> => {
  try {
    // Update bio if provided
    if (data.bio) {
      const response = await fetch(`${API_BASE_URL}/users/me`, {
        method: 'PUT',
        headers: buildHeaders(true),
        body: JSON.stringify({ bio: data.bio }),
      });
      
      await handleApiResponse(response);
    }
    
    // Upload avatar if provided
    if (data.avatarFile) {
      const formData = new FormData();
      formData.append('file', data.avatarFile);
      
      const avatarResponse = await fetch(`${API_BASE_URL}/users/me/avatar`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${getAuthToken()}`,
          // Don't set Content-Type for FormData - browser will set it with boundary
        },
        body: formData,
      });
      
      await handleApiResponse(avatarResponse);
    }
    
    return { success: true };
  } catch (error) {
    console.error('Error updating profile:', error);
    return { success: false };
  }
};

// Additional helper for checking authentication status
export const isAuthenticated = (): boolean => {
  return !!getAuthToken();
};

// Login helper (for existing users)
export const login = async (email: string, password: string): Promise<AuthResponse> => {
  try {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: buildHeaders(),
      body: JSON.stringify({ email, password }),
    });
    
    const authData = await handleApiResponse<AuthResponse>(response);
    
    // Store the token
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', authData.token);
    }
    
    return authData;
  } catch (error) {
    console.error('Error logging in:', error);
    throw error;
  }
};

// Logout helper
export const logout = (): void => {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('auth_token');
  }
};