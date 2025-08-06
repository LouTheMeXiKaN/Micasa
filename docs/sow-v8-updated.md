# Micasa Relaunch MVP - Scope of Work (SOW)
**Document Version: 8.0**
**Status: Current with Latest Screen List Updates**
**Last Updated: December 2024**

## 1. Executive Summary & Guiding Principles

This document outlines the complete scope of work for the Minimum Viable Product (MVP) relaunch of the Micasa platform. The objective is to launch a lean, stable, and strategically-focused product that validates our core "steel thread": enabling creators to easily collaborate on events and share revenue transparently.

The development will be guided by these key principles:
* **The "Steel Thread"**: A relentless focus on the core user journey of creating, collaborating on, and monetizing events
* **Just-in-Time Friction**: User friction (e.g., account creation, profile completion, payout onboarding) is deferred until the moment of highest user intent
* **Creator Empowerment**: The platform provides maximum flexibility and control to the host, particularly through robust event creation controls
* **Hybrid Web/App Model**: The guest experience is web-first for frictionless sharing, while creator tools are housed in the mobile app
* **Dynamic Social Graph**: The platform transforms static contact lists into living records of shared event experiences, facilitating post-event networking and community building
* **Progressive Profile Completion**: A tiered system ensures users provide necessary information at contextually appropriate moments
* **Collaborative Attribution**: The platform tracks and celebrates the full creative team's contributions, both financial and social
* **Transparent Team Economics**: All team members can see the full profit share breakdown, promoting trust and fairness

## 2. Web Platform Scope (events.micasa.events)

The web platform is designed for the guest experience and the frictionless onboarding of new collaborators. It must be fast, responsive, and transactional.

### Part 2.1: Guest Experience
* **Screen W-1: Public Event Page**: Display all public information for events with:
  * **Event Team Display**: Shows complete creative team (Host, Co-hosts, Collaborators) with profile pictures, names, and role badges
  * **"Who's Going" Attendee Display**: Dynamic visibility based on three-tier system:
    * **Public**: Always visible to everyone ("Jane, John, and 23 others are going")
    * **Attendees Live**: Hidden to non-attendees; shows count pre-event, full display during/after for attendees
    * **Private**: Hidden to all except hosts and co-hosts
  * **Invitation Context Recognition**: 
    * Detect and preserve invitation_id URL parameter
    * Display personalized invitation banner with host attribution
    * Track invitation-to-purchase conversion separately from general referrals
    * Maintain full parameter chain: `?invitation_id={id}&ref={inviter_user_id}`
  * Referral parameter capture (?ref=[user_id]) for attribution tracking
  * Open positions section with role titles and dynamic button states
* **Screen W-2: Conditional Checkout & RSVP Flow**: Handle guest actions based on event pricing model:
  * Flow A: Direct payment for fixed price or choose-your-price events
  * Flow B: RSVP first with optional donation for donation-based events
  * Confirmation messages acknowledge referral sources when applicable
  * **Enhanced confirmation messages based on guest list visibility:**
    * If arrived via referral: "Thanks to [Referrer Name] for sharing this event! 🎉"
    * If "attendees_live" pre-event: "You're in! The guest list will unlock when the event begins."
    * If "attendees_live" during/post: "You're in! Check out who else is attending!"

### Part 2.2: Collaborator Onboarding
* **Screen W-3: Proposal Acceptance Page**: Private URL for invited collaborators to review and accept/decline proposals with:
  * Clear role indication for co-host invitations
  * Profit share percentage display
  * Additional context for co-host privileges ("Co-hosts can manage guests, invite team members, and more!")
* **Screen W-4: Open Position Application Form**: Multi-step form for applying to open positions with:
  * **Duplicate Application Prevention**:
    * System verifies if user has already applied before showing form
    * Display "Already Applied" state with redirection options
    * Button states reflect application status (Apply/Applied ✓/Position Filled)
* **Screen W-5: App Funnel/Success Page**: Post-action confirmation encouraging mobile app download
* **Screen W-6: Hyperwallet Onboarding Modal**: Embedded payout setup for first-time paid collaborators
* **Screen W-7: Public User Profile Page**: Display public user information with:
  * Basic profile information (photo, username, bio, social links)
  * **"Upcoming Events" Section**: Shows future public events where user is host/collaborator
  * **"Past Events" Section**: Shows history of public events where user was host/collaborator/attendee (privacy-controlled)
* **Screen W-8: Web Collaborator Onboarding Gate**: Two-step mandatory flow for new collaborators:
  * Step 1: Account creation (social or email)
  * Step 2: Username selection and phone verification (OTP)
  * Co-host specific messaging when applicable ("Welcome to the team! As a co-host, you'll have access to guest management tools...")
* **Screen W-9: Profile Augmentation Nudge**: Optional prompt for adding profile photo and bio

### Part 2.3: Post-Event Summaries (Future Enhancement)
* **Public Event Summary Pages**: Read-only pages showing non-sensitive event highlights, accessible from user profiles (post-MVP fast-follow)

## 3. Mobile Application Scope (iOS & Android via Flutter)

The mobile app serves as the primary platform for creators (Hosts and Co-hosts).

### Part 3.1: Core User Management & Authentication
* **Authentication System**:
  * Email/password registration and login
  * Google and Apple OAuth integration
  * Password reset functionality
  * JWT-based session management
* **Profile Management**:
  * Screen 25: Mandatory Profile Initialization Gate (blocks app access until username/phone provided)
  * Screen 22: Context-aware profile completion prompts (pre/post-action models)
  * Profile editing with photo upload, bio, social links
  * Public profile view with "Upcoming Events" and "Past Events" sections
  * Privacy controls for event visibility:
    * Toggle for showing upcoming events
    * Toggle for showing past events
    * Granular controls for past events (hosted/collaborated/attended)

### Part 3.2: Event Creation & Management
* **Event Creation Flow**:
  * Two-step creation process (What & Where, then Rules & How)
  * Image upload for cover photos
  * Location privacy controls (immediate, on confirmation, 24 hours before)
  * **Three-tier guest list visibility system**:
    * Public: Everyone can see who's attending (creates FOMO)
    * Attendees Live: Only ticket holders see full list during/after event
    * Private: Only hosts and co-hosts can see
  * Event privacy toggle (public vs invite-only)
  * Four pricing models: Fixed Price, Choose Your Price, Donation Based, Free RSVP
  * Optional capacity limits
  * **Free RSVP and Donation-Based events support**: Going/Maybe/Not Going responses
* **Dynamic Event Management Screen**:
  * **Role-based access control**:
    * Hosts: Full access to all features
    * Co-hosts: All features except [Edit Details], [Confirm Payouts], and [Cancel Event]
  * Pre-Event actions organized in three groups:
    * **Promotion & Discovery**: Preview, Share (with auto referral), QR codes, Invite
    * **Operations & Guest Management**: Guest list, donation QR (conditional), messaging
    * **Core Administration**: Team management, edit details (host only), cancel (host only)
  * Live-Event: Guest check-in with support for Going/Maybe attendees
  * Post-Event: Financial summary, payout triggering, access to celebration screens
  * **Event Stats Section**: Real-time metrics including registration, team size, revenue

### Part 3.3: Enhanced Navigation & Information Architecture
* **Refined Navigation Structure**:
  * **Dashboard ("Home" Tab)**: Lean, forward-looking command center with:
    * **Enhanced Smart Link Navigation**:
      * Single proposal → Direct navigation to new Proposal Details screen (Screen 12.1)
      * Single application → Navigation to My Events (Pending tab)
      * Multiple items → Navigation to My Events (Pending tab)
      * Differentiate between proposal and application items in navigation logic
    * Time-sensitive CTAs for events needing attention
    * Upcoming event previews with role badges and promotional stats
  * **"My Events" Hub**: Comprehensive event filing system with Pending | Upcoming | Past tabs
  * **"My Community" Tab**: Contact management with event-based grouping
  * **Profile Tab**: Account settings and earnings

### Part 3.4: Community & Social Features
* **Enhanced "My Community" Management**:
  * Toggle between "All Contacts" and "Group by Event" views
  * Event frames showing all events where user was present (as host, collaborator, or attendee)
  * Manual contact addition and phone contact import
  * Automatic event association tracking
  * Contact profiles linked to Micasa users when matched
  * Bulk import from guest lists with duplicate detection
* **Event-Based Invitation System**:
  * Invite guests and collaborators using event-grouped interface
  * SMS-based invitations with templated messages
  * **Automatic referral parameter inclusion in all shared links**
  * UI hints about referral tracking ("Your referral link - track your impact!")
* **Guest List Features**:
  * Import to My Community button (respecting visibility rules)
  * Check-in functionality for hosts and co-hosts
  * Post-event networking notifications
  * **Support for Free RSVP events**: Separate sections for "Going" and "Maybe" attendees
* **My Invitations Screen Enhancement**:
  * **In-App Browser Integration**:
    * All invitations open in native in-app browser
    * Preserved invitation context through URL parameters
    * Native "Done" button for easy return to app
    * Maintains app state in background during web interaction

### Part 3.5: Collaboration System
* **Screen 12.1: Proposal Details** (New):
  * **Purpose**: Dedicated view for collaboration proposals with full context
  * **Features**:
    * Complete proposal information including host's message
    * Full event details and team overview
    * Role-specific information and profit share transparency
    * Co-host privilege explanation when applicable
    * Accept/Decline actions with appropriate flows
  * **Navigation**: 
    * Accessed from pending proposal cards and single-item Smart Links
    * Integrates with Hyperwallet flow for first-time paid collaborations
#### Role Hierarchy
* **Hosts**: Primary event organizers with full control.
* **Co-hosts**: Elevated collaborators with management privileges.
* **Collaborators**: Regular team members focused on their specific role.
* **Open Positions**:
  * Create positions with role title (30 char limit), description, and optional profit share
  * Application management with accept/decline
  * Edit/delete positions (restricted if applications exist)
  * Status tracking (open/filled)
* **Direct Invitations**:
  * Invite from community with profit share proposal
  * **Co-host privilege toggle**: Grants additional permissions and acknowledges in messaging
  * SMS delivery to non-users with web onboarding link
  * Context-aware collaborator selection from profiles
  * **Role/Title field**: Required 30-character field for custom role designation
* **Profit Share Transparency**:
  * All team members can see everyone's profit share percentages
  * Visible in collaboration hub and event views
  * Promotes trust and fairness within teams
* **Enhanced "My Events" Hub**:
  * **Pending Tab Improvements**:
    * Rich proposal cards with host info, role, profit share, message indicator, and co-host badge
    * Application cards with position details, application date, and withdrawal option
    * Quick actions (Accept/Decline/Withdraw) directly from list
    * Card body navigation to appropriate detail views
  * Upcoming events management based on role
  * Past events with permanent access to post-event summaries
  * Removal request handling with dispute option

### Part 3.6: Post-Event Experience Engine
* **Social Settlement Screen (Monetized Events)**:
  * **Role-based financial visibility**:
    * Hosts/Co-hosts: See full financial breakdown and all payout amounts
    * Team Members: See gross revenue and their own payout (others' amounts hidden)
    * Attendees: No financial data access
  * Celebratory design with shareable format
  * **Team Promotional Impact section**: Shows referral effectiveness for all team members
  * Full Creative Team showcase (paid and unpaid contributors)
  * Payout nudge for hosts who haven't triggered distribution
  * Export functionality for detailed reports (host/co-host only)
* **Collaborative Snapshot Screen (Free Events)**:
  * Celebratory headline emphasizing community impact
  * Impact Metrics: Attendee count, performer count, other relevant metrics
  * Creative Team showcase
  * Team reach metrics without monetary values
  * Export guest list functionality (host/co-host only)

### Part 3.7: Financial Management
* **Payment Collection**:
  * Stripe integration for all payment types
  * Automatic ticket/donation creation with referrer tracking
  * Transaction fee tracking
* **Payout System**:
  * Hyperwallet integration (JIT onboarding)
  * Host-triggered settlement process
  * **Transparent payout summaries with role-based visibility**
  * Collaborator removal requests with 24-hour response window
  * Dispute mechanism freezing payouts
  * My Earnings dashboard with CSV export
* **Settlement Flow**:
  * Two-stage process: Stripe → Hyperwallet → Collaborators
  * Financial summary before settlement
  * Platform fee and Stripe fee deduction
  * Net revenue distribution based on profit shares

### Part 3.8: Communication Features
* **Push Notifications**:
  * New proposals and applications
  * Event updates and reminders
  * Post-event guest list access
  * Post-event summary availability
  * Payout status updates
  * Referral milestone achievements
  * Proposal message delivery in pending items
  * Application withdrawal notifications to hosts
* **Messaging**:
  * Broadcast messages to all guests
  * SMS/Email delivery based on available contact info
  * Auto-generated email subjects
  * Co-host messaging privileges
  * **Free RSVP event support**: Option to include "Maybe" respondents

## 4. Backend & Infrastructure

### Core Services & Integrations
* **Payment Processing**: 
  * Stripe (manual payout mode)
  * Hyperwallet for collaborator distributions
  * Webhook handling for both services
* **Communications**:
  * SMS service (Twilio) for invitations with referral tracking
  * Email service (SendGrid) for transactional emails
  * Push notification service for mobile apps
* **Storage & Media**:
  * Cloud storage for profile photos and event images
  * CDN for media delivery
* **Analytics & Attribution**:
  * Comprehensive referral tracking system
  * Promotional impact calculation engine
  * Team contribution analytics
  * Invitation attribution tracking

### Database Architecture
* **Core Entities**: Users, Events, Collaborations, Tickets, Transactions, Payouts
* **Role Management**: Host, Co-host, Team Member, Attendee tracking
* **Social Graph**: Contacts, Contact-Event Associations
* **Financial Tracking**: Stripe balance transactions, Event settlements, Hyperwallet payments
* **Attribution**: Referral tracking, Promotional impact metrics, Team contribution data, Invitation conversions
* **Privacy Settings**: 
  * Guest list visibility (public/attendees_live/private)
  * Profile event display toggles (upcoming/past)
  * Granular past event controls (hosted/collaborated/attended)
* **Application Tracking**: 
  * Unique constraint on user_id + position_id to prevent duplicates
  * Application status tracking (pending/withdrawn/accepted/rejected)
  * Timestamp tracking for application actions
* **RSVP Support**: Going/Maybe/Not Going status for free events
* **Supporting Tables**: Open positions, Invitations, Notifications, Webhook events

### Background Jobs & Automation
* **Event Association Creation**: Automatically links contacts when they attend events together
* **Post-Event Notifications**: Sends guest list access notifications 1-2 hours after event ends
* **Post-Event Summary Generation**: Creates social settlement or collaborative snapshot data
* **Association Repair Job**: Ensures data consistency for event-contact relationships
* **Settlement Processing**: Manages the multi-stage payout flow
* **Webhook Processing**: Handles asynchronous payment status updates
* **Attribution Processing**: Calculates promotional impact metrics for team members
* **Co-host Permission Sync**: Ensures co-host privileges are properly reflected
* **Application State Sync**: Ensure button states reflect current application status
* **Invitation Expiry**: Handle expired invitations gracefully

## 5. Business Logic & Rules

### Event Management
* **Pricing Independence**: Pricing model and privacy settings operate independently
* **Edit Restrictions**: 
  * Financial details locked after first sale
  * Major changes trigger notifications
  * Co-hosts cannot edit core event details
* **Cancellation**: 
  * Available anytime before event ends (hosts only)
  * Automatic refunds processed
#### Guest List Visibility Tiers
* **Public**: Always visible to everyone (default for FOMO).
* **Attendees Live**:
    * Non-attendees: Cannot see any guest information.
    * Attendees pre-event: See count only.
    * Attendees during/after: See full guest list.
    * **Team Members (Hosts, Co-hosts, Collaborators): Always see the full list, bypassing all restrictions.**
* **Private**: Only hosts and co-hosts can access.
* **Post-Event Access**: All participants maintain permanent access to event summaries

* **Free RSVP Events**: Support Going/Maybe/Not Going responses with separate tracking

### Collaboration Rules
* **Role Hierarchy**:
  * **Host**: Full control over event and team
  * **Co-host**: Can invite guests, manage team, check in attendees, view full financials
  * **Team Member**: Focus on their role, limited financial visibility
* **Profit Share**: 
  * Set at invitation, locked after acceptance
  * **Full transparency**: All team members see everyone's percentages
* **Attribution**: 
  * All team members automatically receive unique referral links
  * Promotional impact tracked and celebrated post-event
  * UI hints guide users to share with tracking
* **Removal Process**:
  * Host-initiated only (pre or post-event)
  * 24-hour response window for collaborator
  * Auto-approval if no response
  * Disputes freeze all event payouts
* **Open Position Management**:
  * Cannot delete positions with active applications
  * Positions marked "filled" when accepted
  * Role titles limited to 30 characters
* **Application Management**:
  * One application per user per position enforced at database level
  * Application withdrawal allowed until position is filled
  * Automatic notification to host on withdrawal
* **Proposal Visibility**:
  * Full transparency of profit shares to all team members
  * Host messages preserved and displayed in proposal flow
  * Co-host privileges clearly communicated during invitation

### Financial Rules
* **Platform Fee**: Flat fee per ticket/donation (amount TBD)
* **Stripe Fees**: Absorbed from gross revenue
* **Settlement**: Host-triggered after event completion
* **Transparency**:
    * **Profit Shares**: All team members can see the profit share *percentages* of everyone on the team to ensure fairness.
    * **Payout Amounts**: Final payout *amounts* are visible based on role. Hosts/Co-hosts can see the full financial breakdown and all payout amounts. Collaborators can only see their own individual payout amount.
* **Payout Prerequisites**:
  * All collaborators must have Hyperwallet accounts
  * No pending removal requests or disputes
  * Sufficient Stripe balance available

#### Profile Completion Requirements

To support both frictionless guest conversion and robust creator profiles, the platform will use a tiered, just-in-time approach based on the user's entry point (Web vs. Mobile App).

**1. Web Onboarding (Minimal Friction for Guests & Applicants)**
* A user can become a guest or apply for a position on the web by creating a minimal account (Social OAuth or Email/Password). For these initial actions, a phone number is **not** mandatory. Profile completion is encouraged via non-blocking nudges.

**2. Mobile App Onboarding (Mandatory Gate)**
* The mobile app is the primary tool for active creators. To ensure a high-quality experience and data integrity, a stricter rule applies.
* The **Mandatory Profile Initialization Gate (Screen 25)** will be displayed immediately after login on **every session** if the user's profile is incomplete (`phone_number` is null OR `is_username_autogenerated` is true).
* The user will be required to provide a unique username and a phone number before they can access any other part of the mobile app.

**3. Payout Onboarding (Just-in-Time)**
* Separately, any user performing an action that requires them to receive payment for the first time (e.g., publishing a paid event, accepting a paid proposal) will trigger the **Hyperwallet Onboarding Modal (Screen 20)** if they do not have a `hyperwallet_user_token`. This is triggered after the primary action is initiated but before it is finalized.

* **Privacy Controls**:
  * Users control visibility of "Upcoming Events" section
  * Users control visibility of "Past Events" section
  * Granular controls for past events (hosted/collaborated/attended)
  * Separate controls for financial vs. social information
  *Users toggle these controls from the edit profile page.

## 6. Communication Strategy

### Channel Allocation
* **SMS**: Host/co-host initiated invitations with referral tracking, urgent notifications
* **Email**: Purchase confirmations, system notifications, broadcast messages, post-event summaries
* **Push**: Real-time updates for active app users, post-event celebrations, referral milestones
* **In-App**: Persistent states, post-event summaries, promotional impact displays

### Notification Triggers
* New sales, proposals, applications
* Event updates and cancellations
* Post-event summary availability
* Post-event networking opportunities
* Payout status changes
* Profile completion reminders
* Attribution milestones ("You brought 10 people!")
* Co-host privilege grants
* Application withdrawal notifications
* Proposal messages in pending items
* Enhanced Smart Link text based on item type
* RSVP status changes (Going/Maybe/Not Going)

## 7. Success Metrics

### Platform Health
* User acquisition and activation rates
* Event creation frequency and success rate
* Average collaborators per event
* Co-host adoption rate
* Revenue processing volume
* Settlement completion rate
* Post-event engagement rates
* Free event to paid event conversion

### Community Engagement
* Contact import adoption rate
* Event-based view usage
* Post-event connection rate
* Guest list import frequency
* Profile completion rates
* "Who's Going" impact on conversion
* Referral link usage and effectiveness
* Team member retention across events
* Maybe → Going conversion rates

### Creator Success
* Average events per creator profile
* Portfolio depth (events in "Past Events")
* Referral-driven attendance rates
* Post-event summary shares
* Collaborator retention rates
* Co-host to host conversion rate
* Team size growth over time
* Promotional impact per team member

### Financial Performance
* Average ticket price and event revenue
* Platform fee collection
* Payout success rate
* Time to settlement
* Dispute resolution rate
* Revenue per referral
* Profit share distribution patterns
* Team-driven revenue percentage

## 8. Security & Compliance

### Data Protection
* PII encryption at rest and in transit
* PCI compliance for payment data
* Secure token-based authentication
* Phone number verification for collaborators
* Privacy controls for public information
* Role-based access control enforcement
* Secure handling of invitation_id parameters
* Prevention of invitation link sharing/abuse
* Application status verification to prevent duplicate submissions

### Financial Security
* Stripe webhook signature verification
* Hyperwallet webhook authentication
* Idempotent payment operations
* Comprehensive audit logging
* Transparent financial reporting with role-based visibility
* Secure profit share storage and display

### Attribution & Privacy
* Referral tracking respects user privacy
* No personally identifiable information in URLs
* Clear consent for promotional impact sharing
* Secure storage of attribution data
* Team-only visibility for promotional metrics

## 9. Future Enhancements (Post-MVP)

* Public Event Summary pages with rich media
* Advanced analytics dashboard for hosts
* Multi-event series management
* Tiered platform fees based on volume
* In-app messaging between collaborators
* Event templates and cloning
* Automated tax documentation
* International payment support
* API for third-party integrations
* Enhanced "Past Events" with media galleries
* Social media integration for post-event sharing
* Advanced referral analytics and campaigns
* Co-host to host progression paths
* Team performance analytics
* Waitlist management for sold-out events
* Recurring event support
* Multi-tier ticketing

---

**Change Log:**
- v6.0: Major update incorporating all features from latest screen lists
- v7.0: UX Refinements update
- v8.0: Comprehensive update incorporating all features from mobile v4.0 and web v2.4:
  - Added Free RSVP and Donation-Based event support for Going/Maybe/Not Going responses
  - Added role/title character limit (30 chars) for collaborator invitations and open positions
  - Added event stats section with real-time metrics display
  - Enhanced guest list check-in for free events with separate Going/Maybe sections
  - Added privacy controls for profile event visibility (upcoming/past events)
  - Added granular controls for past event types (hosted/collaborated/attended)
  - Enhanced message guest modal with support for free event types
  - Updated promotional impact displays with tappable rows for detailed breakdowns
  - Added export functionality restrictions based on role
  - Enhanced confirmation messages based on guest list visibility settings
  - Added UI hints for referral tracking throughout
  - Updated post-event experience screens with full feature set from v4.0