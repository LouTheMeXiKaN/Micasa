openapi: 3.0.0  
info:  
title: Micasa MVP API Contract  
version: 1.4.0  
description: \>  
The backbone API for the Micasa platform, supporting mobile and web clients.  
v1.1.0 Changelog:  
\- Augmented UserProfile schema with detailed privacy settings.  
v1.2.0 Changelog:  
\- Augmented Event endpoints with detailed response schemas for real-time stats and post-event promotional impact.  
v1.3.0 Changelog:  
\- Added detailed response schemas for Collaboration and Application endpoints.  
v1.4.0 Changelog:  
\- Added standardized ErrorResponse schema and defined specific error cases for critical business logic (e.g., duplicate applications).  
servers:

* url: https://api.micasa.events/v1

components:  
securitySchemes:  
BearerAuth:  
type: http  
scheme: bearer  
bearerFormat: JWT

# **\=======================================**

# **API Endpoints (Paths)**

# **\=======================================**

paths:

# **\---------------------------------------**

# **1\. Authentication**

# **\---------------------------------------**

/auth/register:  
post:  
summary: Register a new user (Email/Password)  
tags: \[Auth\]  
responses:  
'201':  
description: User successfully registered.  
'409':  
description: Username or email is already taken.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
/auth/login:  
post:  
summary: Log in (Email/Password)  
tags: \[Auth\]  
/auth/oauth:  
post:  
summary: Authenticate via OAuth (Google/Apple)  
tags: \[Auth\]  
/auth/phone/send-otp:  
post:  
summary: Send OTP for phone verification  
tags: \[Auth\]  
security: \[{ BearerAuth: \[\] }\]  
/auth/phone/verify-otp:  
post:  
summary: Verify OTP and confirm phone number  
tags: \[Auth\]  
security: \[{ BearerAuth: \[\] }\]

# **\---------------------------------------**

# **2\. User Profile & Management**

# **\---------------------------------------**

/users/me:  
get:  
summary: Get authenticated user's profile  
tags: \[Users\]  
security: \[{ BearerAuth: \[\] }\]  
responses:  
'200':  
description: OK  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/UserProfile'  
'401':  
$ref: '\#/components/responses/UnauthorizedError'  
put:  
  summary: Update authenticated user's profile  
  tags: \[Users\]  
  security: \[{ BearerAuth: \[\] }\]  
  requestBody:  
    content:  
      application/json:  
        schema:  
          $ref: '\#/components/schemas/UserProfileUpdate'  
  responses:  
    '200':  
      description: Profile updated successfully.  
      content:  
        application/json:  
          schema:  
            $ref: '\#/components/schemas/UserProfile'  
    '401':  
      $ref: '\#/components/responses/UnauthorizedError'

/users/{userId}:  
get:  
summary: Get public profile of a user  
tags: \[Users\]  
/users/me/avatar:  
post:  
summary: Upload profile picture  
tags: \[Users\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
multipart/form-data:  
schema:  
type: object  
properties:  
file: { type: string, format: binary }

# **\---------------------------------------**

# **3\. Events (Creation & Management)**

# **\---------------------------------------**

/events:  
post:  
summary: Create a new event  
tags: \[Events\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/EventCreateInput'  
responses:  
'201': { description: Event created }  
'401':  
$ref: '\#/components/responses/UnauthorizedError'  
/events/{eventId}:  
get:  
summary: Get event details  
tags: \[Events\]  
responses:  
'200':  
description: Detailed information about the event.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/EventDetails'  
'404':  
$ref: '\#/components/responses/NotFoundError'  
put:  
  summary: Update event details (Host only)  
  tags: \[Events\]  
  security: \[{ BearerAuth: \[\] }\]

/events/{eventId}/cancel:  
post:  
summary: Cancel an event (Host only)  
tags: \[Events\]  
security: \[{ BearerAuth: \[\] }\]  
/events/{eventId}/broadcast:  
post:  
summary: Send a message to all guests (Host/Co-host)  
tags: \[Events, Communication\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
type: object  
properties:  
message: { type: string }  
include\_maybes: { type: boolean, default: false }  
/events/{eventId}/guests:  
get:  
summary: Get the guest list  
tags: \[Events, Guests\]  
security: \[{ BearerAuth: \[\] }\]

# **\---------------------------------------**

# **4\. My Events (Dashboard & Hub)**

# **\---------------------------------------**

/me/events:  
get:  
summary: Get events for the authenticated user  
tags: \[My Events\]  
security: \[{ BearerAuth: \[\] }\]  
parameters:  
\- name: filter  
in: query  
required: true  
schema:  
type: string  
enum: \[pending, upcoming, past\]  
/me/dashboard:  
get:  
summary: Get dashboard data  
tags: \[My Events\]  
security: \[{ BearerAuth: \[\] }\]

# **\---------------------------------------**

# **5\. Collaboration & Team Management**

# **\---------------------------------------**

/events/{eventId}/team:  
get:  
summary: Get the event collaboration hub data (Screen 8\)  
tags: \[Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
responses:  
'200':  
description: A structured object containing the full team, pending proposals, and open positions.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/EventTeamHub'  
'401':  
$ref: '\#/components/responses/UnauthorizedError'  
'403':  
$ref: '\#/components/responses/ForbiddenError'  
/events/{eventId}/team/invite:  
post:  
summary: Send a collaboration proposal (Host/Co-host)  
tags: \[Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/CollaborationInvite'  
/collaborations/{collaborationId}:  
get:  
summary: Get proposal details (Screen 12.1)  
tags: \[Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
/collaborations/{collaborationId}/respond:  
post:  
summary: Accept or Decline a proposal  
tags: \[Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
type: object  
properties:  
action: { type: string, enum: \[accept, decline\] }

# **\---------------------------------------**

# **6\. Open Positions & Applications**

# **\---------------------------------------**

/events/{eventId}/positions:  
post:  
summary: Create an open position (Host/Co-host)  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]  
/positions/{positionId}:  
put: { summary: Edit position, tags: \[Applications\], security: \[{ BearerAuth: \[\] }\] }  
delete:  
summary: Delete position  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]  
responses:  
'204':  
description: Position successfully deleted.  
'409':  
description: Cannot delete a position that has existing applications.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
/positions/{positionId}/applications:  
get:  
summary: List applications for a position (Screen 10\)  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]  
responses:  
'200':  
description: A list of applicants with their profile and message.  
content:  
application/json:  
schema:  
type: array  
items:  
$ref: '\#/components/schemas/Applicant'  
post:  
summary: Apply for a position (W-4)  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
properties:  
message: { type: string }  
responses:  
'201':  
description: Application submitted successfully.  
'409':  
description: Returned if the user has already applied for this position.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
/applications/{applicationId}/manage:  
post:  
summary: Accept or Decline an application (Host/Co-host)  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
properties:  
action: { type: string, enum: \[accept, decline\] }  
/applications/{applicationId}/withdraw:  
post:  
summary: Withdraw application (Applicant)  
tags: \[Applications\]  
security: \[{ BearerAuth: \[\] }\]

# **\---------------------------------------**

# **7\. Ticketing, RSVP, and Check-in**

# **\---------------------------------------**

/events/{eventId}/checkout:  
post:  
summary: Purchase ticket or RSVP  
tags: \[Ticketing\]  
requestBody:  
content:  
application/json:  
schema:  
type: object  
properties:  
amount\_paid: { type: number }  
rsvp\_status: { type: string, enum: \[going, maybe\] }  
referrer\_user\_id: { type: string, format: uuid, nullable: true }  
invitation\_id: { type: string, format: uuid, nullable: true }  
/tickets/{ticketId}/rsvp:  
put:  
summary: Update RSVP status  
tags: \[Ticketing\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
properties:  
rsvp\_status: { type: string, enum: \[going, maybe, not\_going\] }  
/tickets/{ticketId}/check-in:  
post:  
summary: Check a guest in  
tags: \[Ticketing\]  
security: \[{ BearerAuth: \[\] }\]

# **\---------------------------------------**

# **8\. Community & Social Graph**

# **\---------------------------------------**

/me/community:  
get:  
summary: Get the user's contact list  
tags: \[Community\]  
security: \[{ BearerAuth: \[\] }\]  
parameters:  
\- name: view  
in: query  
schema:  
type: string  
enum: \[all, by\_event\]  
default: all  
post:  
  summary: Add a contact  
  tags: \[Community\]  
  security: \[{ BearerAuth: \[\] }\]

/events/{eventId}/import-guests-to-community:  
post:  
summary: Bulk import guests from an event  
tags: \[Community\]  
security: \[{ BearerAuth: \[\] }\]  
/me/community/import:  
post:  
summary: Bulk import contacts  
tags: \[Community\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
required: true  
content:  
application/json:  
schema:  
type: object  
properties:  
contacts:  
type: array  
items:  
type: object  
properties:  
display\_name: { type: string }  
phone\_number: { type: string }  
responses:  
'201':  
description: Contacts successfully imported.

# **\---------------------------------------**

# **9\. Financials & Payouts**

# **\---------------------------------------**

/me/payout-account/onboarding-token:  
post:  
summary: Get single-use token for Hyperwallet onboarding  
tags: \[Financial\]  
security: \[{ BearerAuth: \[\] }\]  
/me/earnings:  
get:  
summary: Get user's earnings history  
tags: \[Financial\]  
security: \[{ BearerAuth: \[\] }\]  
/events/{eventId}/settlement:  
get:  
summary: Get the settlement preview (Host only)  
tags: \[Financial, Events\]  
security: \[{ BearerAuth: \[\] }\]  
post:  
  summary: Confirm and trigger payouts (Host only)  
  tags: \[Financial, Events\]  
  security: \[{ BearerAuth: \[\] }\]

/collaborations/{collaborationId}/remove-request:  
post:  
summary: Host requests removal of a collaborator post-event  
tags: \[Financial, Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
/collaborations/{collaborationId}/remove-response:  
post:  
summary: Collaborator approves or disputes removal  
tags: \[Financial, Collaboration\]  
security: \[{ BearerAuth: \[\] }\]  
requestBody:  
content:  
application/json:  
schema:  
properties:  
action: { type: string, enum: \[approve, dispute\] }  
dispute\_reason: { type: string, nullable: true }

# **\---------------------------------------**

# **10\. Post-Event Experience**

# **\---------------------------------------**

/events/{eventId}/summary:  
get:  
summary: Get the post-event summary  
tags: \[Events\]  
security: \[{ BearerAuth: \[\] }\]  
responses:  
'200':  
description: A comprehensive summary of the event's outcome.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/EventSummary'

# **\---------------------------------------**

# **11\. Notifications**

# **\---------------------------------------**

/me/notifications:  
get:  
summary: Get user's notifications  
tags: \[Notifications\]  
security: \[{ BearerAuth: \[\] }\]  
/notifications/{notificationId}/read:  
post:  
summary: Mark a notification as read  
tags: \[Notifications\]  
security: \[{ BearerAuth: \[\] }\]  
parameters:  
\- name: notificationId  
in: path  
required: true  
schema:  
type: string  
format: uuid  
responses:  
'204':  
description: No Content.

# **\---------------------------------------**

# **12\. Webhooks (Internal)**

# **\---------------------------------------**

/webhooks/{source}:  
post:  
summary: Receive webhook callbacks  
tags: \[Webhooks\]  
parameters:  
\- name: source  
in: path  
required: true  
schema:  
type: string  
enum: \[stripe, hyperwallet\]  
requestBody:  
required: true  
content:  
application/json: {}  
responses:  
'200':  
description: Webhook received.

# **\=======================================**

# **SCHEMAS & RESPONSES**

# **\=======================================**

components:

# **\--- Standardized Reusable Responses \---**

responses:  
UnauthorizedError:  
description: Authentication information is missing or invalid.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
ForbiddenError:  
description: Authenticated user does not have permission to perform this action.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
NotFoundError:  
description: The requested resource could not be found.  
content:  
application/json:  
schema:  
$ref: '\#/components/schemas/ErrorResponse'  
schemas:  
\# \--- START: Standardized Error Schema v1.4 \---  
ErrorResponse:  
type: object  
required:  
\- error\_code  
\- message  
properties:  
error\_code:  
type: string  
description: A machine-readable error code.  
example: 'RESOURCE\_NOT\_FOUND'  
message:  
type: string  
description: A human-readable description of the error.  
example: 'The requested event could not be found.'  
details:  
type: object  
description: Optional structured data for validation errors.  
\# \--- END: Standardized Error Schema v1.4 \---  
\# \--- User Schemas \---  
UserProfile:  
  type: object  
  properties:  
    user\_id: { type: string, format: uuid, readOnly: true }  
    email: { type: string, format: email, readOnly: true }  
    username: { type: string }  
    phone\_number: { type: string }  
    is\_phone\_verified: { type: boolean, readOnly: true }  
    profile\_picture\_url: { type: string, format: uri, nullable: true }  
    bio: { type: string, nullable: true }  
    instagram\_handle: { type: string, nullable: true }  
    personal\_website\_url: { type: string, format: uri, nullable: true }  
    has\_hyperwallet\_account: { type: boolean, readOnly: true }  
    is\_username\_autogenerated: { type: boolean, readOnly: true }  
    privacy\_show\_upcoming\_events: { type: boolean, default: true }  
    privacy\_show\_past\_events: { type: boolean, default: true }  
    privacy\_past\_events\_include\_hosted: { type: boolean, default: true }  
    privacy\_past\_events\_include\_collaborated: { type: boolean, default: true }  
    privacy\_past\_events\_include\_attended: { type: boolean, default: true }

UserProfileUpdate:  
  type: object  
  properties:  
    username: { type: string }  
    phone\_number: { type: string }  
    profile\_picture\_url: { type: string, format: uri, nullable: true }  
    bio: { type: string, nullable: true }  
    instagram\_handle: { type: string, nullable: true }  
    personal\_website\_url: { type: string, format: uri, nullable: true }  
    privacy\_show\_upcoming\_events: { type: boolean }  
    privacy\_show\_past\_events: { type: boolean }  
    privacy\_past\_events\_include\_hosted: { type: boolean }  
    privacy\_past\_events\_include\_collaborated: { type: boolean }  
    privacy\_past\_events\_include\_attended: { type: boolean }

\# \--- Event Schemas \---  
EventCreateInput:  
  type: object  
  properties:  
    title: { type: string }  
    start\_time: { type: string, format: date-time }  
    end\_time: { type: string, format: date-time }  
    location\_address: { type: string }  
    location\_visibility: { type: string, enum: \[immediate, confirmed\_guests, 24\_hours\_before\] }  
    pricing\_model: { type: string, enum: \[fixed\_price, choose\_your\_price, donation\_based, free\_rsvp\] }  
    price\_fixed: { type: number, nullable: true }  
    guest\_list\_visibility: { type: string, enum: \[public, attendees\_live, private\] }  
    is\_invite\_only: { type: boolean }

EventStats:  
  type: object  
  properties:  
    registered\_count: { type: integer }  
    maybe\_count: { type: integer }  
    team\_size: { type: integer }  
    gross\_revenue: { type: number, format: float }

EventDetails:  
  type: object  
  allOf:  
    \- $ref: '\#/components/schemas/EventCreateInput'  
  properties:  
    event\_id: { type: string, format: uuid, readOnly: true }  
    host\_user\_id: { type: string, format: uuid, readOnly: true }  
    status: { type: string, enum: \[draft, published, live, completed, cancelled\], readOnly: true }  
    stats:  
      $ref: '\#/components/schemas/EventStats'  
    current\_user\_role:  
      type: string  
      enum: \[host, co-host, collaborator, attendee, none\]

PromotionalImpactItem:  
  type: object  
  properties:  
    user\_id: { type: string, format: uuid }  
    username: { type: string }  
    role\_title: { type: string }  
    attendees\_brought: { type: integer }  
    revenue\_generated: { type: number, format: float }

PayoutItem:  
  type: object  
  properties:  
    user\_id: { type: string, format: uuid }  
    username: { type: string }  
    role\_title: { type: string }  
    payout\_amount: { type: number, format: float, nullable: true }

FinancialSummary:  
  type: object  
  properties:  
    gross\_revenue: { type: number, format: float }  
    total\_fees: { type: number, format: float }  
    net\_payout: { type: number, format: float }  
    payouts:  
      type: array  
      items:  
        $ref: '\#/components/schemas/PayoutItem'

SnapshotMetrics:  
  type: object  
  properties:  
    attendee\_count: { type: integer }  
    contributor\_count: { type: integer }

EventSummary:  
  type: object  
  properties:  
    event\_id: { type: string, format: uuid }  
    title: { type: string }  
    start\_time: { type: string, format: date-time }  
    financial\_summary:  
      $ref: '\#/components/schemas/FinancialSummary'  
      nullable: true  
    creative\_team:  
      type: array  
      items:  
        type: object  
        properties:  
          user\_id: { type: string, format: uuid }  
          username: { type: string }  
          role\_title: { type: string }  
    promotional\_impact:  
      type: array  
      items:  
        $ref: '\#/components/schemas/PromotionalImpactItem'  
    snapshot\_metrics:  
      $ref: '\#/components/schemas/SnapshotMetrics'  
      nullable: true

\# \--- Collaboration & Application Schemas \---  
CollaborationInvite:  
  type: object  
  properties:  
    identifier: { type: string, description: "Can be user\_id or phone\_number" }  
    role\_title: { type: string, maxLength: 30 }  
    profit\_share\_percentage: { type: number }  
    is\_cohost: { type: boolean }  
    message: { type: string }

Applicant:  
  type: object  
  properties:  
    application\_id: { type: string, format: uuid }  
    application\_date: { type: string, format: date-time }  
    message: { type: string }  
    user\_info:  
      type: object  
      properties:  
        user\_id: { type: string, format: uuid }  
        username: { type: string }  
        profile\_picture\_url: { type: string, format: uri, nullable: true }  
        bio: { type: string, nullable: true }  
        instagram\_handle: { type: string, nullable: true }  
        personal\_website\_url: { type: string, format: uri, nullable: true }

TeamMember:  
  type: object  
  properties:  
    user\_id: { type: string, format: uuid }  
    username: { type: string }  
    profile\_picture\_url: { type: string, format: uri, nullable: true }  
    role\_title: { type: string }  
    is\_cohost: { type: boolean }  
    profit\_share\_percentage: { type: number }

PendingProposal:  
  type: object  
  properties:  
    collaboration\_id: { type: string, format: uuid }  
    user\_id: { type: string, format: uuid }  
    username: { type: string }  
    role\_title: { type: string }  
    is\_cohost: { type: boolean }  
    profit\_share\_percentage: { type: number }

OpenPositionSummary:  
  type: object  
  properties:  
    position\_id: { type: string, format: uuid }  
    role\_title: { type: string }  
    profit\_share\_percentage: { type: number, nullable: true }  
    applicant\_count: { type: integer }

EventTeamHub:  
  type: object  
  properties:  
    confirmed\_team:  
      type: array  
      items:  
        $ref: '\#/components/schemas/TeamMember'  
    pending\_proposals:  
      type: array  
      items:  
        $ref: '\#/components/schemas/PendingProposal'  
    open\_positions:  
      type: array  
      items:  
        $ref: '\#/components/schemas/OpenPositionSummary'  
