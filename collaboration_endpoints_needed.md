# Backend Endpoints Needed for Event Collaboration Hub

## Current Situation

The mobile app has implemented the Event Collaboration Hub feature (Screens 8, 10, and 11 from the spec), which allows event hosts to:
1. View and manage their event team (co-hosts and collaborators)
2. Create open positions for their event
3. View and manage applications to those positions

The frontend is fully implemented and trying to make API calls, but the backend endpoints don't exist yet, causing the app to show an infinite loading spinner when users navigate to the collaboration hub.

## Navigation Flow
- From Event Management Screen (Screen 7) → User clicks "Manage Team" → Navigates to `/collaboration/{eventId}` → Attempts to load collaboration data

## Required Endpoints

### 1. Get Event Collaboration Data
**Endpoint:** `GET /api/events/{eventId}/collaboration`

**Purpose:** Retrieve all collaboration data for an event in a single call

**Expected Response:**
```json
{
  "cohosts": [
    {
      "id": "collab_123",
      "user_id": "user_456",
      "username": "john_doe",
      "profile_picture_url": "https://...",
      "role_title": "Event Coordinator",
      "profit_share": 20,
      "is_cohost": true,
      "status": "accepted"
    }
  ],
  "team_members": [
    {
      "id": "collab_789",
      "user_id": "user_012",
      "username": "jane_smith",
      "profile_picture_url": null,
      "role_title": "Photographer",
      "profit_share": 15,
      "is_cohost": false,
      "status": "accepted"
    }
  ],
  "open_positions": [
    {
      "id": "pos_123",
      "role_title": "DJ",
      "description": "Looking for an experienced DJ",
      "profit_share": 10,
      "applicant_count": 3,
      "status": "open",
      "created_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

**Authorization:** User must be the event host or co-host

### 2. Create Open Position
**Endpoint:** `POST /api/events/{eventId}/positions`

**Request Body:**
```json
{
  "role_title": "DJ",
  "description": "Looking for an experienced DJ for our wedding",
  "profit_share": 10
}
```

**Response:** Returns the created position object

### 3. Update Open Position
**Endpoint:** `PUT /api/positions/{positionId}`

**Request Body:**
```json
{
  "role_title": "Updated Title",
  "description": "Updated description",
  "profit_share": 15
}
```

**Response:** Returns the updated position object

### 4. Delete Open Position
**Endpoint:** `DELETE /api/positions/{positionId}`

**Response:** 204 No Content on success

**Error Cases:**
- 409 Conflict if position has applications (cannot delete)

### 5. Get Position Applications
**Endpoint:** `GET /api/positions/{positionId}/applications`

**Response:**
```json
{
  "applications": [
    {
      "id": "app_123",
      "applicant": {
        "user_id": "user_789",
        "username": "applicant_name",
        "profile_picture_url": "https://...",
        "bio": "Experienced DJ with 5 years...",
        "instagram_handle": "@djawesome",
        "website_url": "https://djawesome.com"
      },
      "message": "I'd love to DJ your event! I have experience with...",
      "applied_at": "2024-01-10T15:30:00Z",
      "status": "pending"
    }
  ]
}
```

### 6. Accept Application
**Endpoint:** `POST /api/applications/{applicationId}/accept`

**Response:** Returns success with the created collaborator object

### 7. Decline Application
**Endpoint:** `POST /api/applications/{applicationId}/decline`

**Response:** 204 No Content

## Database Considerations

The backend will need to ensure:
- Only hosts and co-hosts can access these endpoints for their events
- Proper validation of profit share percentages
- Application status tracking (pending/accepted/declined)
- Position status management (open/filled)
- Preventing deletion of positions with active applications

## Current Mobile Implementation

The mobile app expects these endpoints to work as described above. The relevant code is in:
- `lib/features/collaboration/data/services/collaboration_api_service.dart`
- `lib/features/collaboration/data/repositories/collaboration_repository.dart`

Currently, the app is making a real API call to these endpoints, which fail because they don't exist on the backend.

## Testing Note

Once these endpoints are implemented, the collaboration feature flow will be:
1. Host creates an event
2. Host clicks "Manage Team" from the event management screen
3. Host can create open positions
4. Applicants can apply (this happens on the web platform)
5. Host can view applications and accept/decline them
6. Accepted applicants become team members visible in the collaboration hub