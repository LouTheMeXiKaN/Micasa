# Micasa Web App - Screen List v2.4 (Updated Sections)

**Version: 2.4**  
**Status: Current**  
**Last Updated: December 2024**

### **Theme & Style Guide**

* **Overall Vibe**: Fast, clean, and transactional. The design should be an extension of the mobile app's "Brooklyn creative professional" theme but optimized for web browsers on both desktop and mobile.  
* **Fonts & Colors**: Should be identical to the mobile app's style guide for brand consistency.

### **Part 1: Guest-Facing Experience**

#### **Screen W-1: Public Event Page**

* **Purpose**: To display all public information for a specific event and serve as the primary landing page for guests and potential collaborators.
* **Trigger**: Accessing a direct event URL shared by a host or another guest.
* **Content**:
    * Event Cover Image.
    * Event Title, Date, and Time.
    * Event Description.
    * Location (Full address or neighborhood, depending on host's privacy setting).
    * **Event Team Display:**
        * Shows the complete creative team for the event.
        * Includes Host, Co-hosts, and all Collaborators.
        * Each person displays: Profile picture, Name, and role badge ("Host", "Co-host", or role title for collaborators).
        * All profiles are clickable and navigate to their public profile page.
    * **"Who's Going" Section (conditional):**
        * **Visibility based on `guest_list_visibility` setting:**
            * **If "public":** Section always visible to everyone.
                * Shows profile pictures and names: "Jane, John, and 23 others are going".
                * Creates FOMO effect for non-attendees.
            * **If "attendees_live":**
                * **For non-attendees:** Section completely hidden (no indication of attendance).
                * **For logged-in attendees:**
                    * **Pre-event:** Shows only count: "25 people are attending".
                    * **During/Post-event:** Shows full "Who's Going" display with names and pictures.
            * **If "private":** Section hidden to everyone except hosts and co-hosts.
    * **Open Positions Section** (if any exist):
        * Each position shows role title and [Apply] button.
    * A primary call-to-action button: `[Buy Ticket]`, `[RSVP]`, or `[Donate]`, depending on the event's pricing model.
        * For authenticated users with an existing RSVP:
            * Instead of `[RSVP]` button, display:
                * Status banner: "✓ You're going!" or "~ You're interested (Maybe)".
                * `[Change RSVP Status]` button.
            * **When clicked**: Opens modal matching mobile UI with Going/Maybe/Not Going options.
            * Updates page state without refresh after selection.
    * **A secondary call-to-action button: `[Apply to Collaborate]` (conditional).**
        * **Visibility:** This button is only visible if the event has one or more open positions.
        * **Purpose:** Provides a clear, high-visibility pathway for potential collaborators, creating a dual funnel for both guests and applicants.
        * **Style:** Must be styled as a secondary button (e.g., outline/ghost style) to not visually compete with the primary CTA.
* **Technical Behavior:**
    * The page preserves any referral parameters in the URL (`?ref=[user_id]`) for backend attribution tracking.
    * These parameters persist through the entire user journey (checkout, application, etc.).
* **Actions**:
    * Tapping the primary CTA button begins the *Conditional Checkout & RSVP Flow (W-2)*.
    * Tapping on a Host or Co-Host's profile navigates to their *Screen W-7: Public User Profile Page*.
    * Tapping `[Apply]` on an open position navigates to *Screen W-4: Open Position Application Form*.
    * **Tapping the secondary `[Apply to Collaborate]` button smoothly scrolls the page viewport to the 'Open Positions' section.**

#### Screen W-2: Conditional Checkout & RSVP Flow

* **Purpose**: To handle guest actions based on the event's specific pricing model. The flow is conditional.
* **Trigger**: Clicking the primary CTA button on the *Public Event Page (W-1)*.
* **Flow A: For "Fixed Price" or "Choose Your Price" Events**
  #### **Flow A: For "Fixed Price" or "Choose Your Price" Events**

* **Purpose**: To handle a mandatory payment.
* **Content**: A sequence of steps within a modal:
    1.  **Authentication (for new/logged-out users):** The modal first presents the low-friction social authentication options, mirroring the mobile app's primary authentication screen.
        * The initial view contains:
            * Primary Button: `[Continue with Google]`
            * Primary Button: `[Continue with Apple]`
            * Secondary Link/Button: `[Continue with Email]`
        * If the user selects `[Continue with Email]`, the modal's content transitions to display a view with two tabs: `[Sign Up]` (selected by default) and `[Log In]`, matching the mobile email authentication flow.
    2.  **Payment:** After successful authentication, the user proceeds to the embedded Stripe interface.
    3.  **Confirmation:** A final screen confirming the purchase.

---

#### **Flow B: For "Donation Based" Events**

* **Purpose**: To handle a simple RSVP first, with an optional donation.
* **Content**: A sequence of steps within a modal:
    1.  **Authentication & RSVP:** The primary action is to RSVP, which requires authentication.
        * The initial view contains:
            * Primary Button: `[Continue with Google]`
            * Primary Button: `[Continue with Apple]`
            * Secondary Link/Button: `[Continue with Email]`
        * If the user selects `[Continue with Email]`, the modal's content transitions to display a view with two tabs: `[Sign Up]` (selected by default) and `[Log In]`, matching the mobile email authentication flow.
        * Upon successful authentication, the user's RSVP is confirmed.
    2.  **Optional Donation**: After the RSVP is confirmed, the modal transitions to a new view.
        * **Content**: A message like, "Thanks for RSVPing! Donations help support the creators." It will feature an optional donation input field and a `[Donate]` button.
        * A clear secondary link like `[Maybe Later]` must be present to allow the user to easily skip the donation step.

* **Post-Purchase Profile Nudge (for new guests)**
    * **Trigger**: Immediately follows the confirmation message for any first-time ticket buyer or RSVP.
    * **Purpose**: To encourage new guests to complete their profile in a non-blocking manner, improving the social proof of the "Who's Going" section.
    * **Content**: A new section appears on the confirmation screen with:
        * **Headline**: "Help the host and other guests recognize you!"
        * **Input 1**: A control for uploading a profile picture.
        * **Input 2**: An optional multi-line text area for the user's bio.
        * **Primary Button**: `[Save & Finish]`
        * **Secondary Link/Button**: `[Skip for Now]`
    * **Behavior**: This is an optional step. Tapping `[Skip for Now]` or closing the modal simply concludes the flow. Tapping `[Save & Finish]` updates the user's profile and then concludes the flow.


### **Part 2: Collaborator Onboarding Experience**

#### **Screen W-3: Proposal Acceptance Page**

* **Purpose**: A dedicated, private page for an invited collaborator to accept or decline a proposal.  
* **Trigger**: Clicking the unique link sent by a Host via the mobile app's invite system.  
* **Content**:  
  * A clear header: "You've been invited to collaborate!"
  * **Invitation Details:**
    * Event Name
    * Host Name (who invited them)
    * Offered Profit Share %
    * **Role indicator** (if applicable): "As a Co-host" badge if `is_cohost: true`
  * Additional context if co-host: "Co-hosts can manage guests, invite team members, and more!"
  * A primary button: `[Accept Proposal]`.  
  * A secondary button: `[Decline]`.  
* **Actions**:  
  * Tapping `[Accept Proposal]` navigates the user to the **Web Collaborator Onboarding Gate (`Screen W-8`)** to begin the account creation and verification process.  
  * Tapping `[Decline]` will show a simple confirmation message (e.g., "Thanks for letting us know") and end the flow.

Screen W-4: Open Position Application Form (Web)
Purpose: To provide a multi-step web form for a new or existing user to apply for an "Open Position" on an event, guiding them through account creation and basic profile completion if necessary.
Trigger: Clicking the [Apply] button next to an open position on the Public Event Page (W-1). Note: Button is disabled if user has already applied.
Content & Detailed Flow: The screen presents a multi-step modal with the following sequence:
Account Creation / Login (Conditional)
Skip if user already has valid session token
Otherwise show login/signup options
Basic Profile Completion (Conditional)
System checks if user has profile photo and bio
If missing: Show profile completion form inline within the modal
Fields:
Profile photo upload
Bio textarea
Instagram handle (optional)
Personal website URL (optional)
User can choose to complete or skip this step
Application Message & Submit
Text area for application message/cover letter
Display position being applied for
Primary button: [Submit Application]
Actions:
Clicking [Submit Application] calls the POST /api/open-positions/:position_id/apply endpoint
Upon successful submission, user is navigated to Screen W-5: App Funnel / Success Page
Modal can be closed at any time, saving progress

Screen W-5: App Funnel / Success Page
Purpose: To confirm a successful action (proposal accepted, application sent) and strongly encourage the user to download the mobile app for the full creator feature set.
Trigger: The final step of any collaborator onboarding flow.
Content:
A success message (e.g., "Proposal Accepted!" or "Application Sent!").
A clear headline: "Get the full experience on the Micasa app."
Prominent buttons to download from the App Store and Google Play.
Actions: Buttons link directly to the respective app stores.


#### **Screen W-8: Web Collaborator Onboarding Gate**

* **Purpose**: To provide a single, cohesive onboarding experience for a new collaborator on the web, guiding them from account creation through to profile finalization and proposal acceptance.  
* **Platform**: Web  
* **Trigger**: Appears after a new, unauthenticated user clicks `[Accept Proposal]` on the **Proposal Acceptance Page (W-3)**.  
* **Content and Flow**: This screen will consist of two sequential steps.  
  
  **Step 1: Account Creation**  
  * **Headline**: "You're Invited! Create an Account to Accept."  
  * **Content**: Displays basic proposal details (Event Name, Host Name) for context.  
  * **Actions**: The user is presented with three options:  
    1. Primary Button: `[Continue with Google]`  
    2. Primary Button: `[Continue with Apple]`  
    3. Secondary Link/Button: `[Sign up with Email]`  
  * **Conditional Flow for Email**: If the user selects "Sign up with Email", the view will expand or transition to show input fields for "Email" and "Password".  
  * **Backend Action**: When the user successfully signs up (via social or email/password), the system creates a **provisional user account** with an auto-generated username and the `is_username_autogenerated` flag set to `TRUE`. The flow immediately proceeds to Step 2.  
  
  **Step 2: Profile & Phone Verification**  
  * **Headline**: "Just one last step..."  
  * **Body Text**: "Please set a unique username and confirm your phone number to finalize your acceptance."  
  * **Additional Context (if co-host invitation):** 
    * "Welcome to the team! As a co-host, you'll have access to guest management tools and your own promotional link."
  * **Additional Context (if regular collaborator):**
    * "Welcome to the team! You'll receive your personal referral link to track your promotional impact."
  * **Input Field 1**: "Username".  
  * **Display Text**: The user's pre-populated phone number is displayed as non-editable text (e.g., "Verifying: +1 555-123-4567").  
  * **Input Field 2**: "Verification Code". The OTP code is **auto-sent** to the displayed number when this step loads.  
  * **Action Link**: "Resend Code".  
  * **Primary Button**: `[Verify & Complete Acceptance]`.  
  * **Backend Action**: Upon successful submission, the system updates the `user` record (with the new username and sets `is_username_autogenerated` to `FALSE`) and updates the `collaboration` record's status to `accepted`.

#### **Screen W-9: Profile Augmentation Nudge (Web)**

* **Purpose**: To provide a non-blocking, optional prompt for a new collaborator to add secondary profile information (picture and bio) immediately after completing their core account creation. This capitalizes on their high intent to make a good impression.  
* **Platform**: Web  
* **Trigger**: Appears as a distinct step in the onboarding flow immediately after the user successfully completes the **Web Collaborator Onboarding Gate (`W-8`)**.  
* **Content**:  
  * **Headline**: "Make a Great First Impression"  
  * **Body Text**: "We highly recommend adding a profile picture and a short bio. It helps the host and other collaborators get to know you."  
  * **Input 1**: A control for uploading a profile picture (this would call the `POST /api/users/me/avatar` endpoint).  
  * **Input 2**: A multi-line text area for the user's bio.  
  * **Primary Button**: `[Save & Continue]`  
  * **Secondary Button**: `[Skip for Now]`  
* **Actions**:  
  * Tapping `[Save & Continue]` will call the `PUT /api/users/me` endpoint to update the user's profile with the new information, then proceed to the next step in the flow (either the Hyperwallet Onboarding on `W-6` or the Success Page on `W-5`).  
  * Tapping `[Skip for Now]` will immediately proceed to the next step in the flow (`W-6` or `W-5`) without saving any information.

### **Part 3: Public Profile View**

#### **Screen W-7: Public User Profile Page**

* **Purpose**: To display the public-facing, non-sensitive information of a Micasa user, allowing potential guests to learn more about event creators.  
* **Trigger**: Clicking on a Host or Co-Host's name/picture from the *Public Event Page (W-1)*.  
* **Content**: A simple, read-only display of the following public user data, sourced from the GET /api/users/:id endpoint:  
  * Profile Picture  
  * Username  
  * Bio  
  * Clickable links for their Instagram Handle and Personal Website (if provided).  
  * **Past Events Section** (conditional):
    * A non-clickable list of past public events where this user was a host or collaborator
    * Each event shows: Event name, date, and role ("Host" or "Co-host" if applicable)
    * Only visible if the user has enabled this in their privacy settings
    * Events listed chronologically (most recent first)
    * *Note: In MVP, these are display-only. Post-MVP enhancement will add clickable public event summary pages.*
* **Actions**: This is primarily a view-only page. Users would navigate away using their browser's back button or by closing the tab.

---

**Change Log:**
- v2.4: Updated to incorporate:
  - Three-tier guest list visibility system (Public/Attendees Live/Private)
  - Co-host role recognition throughout collaborator onboarding
  - Explicit referral tracking and attribution
  - Role badges for hosts and co-hosts
  - Thank you messages for referral-driven conversions
  - Conditional messaging based on event timing and privacy settings