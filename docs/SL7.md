**Document Version: 4.0**  
**Status: Final with UX Refinements**  
**Last Updated: December 2024**

This document provides a comprehensive list of all mobile application screens for the Micasa MVP. Each screen includes its purpose, content, and a detailed "Actions" section outlining all user navigation paths.

### **Part 1: Onboarding & Authentication**

**Screen 1: Authentication Screen**

* **Purpose**: To serve as the single entry point for new user registration and existing user login, prioritizing low-friction social authentication.  
* **Content**:  
  * Micasa logo and welcoming headline.  
  * Primary Button: `[Continue with Google]`  
  * Primary Button: `[Continue with Apple]`  
  * Secondary Link/Button: `[Continue with Email]`  
* **Actions**:  
  * Tapping `[Continue with Google]` or `[Continue with Apple]` initiates the respective OAuth flow. On success, the user is navigated to `Screen 4: Dashboard`.  
  * Tapping `[Continue with Email]` navigates the user to `Screen 2: Email Authentication Screen`.

**Screen 2: Email Authentication Screen**

* **Purpose:** To handle account creation and login for users who select the traditional email/password option.  
* **Trigger:** Tapping `[Continue with Email]` on `Screen 1: Authentication Screen`.  
* **Content:** A screen with two tabs at the top: `[Sign Up]` and `[Log In]`. The `Sign Up` tab is selected by default.  
  * **Sign Up View:**  
    * Fields for Email and Password only.  
    * T&C checkbox.  
    * `[Create Account]` button.  
  * **Log In View:**  
    * Fields for Email/Username and Password.  
    * `[Log In]` button.  
    * "Forgot Password?" link.  
* **Actions:**  
  * Tapping `[Create Account]` (after validation) creates the account and navigates to `Screen 4: Dashboard`, where `Screen 26: Initial Profile Setup` modal will automatically appear for first-time users.
  * Tapping `[Log In]` (after validation) navigates the user to `Screen 4: Dashboard`.  
  * Tapping "Forgot Password?" initiates the password reset flow.

### **Part 2: Main App Navigation (Persistent Bottom Tab Bar)**

* **Present on:** Screens 4, 12, 14, and 15.1.  
* **Tab 1: [Home]** -> Navigates to **Screen 4: Dashboard**.  
* **Tab 2: [My Events]** -> Navigates to **Screen 12: "My Events" Hub** (formerly "My Gigs").  
* **Tab 3: [My Community]** -> Navigates to **Screen 14: "My Community" Screen**.  
* **Tab 4: [Profile]** -> Navigates to **Screen 15.1: My Profile Hub**.

### **Part 3: Core App Screens**

### **Screen 4: Dashboard**

* **Purpose:** The user's lean, forward-looking command center focused on immediate actions and upcoming events.
* **Content (from top to bottom):** 
* **Smart Link Notification Banner** (conditional, at very top): Dynamic navigation based on pending item type:
  * **What counts as a "pending item":**
    * Incoming collaboration proposals (status: pending)
    * User's own applications to positions (status: pending)
    * Positions user is hosting that have new (unviewed) applications
    * Events user is hosting that need payout confirmation (post-event, unpaid)
  * **If user has exactly 1 pending item total:**
    * Single pending proposal: Shows "[Event Name] - 1 pending proposal" → Navigates to **Screen 12.1: Proposal Details**
    * Single pending application (user's own): Shows "[Event Name] - 1 pending application" → Navigates to **Screen 12: "My Events" Hub (Pending tab)**
    * Single position with applications: Shows "[Position Title] at [Event Name] - X new applications" → Navigates to **Screen 10: Applicant List**
    * Single event needing payout: Shows "[Event Name] - Payouts Ready" → Navigates to **Screen 7.1: Confirm Payouts Screen**
  * **If user has multiple pending items for ONE event:**
    * Shows "[Event Name] - X pending items" → Opens dropdown modal listing each item with navigation to appropriate screen
  * **If user has pending items across MULTIPLE events:**
    * Shows "[X pending items - View all]" → Navigates to **Screen 12: "My Events" Hub (Pending tab)**
 
 * **"Upcoming Events" Section:**
   * Section header: "Upcoming Events"
   * Shows up to 4 event cards maximum
   * Priority order:
     1. Events happening today (sorted by start time)
     2. Events happening tomorrow (sorted by start time)
     3. Future events (sorted chronologically)
   * If user has more than 4 upcoming events, show "View all →" link at bottom
   * Empty state: "No upcoming events. Create your first event!"
   * Each event card displays:
     * Event title
     * Date and time (relative format: "Today at 7PM", "Tomorrow at 2PM", "Sat, Feb 3")
     * Role-specific badge (HOSTING, CO-HOSTING, COLLABORATING, or ATTENDING)
     * Application indicator for HOSTING/CO-HOSTING events with new applications (e.g., "🔴 3 new")
 
 * **Floating Action Button (FAB):**
   * Fixed position bottom-right corner
   * Pill-shaped extended FAB with "+" icon and text "Create Event"
   * Elevated with shadow effect
   * Uses accent orange color (#FF6B35)
   * Always visible while scrolling

* **Actions:**  
 * Tapping FAB navigates to **Screen 5: Event Creation (Step 1)**.  
 * Tapping Smart Link navigates based on the rules above.
 * Tapping dropdown modal items (when multiple pending items for one event) navigates to:
   * Collaboration proposals → **Screen 12.1: Proposal Details**
   * Position applications → **Screen 10: Applicant List** for that position
 * Tapping a time-sensitive payout CTA navigates directly to **Screen 7.1: Confirm Payouts Screen**.
 * Tapping an event card navigates based on role:
   * HOSTING badge → **Screen 7: Dynamic Event Management Screen**
   * CO-HOSTING badge → **Screen 7: Dynamic Event Management Screen** (with restricted features)
   * COLLABORATING badge → **Screen 13: Collaborator Event View**
   * ATTENDING badge → **Screen 18: Attendee Event View**
 * Tapping "View all →" navigates to **Screen 12: "My Events" Hub (Upcoming tab)**

### **Screen 5: Event Creation (Step 1 - The "What & Where")**

* **Purpose**: To capture the essential, public-facing details of a new event in a clean and intuitive interface.  
* **Content**: A single-screen form containing the following fields:  
  * Cover Image: An image upload control, initially showing a placeholder icon. Tapping it should open the phone's native image library for the user to select a photo.  
  * Event Title: A mandatory text input field.  
  * Event Description: A multi-line text area allowing for a more detailed description of the event.  
  * Start Time: A mandatory control that opens the phone's native date/time picker UI.  
  * End Time: A mandatory control that also opens the native date/time picker UI.  
  * Location: A simple, single-line text input field for the location name or address (e.g., "Prospect Park Boathouse" or "123 Main St, Brooklyn, NY").  
* **Action**: A primary [Next] button is located at the bottom of the screen.  
  * Logic: The `[Next]` button is disabled until all mandatory fields (Title, Start Time, End Time) are filled out.  
  * Navigation: Once tapped, the app validates the inputs and navigates the user to `Screen 6: Event Creation (Step 2 - The "Rules & How")`.

### **Screen 6: Event Creation (Step 2 - The "Rules & How")**

* **Purpose:** To configure the rules for privacy, pricing, and attendance for a new event.  
* **Content:** A series of interactive controls:  
  * **Location Visibility:** A set of radio buttons:  
    * Show address immediately  
    * Show address only to confirmed guests  
    * Reveal address 24 hours before event  
  * **Ticket Pricing:** A primary selector with four options: "Fixed Price," "Choose Your Price," "Donation-Based," "Free RSVP."  
    * Conditional fields appear based on the selection:  
      * If "Fixed Price," a `Ticket Price` input is displayed.  
      * If "Choose Your Price," `Minimum Price` and `Suggested Price` inputs are displayed.  
      * If "Donation Based," a `Suggested Donation` input is displayed.  
	-- Note: Free RSVP and Donation-Based events will support "Going", "Maybe", and "Not Going" responses, allowing hosts to gauge interest beyond confirmed attendance.
  * **Max Capacity:** An optional numerical input field to limit total attendance.  
  * **Guest List Visibility:** A radio button selector with three options:
    * **🌐 Public** - Everyone can see who's attending
      * Helper text: "Create FOMO - Let everyone see who's going"
      * This is the default selection
    * **🎟️ Attendees (Live)** - Only ticket holders can see, starting when event begins
      * Helper text: "Exclusive - Attendees see count before event, full list during/after"  
    * **🔒 Private** - Only you and co-hosts can see
      * Helper text: "Maximum privacy - No one else sees the guest list"
    * **Backend Logic:** 
      * Public: Sets `guest_list_visibility: "public"`
      * Attendees (Live): Sets `guest_list_visibility: "attendees_live"`
      * Private: Sets `guest_list_visibility: "private"`
  * **Event Privacy:** A single checkbox control.
    * **Label:** `[ ] Private Event - Invite Only`
    * **Default State:** Unchecked.
    * **Logic:** When unchecked (default), the event is public and anyone with the link can purchase tickets/RSVP. When checked, sends `is_invite_only: true` to the API, restricting ticket purchases to only those who have been explicitly invited by the host.
* **Action:** Tapping the **[Publish Event]** button triggers a Logic Gate:  
  * If the event is paid AND the user has no `hyperwallet_user_token`, the app displays `Screen 20: Hyperwallet Onboarding Modal`. Upon completion, it navigates to `Screen 7: Dynamic Event Management Screen`.  
  * Otherwise, it navigates directly to `Screen 7: Dynamic Event Management Screen`.

### **Screen 7: Dynamic Event Management Screen**

* **Purpose:** The control center for hosts AND co-hosts to manage a single event during pre-event and live phases.  
* **Access Control:**
  * **Primary Host:** Full access to all features
  * **Co-hosts:** Access to all features EXCEPT [Edit Details], [Confirm Payouts], and [Cancel Event]
* **Content:** 
  * Event header displaying title, date, time, and user's role ("Host" or "Co-host")
 * **Content (Pre-Event):** Action buttons organized in three logical groups:
  
  **1. Promotion & Discovery**
  *Getting people interested and signed up*
  * [Preview] -> Shows event as it appears publicly
  * [Share Event] -> Opens native share sheet with event URL including user's referral parameter (?ref=[user_id])
    * Subtitle text: "Your referral link - track your impact!"
  * [Get Event QR] -> Displays QR code of shareable event link (for physical promotion)
  * [Invite Guests] -> Navigates to **Screen 7.2: Invite Guests Screen**
  
  **2. Operations & Guest Management**
  *Managing the people coming to your event*
  * [View Guest List] -> Navigates to **Screen 19: Guest List Check-in Screen** (read-only mode)
  * [Get Donation QR] -> Displays QR code for donation collection **(Only visible for donation-based events)**
  * [Message Guests] -> Opens **Screen 24: Message Guest List Modal**
  
  **3. Core Event & Team Administration**
  *Fundamental event setup and management*
  * [Manage Team] -> Navigates to **Screen 8: Event Collaboration Hub**
  * [Edit Details] -> Navigates back to **Screen 5/6** with fields pre-populated **(Host only - hidden for co-hosts)**
  * [Cancel Event] -> Opens **Screen 23: Cancel Event Confirmation Modal** **(Host only - hidden for co-hosts)**
  
* **Event Stats Section** (visible below action buttons):
  * Displays as a card/section at the bottom
  * Shows key metrics:
    - "Registered": Total attendee count (or "Going" for Free RSVP/Donation events)
    - "Team Size": Number of collaborators (including host)
    - "Revenue": Total revenue (for paid events) or "$0" for free events
  * For Free RSVP/Donation events: Shows "23 Going • 8 Maybe" in the Registered area
  * Updates in real-time

 * **Content (Live-Event):**
    * [Check In Guests] -> Navigates to **Screen 19: Guest List Check-in Screen** (interactive mode)
    * Other pre-event buttons remain available as appropriate

* **Actions (Post-Event):**
  * Co-hosts cannot access this screen post-event (redirected to Screen 13)
  * Only the primary host can access post-event features and navigate to Screen 7.1
* **Timing:** This screen remains accessible until the event END time (not start time), allowing management during the live event.
* **Note:** This screen does not have a Post-Event state. Past events are accessed via Screen 12 (My Events Hub).

**Screen 7.1: Confirm Payouts Screen**

* **Purpose:** Allows a host to review event financials and manage collaborator payouts before distribution.  
* **Trigger:** 
  * From Dashboard (Screen 4): Tapping a time-sensitive payout CTA
  * From Screen 27: Tapping the nudge banner [Confirm & Trigger Payouts] if payouts haven't been processed
* **Content:** A list of collaborators with their calculated payout amount. A main `[Confirm & Pay Out All]` button.  
* **Actions:**  
  * Tapping the `[Remove]` button next to a collaborator initiates a **removal request**.  
    * This action changes the collaborator's status to `pending_removal`.  
    * The `[Confirm & Pay Out All]` button becomes **disabled** until the request is resolved.  
    * The collaborator is notified and must approve or dispute the removal.  
  * Tapping `[Confirm & Pay Out All]` (when enabled) triggers the Hyperwallet distribution for all non-excluded collaborators and navigates the host to **Screen 27: Social Settlement Screen**.

**Screen 7.2: Invite Guests Screen**

* **Purpose:** To allow a host to invite guests from their community using the event-based grouping feature.
* **Content:** 
  * Toggle control at the top: "All Contacts" | "Group by Event"
  * When "All Contacts" is selected: Standard list of all contacts
  * When "Group by Event" is selected: Collapsible event frames showing ALL events where the user has been present (as host, collaborator, or attendee), ordered by most recent first
  * A [Send Invites] button at the bottom
* **Actions:** 
  * Toggling between views instantly switches the display
  * Expanding/collapsing event frames to see contacts from specific events
  * Selecting multiple contacts for batch invitation
  * Tapping [Send Invites] triggers the SMS flow with automatically appended referral parameters and returns the user to **Screen 7**.
* **Note for Free RSVP and Donation-Based events:** When inviting to Free RSVP or Donation-Based events, the invitation will include text: "This is a free event - they can RSVP as Going, Maybe, or Not Going"

### **Screen 8: Event Collaboration Hub**

* **Purpose:** Manage the team for an event with clear role distinctions and transparent profit sharing.  
* **Content:** 
* **"Collaborators"** main section header with conditional subsections:
  * **"Co-hosts"** subsection - Only displays if there are co-host level collaborators
    * Shows collaborators with elevated privileges
    * Each entry displays: Profile picture, name, custom role title, profit share %, and "Co-host" badge
  * **"Team Members"** subsection - Only displays if there are regular collaborators
    * Shows regular collaborators
    * Each entry displays: Profile picture, name, custom role title, and profit share %
  * **Note:** If no collaborators exist in a category, that subsection header is hidden entirely
  * **Empty State:** If no collaborators at all, show: "No team members yet. Invite collaborators to help make your event amazing!"
  * **Transparency Note:** All profit share percentages are visible to all team members
* **Open Positions** (only displays section if positions exist)
  * If no open positions: Hide this entire section
  * When positions exist: Show list with applicant counts
* ** Action buttons:
    * [Invite Collaborator] -> Navigates to `Screen 9: Invite Collaborator Screen`
    * [Create Open Position] -> Navigates to `Screen 11: Create Open Position Screen`
* **Actions:**
  * Both hosts and co-hosts can access all features in this hub
  * Tapping an open position -> Navigates to `Screen 10: Applicant List Screen`
  * Next to each open position, an ellipsis (`...`) menu provides:
    * **`[Edit]`** -> Navigates to `Screen 11` with pre-populated fields
    * **`[Delete]`** -> Opens confirmation modal (fails if applications exist)

### **Screen 9: Invite Collaborator (from Community)**

* **Purpose:** To allow a Host or Co-host to select a contact from their "My Community" list and send them a formal collaboration proposal via SMS.
* **Trigger:** Tapping the **[Invite Collaborator]** button on the **Event Collaboration Hub (Screen 8)**.
* **Content & Flow:** 
  * Toggle control at the top: "All Contacts" | "Group by Event"
  * When "All Contacts" is selected: 
    * Searchable list showing each contact with their name, phone number, and a [Select] button
  * When "Group by Event" is selected:
    * Collapsible event frames showing ALL events where the user has been present (as host, collaborator, or attendee)
    * Each collapsed frame displays: Event title, date, and 5-10 contact previews
    * Frames ordered by most recent events first
    * Each expanded frame shows all contacts alphabetically with [Select] buttons
  * Upon selection via [Select] button, the screen transitions to the proposal form:
    * The selected contact's name and profile picture displayed clearly at the top
    * A required numerical input field for the **"Profit Share %"**
    * A required text input field for "Role/Title" (e.g., "DJ", "Photographer", "Event Coordinator")
      * Character limit: 30 characters
      * Placeholder text: "Enter their role"
    * **New Toggle:** `[ ] Grant co-host privileges`
      * Helper text: "Co-hosts can invite guests, manage the team, and check people in"
      * Additional text: "✨ They'll get their own trackable promotional link!"
    * An optional text area for a brief **"Message"** to personalize the invitation
* **Actions:**  
  * **[Send Proposal]:** Sends the invitation via SMS with:
    * Automatic referral parameter appended to the acceptance link
    * `is_cohost: true/false` based on the toggle state
    * Returns user to Screen 8 after sending
  * **Profile View:** Tapping anywhere on the contact card (except [Select]) navigates to Screen 15 (User Profile View)
  * **Cancel/Back (<)** Returns to Screen 8 without sending

### **Screen 10: Applicant List Screen**

* **Purpose:** To allow hosts and co-hosts to review, evaluate, and manage applications received for an open position on their event, with all relevant information available in one place.
* **Trigger:** Tapping on an open position card from Screen 8 (Event Collaboration Hub) that shows "X applicants"
* **Content:** 
 * Header showing the position title (e.g., "Applications for: Photographer")
 * Application count indicator
 * List of applicant cards, each displaying:
   * Applicant's profile picture (or placeholder)
   * Username
   * Application date/time
   * Preview of their application message (first 2-3 lines)
   * Expand/collapse indicator (chevron)
   * Two action buttons: [Decline] [Accept]
 * **Expanded state** (tapping card body expands in place):
   * Full application message
   * **Complete Profile Section:**
     * Bio (if provided)
     * Instagram handle and/or website (if provided, displayed as tappable links)

   * Action buttons remain visible at bottom: [Decline] [Accept]
 * Empty state (if no applications): "No applications yet. Share your event to attract collaborators!"
* **Actions:**
 * Tapping card body → Expands/collapses the card
 * Tapping [Accept] → Updates application status, sends notification to applicant, navigates back to Screen 8
 * Tapping [Decline] → Updates application status, removes card from list with animation
 * Tapping Instagram/website links → Opens in external browser
 * **Back/Cancel (<)** → Returns to **Screen 8: Event Collaboration Hub**

**Screen 11: Create / Edit Open Position Screen**

* **Purpose:** To allow a host to define the details for a new open position or edit the details of an existing one.  
* **Content:** A form containing the following fields:  
  * **Role Title:** A required text input field for the position's title (e.g., "DJ," "Photographer").
      * ** Character limit: 30 characters 
  * **Description:** A text area for providing details, requirements, and other notes about the role.  
  * **Profit Share %:** An optional numerical input for proposing a specific revenue share percentage.  
* **Actions & Logic:** The screen's title and action buttons are conditional based on how the user accessed it.  
  * **In Create Mode** (Accessed from *Screen 8: Event Collaboration Hub* by tapping `[Create an Open Position]`):  
    * The primary button is **`[Post Position]`**. Tapping it creates the position with the specified details and navigates the user back to Screen 8.  
    * A **Cancel/Back (`<`)** action must be present to discard the new position and return to Screen 8.  
  * **In Edit Mode** (Accessed from *Screen 8: Event Collaboration Hub* by tapping the `[Edit]` option on an existing position ):  
    * The form fields are pre-populated with the existing position's data.  
    * The primary button is **`[Save Changes]`**. Tapping it updates the position and navigates the user back to Screen 8.  
    * A **Cancel/Back (`<`)** action must be present to discard any changes and return to Screen 8.  
    * A secondary button, **`[Delete Position]`**, is present. Tapping it opens a confirmation modal before deletion.  
      * **Conditional State:** This button **must be disabled** if one or more users have already applied for the position.

### **Screen 12: "My Events" Hub**

* **Purpose:** The user's comprehensive event filing system for all their events across all roles.
* **Content:** Tabs for "Pending", "Upcoming", "Past" events.
  * Event cards clearly display the user's role:
    * "Host" (primary event organizer)
    * "Co-host" (collaborator with elevated privileges)
    * "Collaborator" (regular team member)
    * "Attendee" (guest)
  * Cards may show promotional impact: "You brought: 5 people" (if referrals > 0)
* **Actions:**  
  * **Pending Tab:**
    * If no pending items: Show empty state "No pending proposals or applications"
    * Shows pending proposals and applications with enhanced card displays:
    
    **Pending Proposal Cards display:**
    * Event Title
    * Date & Time
    * "Invited by: [Host Name]"
    * "Role: [Custom Role Title]"
    * "Profit Share: [X%]"
    * [CO-HOST badge] (if applicable)
    * 💬 icon (if host included a message)
    * [Decline] [Accept] buttons at bottom
    
    **Pending Application Cards display:**
    * Event Title
    * Date & Time
    * "Applied for: [Position Title]"
    * "Status: Application Pending"
    * "Applied on: [Date]"
    * [Withdraw Application] button
    
    **Interactions:**
    * Quick actions (Accept/Decline/Withdraw) work directly from the list
    * Tapping proposal card body → Navigates to **Screen 12.1: Proposal Details**
    * Tapping application card body → Navigates to **Screen 18: Attendee Event View**
    * Accepting a proposal triggers the Hyperwallet Logic Gate (same as Screen 6) if it's the first paid gig

  * **Upcoming Tab:** 
    * Shows all upcoming events regardless of role
    * When empty: Show centered empty state "No upcoming events. Create your first event!"
    * Tapping an event navigates based on role:
      * Host role -> `Screen 7: Dynamic Event Management Screen`
      * Co-host role -> `Screen 7: Dynamic Event Management Screen` (with restrictions)
      * Collaborator role -> `Screen 13: Collaborator Event View`
      * Attendee role -> `Screen 18: Attendee Event View`
    *For Free RSVP/Donation events**: 
      * Show RSVP status badge next to role badge:
          * "GOING" (green badge)
          * "MAYBE" (yellow badge)
      * Quick action: Long-press on card shows menu with "Change RSVP Status" option
      * Selecting opens same modal as Screen 18

  * **Past Tab:**  
    * Shows all past events with permanent access to summaries
    * When empty: Show centered empty state "Your past events will appear here"
    * Tapping an event navigates to:
      * For hosts of monetized events -> `Screen 27: Social Settlement Screen`
      * For hosts of free events -> `Screen 28: Collaborative Snapshot Screen`
      * For collaborators/attendees of any event -> `Screen 27` or `Screen 28` with appropriate visibility
    * ***Removal State:*** If a gig has a `pending_removal` status, the card will display a prominent notification with two buttons: `[Approve Removal]` and `[Dispute Removal]`.  
      * Tapping `[Approve Removal]` confirms the removal. The card updates to show "Removal Approved".  
      * Tapping `[Dispute Removal]` opens `Screen 21: Payout Dispute Modal`.

### **Screen 12.1: Proposal Details**

* **Purpose:** To provide a comprehensive view of a collaboration proposal, allowing users to make an informed decision with full context including the host's personal message, event details, and clear financial terms.
* **Trigger:** 
  * Tapping on a pending proposal card (body area) from Screen 12: "My Events" Hub (Pending tab)
  * Navigating from Dashboard Smart Link when there's a single pending proposal
* **Content:**
  * **Proposal Summary Card:**
    * "💌 Collaboration Proposal" header
    * From: [Host Name] (@username)
    * Role: [Custom Role Title]
    * Profit Share: [X%]
    * [CO-HOST badge] (if applicable)
  * **Host's Message Section** (if provided):
    * Displayed in quoted style with subtle background
    * Full message text from the host
  * **Event Details Section:**
    * Event cover image
    * Event title, date, time, location
    * Full event description
    * Ticket price and expected attendance
    * **Event Team Display:**
      * Host: [Name] with profile picture and "Host" badge
      * Co-hosts: Listed with profile pictures and "Co-host" badges
      * Current collaborators: Listed with roles (if any confirmed)
  * **Your Role & Responsibilities** (if specified):
    * Bullet points of specific responsibilities
    * Expected time commitment
  * **Team Overview:**
    * Shows complete team with roles and profit shares
    * Highlights "You" in the position being offered
    * Note: This section shows profit share transparency, while the Event Details section shows the public team display
  * **Co-Host Privileges** (conditional):
    * Only shown if being invited as co-host
    * Lists additional permissions and capabilities
  * **Action Buttons:**
    * [Decline Proposal] (secondary)
    * [Accept Proposal] (primary)
  * **Additional Features:**
    * "View full public event page →" link (opens in-app browser)
    * Tappable host profile
* **Actions:**
  * **Accept Flow:**
    * Tap [Accept Proposal]
    * If first paid collaboration → Screen 20 (Hyperwallet Modal)
    * Otherwise → Success toast "You're on the team! 🎉" and return to Screen 12
  * **Decline Flow:**
    * Tap [Decline Proposal]
    * Show confirmation dialog
    * On confirm → Return to Screen 12 with "Proposal declined" toast
  * **Host Profile:** Tapping host name/avatar → Screen 15 (User Profile)

### **Screen 13: Collaborator Event View**

* **Purpose:** To provide regular collaborators (without co-host privileges) with event details, team transparency, and appropriate guest list access.
* **Note:** Co-hosts do not use this screen - they access Screen 7 (Dynamic Event Management) instead.
* **Trigger:** 
  * From Dashboard (Screen 4): Tapping an event card with a "COLLABORATING" badge
  * From "My Events" Hub (Screen 12): Tapping on any upcoming or past event where the user is a regular collaborator
* **Content:**  
  * A header displaying the Event Title, Date, and Time.  
  * **Team Display Section:**
    * Shows all participants: hosts, co-hosts, and collaborators
    * Each entry displays: Profile picture, username, custom role title, role badge, and profit share %
    * **Transparency:** All profit share percentages are visible to all team members
  * A conditional `[Share Event]` button.
    * **Logic:** Only visible if the event's `is_invite_only` is false (public events)
    * Subtitle text: "Your referral link - track your impact!"
    * **Note:** When tapped, automatically appends the collaborator's referral parameter (?ref=[user_id])
  * A conditional `[View Guest List]` button.  
    * **Logic:** Button visibility depends on the `guest_list_visibility` setting:
      * If "private": Hidden (collaborators cannot see guest list)
      * If "public": Always visible for upcoming/live/past events
      * If "attendees_live": Always visible for upcoming/live/past events (collaborators have same access as public mode)
* **Actions:**  
  * Tapping `[Share Event]` opens the native share sheet to share the event's public URL with automatic referral parameter.
  * Tapping on any user's profile navigates to `Screen 15: User Profile View (Public)`.  
  * Tapping the `[View Guest List]` button navigates to `Screen 18.1: Participant Guest List View`.

**Screen 14: "My Community" Screen**

* **Purpose:** To allow a user to build and manage their personal list of contacts, view contacts grouped by shared events, and easily see which of their contacts are already on the Micasa platform.
* **Content:**  
  * Toggle control at the top: "All Contacts" | "Group by Event"
  * **All Contacts View:**
    * Primary buttons: `[Add Contact Manually]` and `[Import from Phone's Contacts]`.
    * A list of contact cards. The appearance of each card is conditional:
      * **Unlinked Contacts** (manual entries): Display as a simple card with only a name/initials.
      * **Linked Contacts** (Micasa users): Display as an enhanced card featuring the user's profile picture and a small Micasa icon.
  * **Group by Event View:**
    * Collapsible event frames showing events the user has attended/hosted/collaborated on
    * Each frame displays: Event title, date, and 5-10 contact previews
    * Frames ordered by most recent events first
    * Expanded frames show all contacts alphabetically with profile pictures
* **Actions:**  
  * Toggle between views instantly switches the display
  * In All Contacts View:
    * Tapping `[Add Contact Manually]` -> Opens a form to add a new contact's name and phone number.
    * Tapping `[Import from Phone's Contacts]` -> Initiates the OS permission prompt and contact import flow.
    * **For Unlinked Contact Cards:**
      * **Tapping the card** -> Opens a simple action modal with `[Edit]` and `[Delete]` options.
    * **For Linked Contact Cards:**
      * **Tapping the main card area** -> Navigates to the user's public profile (`Screen 15: User Profile View`).
      * **Tapping a small `...` (ellipsis) icon** on the card -> Opens a simple action modal with `[Edit]` and `[Delete]` options.
  * In Group by Event View:
    * Tapping collapsed frame -> Expands to show all contacts from that event
    * Tapping [X] on expanded frame -> Collapses the frame
    * Tapping a contact -> Navigates to `Screen 15: User Profile View`

### **Screen 15: User Profile View (Public)**

* **Purpose:** To display the public-facing, non-sensitive information of a Micasa user, allowing others to identify them and understand their event history. This screen is accessed when a user taps on another user's profile from an event page or community list.  
* **Content:** A read-only display of the following public user data, sourced from the `GET /api/users/:id` endpoint:  
  * Profile Picture  
  * Username  
  * Bio  
  * Clickable links for their Instagram Handle and Personal Website (if provided).  
  * **"Past Events" Section**: A list of past public events where this user was a host or collaborator (if user has enabled this in privacy settings)
  * A conditional `[+ Add to My Community]` button.  
  * **Context-Aware Addition:** When accessed from Screen 9's collaborator selection flow, an additional `[Select as Collaborator]` button appears.
* **Actions:**  
  * **Add to Community:**  
    * **Logic:** The `[+ Add to My Community]` button is only visible if the user being viewed is not already in the authenticated user's contact list.  
    * **API Call:** Tapping the button calls the `POST /api/users/me/contacts-from-profile` endpoint, sending the viewed user's ID.  
    * **UI Feedback:** Upon a successful API response, the button should be hidden or replaced with a non-interactive "✓ Added" state to confirm the action.
  * **Select as Collaborator (Context-Specific):**
    * Only visible when navigating from Screen 9
    * Tapping returns to Screen 9 with this contact pre-selected for the profit share form

* **Upcoming Events Section** (conditional):
  • Visible if user has enabled in privacy settings
  • Shows up to 10 upcoming events where user is Host, Co-host, or Collaborator (NOT attending)
  • Each event displays:
    - Event thumbnail image (or placeholder)
    - Event name (clickable - opens event page in browser/webview)
    - Date
    - Role badge: "HOST", "CO-HOST", or custom role title
  • Events listed chronologically (soonest first)
  • If no upcoming events: Section hidden entirely

* **Past Events Section** (conditional):
  • Visible if user has enabled in privacy settings  
  • Shows up to 10 past events where user was Host, Co-host, Collaborator, OR Attendee
  • Each event displays:
    - Event thumbnail image (or placeholder)
    - Event name
    - Date
    - Role badge: "HOST", "CO-HOST", custom role title, or "ATTENDEE"
  • Events listed chronologically (most recent first)
  • Note: In MVP, these are display-only. Post-MVP enhancement will add clickable public event summary pages.

**Screen 15.1: My Profile Hub**

* **Purpose:** To serve as the primary menu for the authenticated user to access secondary features like earnings, invitations, community management, and profile settings.  
* **Trigger:** Tapping the "Profile" icon in the main global navigation bar.  
* **Content:** A menu consisting of a list of navigation links:  
  * **My Earnings** (Navigates to Screen 15.2)  
  * **My Invitations** (Navigates to Screen 17)  
  * **Edit Profile** (Navigates to Screen 16)  
  * **View My Public Profile** (Navigates to Screen 15)
  * **My Community** (Navigates to Screen 14)  
  * **Log Out**  
* **Actions:**  
  * Tapping a link navigates the user to the corresponding screen.  
  * Tapping **View My Public Profile** navigates to `Screen 15: User Profile View (Public)`, populated with the authenticated user's own data.
  * Tapping "Log Out" ends the user's session and returns them to `Screen 1: Authentication Screen`.

**Screen 15.2: My Earnings Screen**

* **Purpose:** To provide a user with a clear, transparent, and centralized dashboard for tracking all income earned as a collaborator or host through the Micasa platform. This screen is crucial for building trust and demonstrating the platform's value.
* **Trigger:** Navigated from the "My Earnings" link on the My Profile Hub (Screen 15.1).
* **Content:**
  * A prominent summary card at the top of the screen that displays the user's Total Earnings to date.
  * A chronological, scrollable list of all individual payout line items from past events, populated by the GET /api/users/me/earnings endpoint.
  * Each item in the earnings history list will display:
    * The name of the event (event.title).
    * The expected or final payout amount.
    * The status of the payout (e.g., "Pending Payout," "On Hold," "Paid").
    * The date the payout was processed (paid_at), which will only be displayed if the status is 'Paid'.
* **Actions:**
  * A primary button, [Export All Earnings as CSV], will be present on the screen.
  * Tapping this button will trigger the GET /api/users/me/earnings/export endpoint and initiate the phone's native file download or share flow.

**Screen 16: Edit Profile Screen**

* **Purpose:** To allow users to create and manage their public-facing identity on Micasa. This includes updating personal information, adding social links, uploading a profile picture, and controlling privacy settings to build trust and recognition within the community.
* **Trigger:** Navigated from the "Edit Profile" link on the My Profile Hub (Screen 15.1) or conditionally from the Initial Profile Setup (Screen 26).
* **Content:** A form containing input fields for all editable user profile attributes as defined by the PUT /api/users/me endpoint:
  * An image upload control for the Profile Picture.
  * Text input field for Username.
  * Text input field for Phone Number.
  * A multi-line text area for the user's Bio.
  * Text input field for a Personal Website URL.
  * Text input field for an Instagram Handle.
- **Privacy Settings Section:**
  * Toggle: "Show Upcoming Events on Profile" (default: ON)
    * Helper text: "Display events you're hosting or working on"
  * Toggle: "Show Past Events on Profile" (default: ON)
    * Helper text: "Display your event history"
  * Granular control section: "Include in Past Events:"
    * Checkbox: [✓] Events I hosted
    * Checkbox: [✓] Events I collaborated on
    * Checkbox: [✓] Events I attended
    * Note: At least one must be selected if Past Events is ON
* **Actions:**
  * A [Save Changes] button at the bottom of the screen.
  * Tapping this button will validate the fields and call the PUT /api/users/me endpoint with the updated profile data.
  * Upon a successful save, the user is navigated back to the My Profile Hub (Screen 15.1).

**Screen 17: My Invitations Screen**

* **Purpose:** To serve as a personal inbox where a user can view all pending private event invitations they have received from hosts. This feature is key to the platform's community and networking aspects.
* **Trigger:** Navigated from the "My Invitations" link on the My Profile Hub (Screen 15.1).
* **Content:**
  * The screen will be populated by a call to the GET /api/users/me/invitations endpoint.
  * It will display a clean, scrollable list of pending event invitations.
  * Each invitation will be presented as a distinct card containing:
    * The event title.
    * The event's start date and time (event_start_time).
    * The username of the host who sent the invitation.
  * If the user has no pending invitations, the screen will display a clear and friendly message (e.g., "You have no new event invitations.").
* **Actions:**
  * Tapping on any invitation card will open the corresponding Public Event Page (W-1) in an **in-app browser** with preserved invitation context
  * The URL will include invitation parameters: `events.micasa.events/e/{event_id}?invitation_id={invitation_id}&ref={inviter_user_id}`
  * The in-app browser includes a native header with "Done" button to return to the app

### **Screen 18: Attendee Event View**

* **Purpose:** To provide attendees with a simple mobile interface for viewing their ticket details and accessing the guest list when permitted by privacy settings.
* **Trigger:** 
  * From Dashboard (Screen 4): Tapping an event card with an "ATTENDING" badge
  * From "My Events" Hub (Screen 12): Tapping on any event where the user is an attendee
* **Content:**
  * Event header displaying:
    * Event title
    * Date and time
    * Location (respecting location visibility settings)
    * Event cover image
  * Host and co-host information (names and profile pictures)
  * Ticket details:
    * Ticket type purchased
    * Order confirmation number
    * QR code for check-in (if applicable)
* **RSVP Status Section** (conditional - only for free_rsvp and donation events):
    * Current status display: "Your Status: Going" or "Your Status: Maybe"
    * [Change RSVP Status] button
    * **When tapped**: Opens modal with three options:
        * Going
        * Maybe  
        * Not Going
    * **Backend behavior**: Calls `PUT /api/tickets/:ticket_id/rsvp` with new status
    * **Edge case**: If changing to "Going" on a full event, show error: "Sorry, this event is at capacity"
  * Conditional `[View Guest List]` button
    * **Visibility Logic based on `guest_list_visibility` setting:**
      * If "public": Always visible
      * If "attendees_live": Only visible during live/past events
      * If "private": Hidden (never visible to attendees)
  * `[Share Event]` button (for public events only)
    * Note: Regular attendees do NOT get referral tracking
* **Actions:**
  * Tapping `[View Guest List]` navigates to **Screen 18.1: Participant Guest List View**
  * Tapping `[Share Event]` opens native share sheet with standard event URL (no referral parameter)
  * Tapping host/co-host profiles navigates to **Screen 15: User Profile View**

### **Screen 18.1: Participant Guest List View**

* **Purpose**: To allow authorized participants to view and import the list of other guests for an event, enabling post-event networking.
* **Trigger**: Tapping the `[View Guest List]` button from:
  * `Collaborator Event View (Screen 13)` - for collaborators
  * `Attendee Event View (Screen 18)` - for regular attendees (when privacy allows)
* **Access Rules by Guest List Visibility Setting:**
  * **"public":** All participants can see full list at any time
  * **"attendees_live":** 
    * Regular attendees: See count only pre-event, full list during/after
    * Collaborators/Co-hosts: See full list at any time (exempt from restrictions)
  * **"private":** Only hosts and co-hosts can ever access
* **Content (Pre-Event for "attendees_live" mode - regular attendees only):**
  * Event title header
  * Large count display: "25 people are attending"
  * Informational message: "Full guest list will be available once the event begins"
  * No import functionality available yet
* **Content (Full Access View):**  
  * A header displaying the event title (e.g., "77 @ The Lot").
  * An `[Import to My Community]` button (always visible for users with full access).
  * A search bar to allow filtering the guest list by name in real-time.
  * A scrollable list of all registered guests, populated by the `GET /api/events/:id/guests` endpoint. Each list item will display only the guest's username.
* **Archive View (Past Events):**
  • When viewing past events from My Events Hub:
    - Header shows "Past Event" badge
    - QR code section replaced with "This event has ended"
    - Guest list remains viewable based on original visibility settings
    - All other information remains for historical reference
* **Actions:**  
  * Tapping `[Import to My Community]` -> Bulk imports all guests to user's community with success message
  * Tapping on any guest's username in the list navigates the user to `Screen 15: User Profile View (Public)`, where they can view that person's profile and add them individually.

**Screen 19: Guest List Check-in**

* **Purpose:** To allow a host or co-host to view the guest list for a live event, digitally check in attendees, and import the guest list to their community.
* **Trigger:** Tapping the [View Guest List] button from the Dynamic Event Management Screen (Screen 7).
* **Content:**  
  * A header displaying the event title and real-time counts:
    * For paid/choose-your-price events: "Checked In / Total Guests"
      * Example: "32 checked in / 47 total"
    * For Free RSVP/Donation-based events: "Checked In / Going / Maybe"
      * Example: "15 checked in / 23 going / 8 maybe"
  * An `[Import to My Community]` button (always visible for hosts).
  * A search bar to allow the host to quickly filter the guest list by name.
  * Guest list display:
    * **For paid/choose-your-price events:**
      * Single scrollable list of all registered guests
      * Each guest shows: username and check-in toggle
    * **For Free RSVP/Donation-based events:**
      * Two distinct sections:
        * **"Going" section**: 
          * Shows all confirmed attendees
          * Each guest shows: username and check-in toggle (functional)
        * **"Maybe" section**:
          * Shows all maybe respondents  
          * Each guest shows: username only (no check-in toggle)
          * Grayed out or visually distinct to indicate view-only status
  * All lists populated by the GET /api/events/:id/guests endpoint
* **Actions:**  
  * Tapping `[Import to My Community]` -> Bulk imports all guests to host's community with success message
  * Tapping the check-in indicator for a "Going" guest triggers the POST /api/tickets/:ticket_id/check-in API call
  * Check-in toggles are only functional for "Going" attendees (not available for "Maybe")
  * Upon successful check-in, the UI immediately updates to reflect the new status and header count updates
  * Search filters both "Going" and "Maybe" sections simultaneously

### **Part 4: Pop-ups & Modals**

**Screen 20: Hyperwallet Onboarding Modal**

* **Purpose:** To securely host the one-time Hyperwallet payout setup process within a modal window. This is a critical step in the "Just-in-Time Friction" principle, ensuring a user only provides sensitive financial information at the exact moment it's required to receive payment.
* **Core Logic:** The Micasa backend will determine if a user needs to be onboarded by checking for the existence of a hyperwallet_user_token on their user record. The client application (both web and mobile) is responsible for calling the POST /api/users/me/payout-account/onboarding-token endpoint immediately before displaying the modal to fetch the single-use token required to render the embedded form.
* **Exhaustive List of Triggers:** The Hyperwallet Onboarding Modal is displayed automatically and conditionally in the following specific scenarios. It is only ever shown if the user has not completed this process before (i.e., their hyperwallet_user_token is null).
  * **For Hosts (Mobile App):** The modal is triggered immediately after a host taps [Publish Event] on Screen 6: Event Creation (Step 2) IF the event has a paid component (Fixed Price, Choose Your Price, or Donation Based).
    * User Flow: Screen 6 -> [Publish Event] -> Screen 20: Hyperwallet Modal -> Screen 7: Dynamic Event Management Screen.
  * **For Invited Collaborators (Web):** The modal is triggered immediately after an invited user taps [Accept Proposal] on the Screen W-3: Proposal Acceptance Page IF the proposal's profit share percentage is greater than 0%.
    * User Flow: Screen W-3 -> [Accept Proposal] -> Screen W-6 / 20: Hyperwallet Modal -> Screen W-5: App Funnel Page.
  * **For Collaborators Accepting Gigs (Mobile App):** The modal is triggered immediately after a user taps [Accept] on a paid gig proposal within the "Pending" tab of the "My Events" Hub (Screen 12).
    * User Flow: Screen 12 -> [Accept] -> Screen 20: Hyperwallet Modal -> Returns to Screen 12 with the gig moved to "Upcoming".

**Screen 21: Payout Dispute Modal**
* **Purpose:** To allow a collaborator to formally dispute a payout removal request.
* **Trigger:** Tapped from the `[Dispute Removal]` button on a gig card in the "My Events" Hub (Screen 12).
* **Content:** A text field for the collaborator to provide comments explaining their reason for the dispute. A main `[Submit Dispute]` button.
* **Action:** Tapping `[Submit Dispute]` sends the dispute to Micasa staff for manual review and changes the gig's status to `disputed`. All payouts for the event remain frozen until the dispute is resolved.

**Screen 22: Profile Completion Prompt Modal (Conditional Logic)**

* **Purpose:** To strongly encourage a user to complete their profile with essential information at the moment of highest relevance, thereby improving their standing in the community and the overall quality of the platform's social graph.
* **Core Logic:** This modal is displayed one time only. It triggers the very first time a user with an "incomplete" profile attempts one of the key actions listed below.
* **Definition of Incomplete:** A user's profile is considered "incomplete" if their profile_picture_url OR bio field is null or empty. The instagram_handle and personal_website_url fields do not affect this logic.

* **Trigger Model 1: Pre-Action ("Informed Continuance")**
  * This model is used when a strong first impression is critical to the success of the action itself.
  * **Applies To:**
    * **Applicants:** When a user taps [Apply] on an Open Position.
    * **Hosts:** When a user taps [Publish Event] on Screen 6: Event Creation (Step 2).
  * **Behavior:** The modal appears before the action is processed, momentarily pausing the flow.
  * **Content:**
    * Headline: "Help Them Get to Know You"
    * Body Text: "A complete profile with a photo and bio makes a great first impression. We highly recommend adding these before you continue."
    * Primary Button: [Complete My Profile]
    * Secondary Button: [Continue]
  * **Actions:**
    * Tapping [Complete My Profile] navigates the user to the Edit Profile Screen (Screen 16). After saving, they are returned to their original context.
    * Tapping [Continue] immediately dismisses the modal and proceeds with the user's original action.

* **Trigger Model 2: Post-Action ("Helpful Suggestion")**
  * This model is used when securing the user's action without friction is the top priority.
  * **Applies To:**
    * **Invited Collaborators:** When a user taps [Accept] on a pending proposal in the "My Events" Hub (Screen 12).
  * **Behavior:** The primary action (accepting the gig) is sent to the backend and confirmed first. The modal appears after the action is successful.
  * **Content:**
    * Headline: "You're on the team!"
    * Body Text: "To make sure you look great on the public event page, we suggest adding a photo and bio to your profile."
    * Primary Button: [Complete My Profile]
    * Secondary Button: [Maybe Later]
  * **Actions:**
    * Tapping [Complete My Profile] navigates the user to the Edit Profile Screen (Screen 16).
    * Tapping [Maybe Later] dismisses the modal.

**Screen 23: Cancel Event Confirmation Modal**

* **Purpose:** To prevent a host from accidentally canceling their event and to ensure they understand the consequences of this irreversible action.
* **Trigger:** Tapping the [Cancel Event] button on the Dynamic Event Management Screen (Screen 7).
* **Content:**
  * Headline: "Are you sure you want to cancel?"
  * Body Text: "This action cannot be undone. All registered guests will be notified via email that the event has been canceled, and any payments will be refunded. Are you sure you wish to proceed?"
  * Primary (Destructive) Button: [Yes, Cancel Event]
  * Secondary (Safe) Button: [Nevermind]
* **Actions:**
  * Tapping [Yes, Cancel Event] executes the API call to cancel the event and then navigates the user back to their Dashboard (Screen 4).
  * Tapping [Nevermind] closes the modal, leaving the user on the Dynamic Event Management Screen (Screen 7).

**Screen 24: Message Guest List Modal (Simple UI)**

* **Purpose:** To provide a simple, unified interface for the host to compose and send a broadcast message to all registered guests.
* **Trigger:** Tapping the [Message Guest List] button on the Dynamic Event Management Screen (Screen 7).
* **Backend Logic:**
  * The message is sent via SMS to all guests who have a phone_number on their profile.
  * The message is sent via email to any guests who do not have a phone number.
  * For all messages sent via email, the system will auto-generate the subject line using the format: "A message from the host of [Event Title]".
* **Content (Static UI):** The modal will always display the same simple interface.
  * Headline: "Message All Guests"
  * Info Text: 
    * For paid/donation events: "This will be sent via SMS to guests with a phone number and via email to all others."
    * For Free RSVP events: Shows checkboxes: "Send to: [✓] All confirmed guests [✓] Include maybes"
  * Input Field: A multi-line text area labeled "Message".
  * Primary Button: [Send Message]
  * Secondary Button: [Cancel]
* **Actions:**
  * Tapping [Send Message] validates that the message field is not empty, triggers the POST /api/events/:id/broadcast endpoint, shows a confirmation toast ("Message Sent!"), and closes the modal.
  * Tapping [Cancel] closes the modal without sending a message.

**Screen 25: Mandatory Profile Initialization Gate**

* **Purpose**: To act as a mandatory gate for any user who has not yet set a unique username or provided a phone number, ensuring all active mobile app users have the necessary data to participate fully in the Micasa community.
* **Trigger**: This screen will appear as a blocking modal immediately after app launch (over the Dashboard) on **every session** if any of the following conditions are met for the logged-in user:
   * `user.phone_number` IS NULL
   * OR `user.username` IS NULL
   * OR `user.is_username_autogenerated` IS TRUE
* **Behavior**: This is **not an optional or dismissible modal**. The user cannot access the rest of the app until they complete this step.
* **Content**:
   * **Headline**: "Welcome to the Community!"
   * **Body Text**: "Let's get your profile ready. What should we call you, and how can we reach you?"
   * **Input Field 1**: "Username" (pre-filled with their current username if exists, empty if null).
   * **Input Field 2**: "Phone Number" (pre-filled if exists, empty if null).
   * **Primary Button**: `[Complete Setup]`
* **Action**:
   * Both fields are mandatory. The button is disabled until both are filled.
   * Tapping `[Complete Setup]` will call the `PUT /api/users/me` endpoint to update their profile. On success, the modal is dismissed and the user can interact with the app. On failure (e.g., username taken), an error message is displayed.

### **Part 5: Post-Event Experience Screens**

### **Screen 27: Social Settlement Screen**

* **Purpose:** To create a powerful, emotional, and shareable summary after a monetized event concludes, transparently celebrating financial success while honoring the full creative team.
* **Trigger:** 
  * From Screen 12 (My Events Hub - Past tab): Tapping a past monetized event
  * From Screen 7.1 (Confirm Payouts): Automatically navigated after confirming payouts
  * From Push Notification: Direct deep link sent after event concludes
* **Access:** All event participants (hosts, co-hosts, collaborators, and attendees) can view this screen with role-specific visibility levels.
* **Content:**
  * **Payout Nudge Banner (Host only, conditional)**: If payouts haven't been triggered yet:
    * "💰 Payouts pending - [Confirm & Trigger Payouts]"
  * **Header Section:**
    * Celebratory headline (e.g., "🎉 Amazing Event!")
    * Event title, date, and location
    * Event cover image
  * **Section 1: Payout Summary (Visibility varies by role)**
    * **For Hosts & Co-hosts:**
      * Gross Revenue display
      * Platform and processing fees (transparent breakdown)
      * Net Payout amount (highlighted)
      * Full list of all paid collaborators with:
        * Profile picture and name
        * Role
        * Individual payout amount for each person
    * **For Team Members (Regular Collaborators):**
      * Gross Revenue display
      * Platform and processing fees (transparent breakdown)
      * Net Payout amount (highlighted)
      * Limited payout visibility:
        * Only their own payout amount displayed prominently
        * Other collaborators listed by name and role but payout amounts hidden
        * Personal earnings highlighted: "Your earnings: $XXX"
    * **For Attendees:**
      * No access to Section 1 (financial data hidden)
  * **Section 2: The Full Creative Team (Visible to all participants)**
    * Honors ALL contributors (both paid and unpaid)
    * Each person shown with:
      * Profile picture
      * Name
      *Custom role title
  * **Section 3: Team Promotional Impact (Visible to all team members, hidden from regular attendees)**
    * Header: "Team Promotional Impact 🎯"
    * For each team member who shared the event:
      * Profile picture + Name + Role
      * "Brought in: X attendees"
      * "Generated: $Y in revenue"
      * 🏆 indicator for top promoter
    * User's own stats highlighted with different background color
    * Tappable rows for detailed breakdown showing:
      * Time-based graph of their referrals
      * Which ticket types were purchased
  * **Action Buttons:**
    * [Export Data] - Generates detailed CSV report (host and co-host only)
* **Actions:**
  * Tapping the payout nudge banner navigates to **Screen 7.1: Confirm Payouts Screen**
  * Tapping any collaborator navigates to their public profile (Screen 15)
  * [Export Data] triggers download of comprehensive event report (includes all financial data)

### **Screen 28: Collaborative Snapshot Screen**

* **Purpose:** To validate and celebrate the social and creative success of collaborative events without direct monetization, emphasizing community impact over financial metrics.
* **Trigger:**
  * From Screen 12 (My Events Hub - Past tab): Tapping a past free event
  * From Push Notification: Direct deep link sent after event concludes
* **Access:** All event participants can view this screen.
* **Content:**
  * **Header Section:**
    * Celebratory headline (e.g., "✨ What a Success!")
    * Event title, date, and location
    * Event cover image
  * **Impact Metrics Section (Visible to all):**
    * Number of Attendees (with visual representation)
    * Number of Performers/Contributors
    * Other relevant metrics (e.g., "3 Bands Performed", "5 Artists Exhibited")
    * Community growth metrics (e.g., "23 new connections made")
  * **The Creative Team Section (Visible to all):**
    * Prominent display of all collaborators
    * Each person shown with:
      * Profile picture
      * Name
      * Custom role title
  * **Team Reach & Impact (Visible to team members only, hidden from attendees):**
    * Shows each collaborator's social contribution:
      * "Sarah brought 12 friends"
      * "Mike's network added 8 attendees"
      * Visual indicators for impact levels
    * Celebrates social reach without monetary values
  * **Action Buttons:**
    * [Export Guest List] - CSV download (host and co-host only)
* **Actions:**
  * Tapping any collaborator navigates to their public profile (Screen 15)
  * [Export Guest List] downloads attendee data for future event planning

---

**Change Log:**
- v2.4: Updated Screen 26 to Initial Profile Setup (replacing Screen 25)
- v2.5: Integrated Event-Based Community Feature across Screens 7.2, 9, 14, 18.1, and 19. Added [Import to My Community] buttons, event grouping toggles, and streamlined collaborator selection with context-aware UI elements.
- v2.6: Consolidated Screens 25 and 26 into a single Mandatory Profile Initialization Gate that handles all cases of incomplete profile data.
- v3.0: Major update incorporating post-event experience engine and navigation refinements:
  - Renamed "My Gigs" to "My Events" Hub throughout
  - Added Screen 27: Social Settlement Screen for monetized events
  - Added Screen 28: Collaborative Snapshot Screen for free events
  - Integrated referral parameter tracking in all share functions
  - Added "Who's Going" logic tied to guest list visibility
  - Added "Past Events" section to user profiles (Screen 15)
  - Added privacy controls for "Past Events" in Screen 16
  - Refined Dashboard (Screen 4) to be lean and forward-looking
  - Added Smart Link navigation for pending items
  - Enhanced Screen 12 with permanent access to post-event summaries
  - Added promotional impact tracking for hosts
- v3.2: Major update incorporating three feature enhancements:
  - Implemented three-tier guest list visibility system (Public/Attendees Live/Private)
  - Added co-host role with elevated privileges distinct from regular collaborators
  - Made referral tracking explicit throughout with UI hints and impact celebration
  - Updated Screen 27 with role-based financial visibility
  - Added profit share transparency across all team views
- v4.0: UX Refinements update:
  - Added Screen 12.1: Proposal Details for comprehensive proposal viewing
  - Updated Screen 4 with specific Smart Link navigation logic
  - Enhanced Screen 12 Pending tab with detailed card specifications
  - Updated Screen 17 to use in-app browser for invitations
  - Added application state management to prevent duplicates
  - Clarified Event Team Display in proposal details screen