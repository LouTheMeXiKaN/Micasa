
# Micasa MVP: Stage 1.4 Implementation Plan (Web Frontend Initialization)

This document outlines the sequential implementation plan for Stage 1.4 of the Micasa MVP. This stage focuses on setting up the Next.js project and implementing the core web-facing screens (W-1, W-4, W-8, W-9, W-5) according to the provided specifications.

## 1. Project Initialization and Setup

### 1.1 Initialize Next.js Project

Execute the following command in your terminal to initialize the Next.js project with TypeScript, Tailwind CSS, ESLint, and the App Router.

```bash
npx create-next-app@latest micasa-web --typescript --eslint --tailwind --src-dir --app --import-alias "@/*"
```

### 1.2 Navigate to Project Directory

```bash
cd micasa-web
```

### 1.3 Create Core Directories

Execute the following command to create the necessary directory structure within the `src` directory.

```bash
mkdir -p src/components/common
mkdir -p src/components/event
mkdir -p src/components/onboarding
mkdir -p src/components/application
mkdir -p src/lib
mkdir -p src/types
```

## 2. Design System Implementation (Tailwind Configuration & Global Styles)

We will implement the Micasa design system based on the "Brooklyn creative professional" aesthetic, utilizing the accent orange (#FF6B35).

### 2.1 Configure Tailwind CSS

Overwrite the `tailwind.config.ts` file with the following configuration.

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Micasa Palette
        'primary': '#FF6B35', // Accent Orange
        'primary-dark': '#E65119',
        'background': '#F9F8F4', // Light, slightly warm background
        'surface': '#FFFFFF', // Cards and modals
        'text-primary': '#1A1A1A', // Main text
        'text-secondary': '#666666', // Secondary text
        'border-color': '#E0E0E0',
        'success': '#4CAF50',
        'error': '#F44336',
      },
      fontFamily: {
        // Consistent font stack
        sans: ['Inter', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 2px 4px rgba(0, 0, 0, 0.05)',
        'medium': '0 4px 8px rgba(0, 0, 0, 0.1)',
      },
    },
  },
  plugins: [],
};
export default config;
```

### 2.2 Update Global CSS

Overwrite the `src/app/globals.css` file to apply base styles and define utility classes.

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Import Inter font */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

@layer base {
  body {
    @apply bg-background text-text-primary font-sans;
  }
}

/* Utility classes for common components (Design System) */
@layer components {
  .btn-primary {
    @apply bg-primary text-white font-semibold py-3 px-6 rounded-lg shadow-soft hover:bg-primary-dark transition-colors disabled:opacity-50;
  }

  .btn-secondary {
    @apply bg-surface text-text-primary font-semibold py-3 px-6 rounded-lg border border-border-color shadow-soft hover:bg-gray-100 transition-colors disabled:opacity-50;
  }

  .btn-ghost {
    @apply text-text-secondary font-medium py-3 px-6 rounded-lg hover:text-text-primary hover:underline transition-colors disabled:opacity-50;
  }

  .card {
    @apply bg-surface p-6 rounded-xl shadow-medium border border-border-color;
  }

  .input-field {
    @apply block w-full px-4 py-3 border border-border-color rounded-lg bg-surface text-text-primary focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary;
  }
}
```

### 2.3 Update Root Layout

Update `src/app/layout.tsx` to include basic metadata and structure.

```typescript
import type { Metadata } from "next";
// We import the font via CSS in globals.css, so we don't need next/font here unless optimizing
import "./globals.css";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Micasa Events",
  description: "Collaborate, create, and monetize events.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <header className="shadow-soft bg-surface">
            <nav className="container mx-auto px-4 py-4 flex justify-between items-center">
                <Link href="/" className="text-2xl font-bold text-primary">Micasa</Link>
                {/* Placeholder for Auth status */}
                <div className="space-x-4">
                    <Link href="/login" className="text-text-secondary hover:text-primary">Login</Link>
                </div>
            </nav>
        </header>
        <main>
            {children}
        </main>
      </body>
    </html>
  );
}
```

## 3. Core Libraries and Types

### 3.1 Define TypeScript Interfaces

Create the file `src/types/index.ts` and add the following interfaces based on the Database Schema and API Contract.

```typescript
// src/types/index.ts

export interface User {
  user_id: string;
  username: string;
  profile_picture_url?: string | null;
  bio?: string | null;
  is_username_autogenerated: boolean;
}

export type PricingModel = 'fixed_price' | 'choose_your_price' | 'donation_based' | 'free_rsvp';
export type GuestListVisibility = 'public' | 'attendees_live' | 'private';

export interface Event {
  event_id: string;
  host_user_id: string;
  title: string;
  description: string;
  cover_image_url: string;
  start_time: string; // ISO Date string
  end_time: string;
  location_address: string; // Backend handles visibility masking
  status: 'draft' | 'published' | 'live' | 'completed' | 'cancelled';
  pricing_model: PricingModel;
  guest_list_visibility: GuestListVisibility;
}

export interface Collaboration {
  collaboration_id: string;
  user: User;
  role_title: string;
  is_cohost: boolean;
}

export interface OpenPosition {
  position_id: string;
  event_id: string;
  role_title: string;
  description: string;
  profit_share_percentage?: number;
  status: 'open' | 'filled' | 'closed';
}

// Extended type for Event Page (W-1)
export interface EventDetails extends Event {
  team: Collaboration[];
  open_positions: OpenPosition[];
  attendees: User[]; // Only populated if visibility rules allow (handled by backend)
  attendee_count: number;
}

// Represents the current user's context viewing an event (Determined by backend)
export interface UserEventContext {
  is_authenticated: boolean;
  // Role determines access level (SOW 3.2, 3.5)
  role: 'host' | 'cohost' | 'collaborator' | 'attendee' | 'public';
  rsvp_status?: 'going' | 'maybe' | 'not_going' | null;
  has_applied_to_position_ids: string[];
}

export interface ProposalDetails {
    proposal_id: string;
    event: Pick<Event, 'event_id' | 'title'>;
    host: User;
    role_title: string;
    profit_share_percentage: number;
    is_cohost: boolean;
    invited_phone_number: string;
}
```

### 3.2 Define API Utility Functions

Create the file `src/lib/api.ts` and add the following placeholder API functions.

```typescript
// src/lib/api.ts
import { EventDetails, UserEventContext, OpenPosition, ProposalDetails, User } from '@/types/index';

// Placeholder function to simulate API calls
const simulatedApiCall = async <T>(data: T): Promise<T> => {
  console.log('Simulating API call...');
  await new Promise(resolve => setTimeout(resolve, 500));
  return data;
};

// --- Authentication & User Context ---

export const getCurrentUser = async (): Promise<User | null> => {
    // Placeholder: Check session/token
    return simulatedApiCall(null); // Default to unauthenticated
}

// W-1: Fetch Event Details and User Context
// API Endpoint: GET /api/events/:id (with Auth token if available)
export const getEventDetails = async (eventId: string): Promise<{ details: EventDetails, context: UserEventContext }> => {
  // The backend is responsible for determining visibility based on auth token and event settings (SOW 5).

  const mockDetails: EventDetails = {
    event_id: eventId,
    title: "Brooklyn Warehouse Art Show",
    description: "An exploration of contemporary urban art featuring local artists. Live music and refreshments available.",
    cover_image_url: "https://placehold.co/1200x600/png?text=Event+Cover",
    start_time: "2025-09-20T18:00:00Z",
    end_time: "2025-09-20T22:00:00Z",
    location_address: "Secret Location (Revealed to attendees)", // Example of masked location
    pricing_model: 'free_rsvp',
    guest_list_visibility: 'public', // Change this to test visibility logic
    host_user_id: 'host-1',
    status: 'published',
    team: [
      {
        collaboration_id: 'c1', role_title: 'Host', is_cohost: true,
        user: { user_id: 'host-1', username: 'ArtCuratorBK', profile_picture_url: 'https://i.pravatar.cc/150?img=1', is_username_autogenerated: false }
      },
      {
        collaboration_id: 'c2', role_title: 'DJ', is_cohost: false,
        user: { user_id: 'collab-1', username: 'SoundWavez', profile_picture_url: 'https://i.pravatar.cc/150?img=2', is_username_autogenerated: false }
      },
    ],
    open_positions: [
      { position_id: 'p1', event_id: eventId, role_title: 'Videographer', description: 'Capture the event highlights.', status: 'open', profit_share_percentage: 10 },
      { position_id: 'p2', event_id: eventId, role_title: 'Door Manager', description: 'Handle check-ins.', status: 'open' },
    ],
    attendees: [
        { user_id: 'a1', username: 'ArtLover1', profile_picture_url: 'https://i.pravatar.cc/150?img=3', is_username_autogenerated: false },
        { user_id: 'a2', username: 'Brooklynite', profile_picture_url: 'https://i.pravatar.cc/150?img=4', is_username_autogenerated: false },
    ],
    attendee_count: 45,
  };

  // Mock context for an unauthenticated public user
  const mockContext: UserEventContext = {
    is_authenticated: false,
    role: 'public',
    has_applied_to_position_ids: [],
    rsvp_status: null,
  };

  return simulatedApiCall({ details: mockDetails, context: mockContext });
};

// --- W-4: Applications ---

// API Endpoint: POST /api/open-positions/:position_id/apply
export const submitApplication = async (positionId: string, message: string): Promise<{ success: boolean }> => {
  console.log(`Submitting application for ${positionId} with message: ${message}`);
  // Requires authentication
  return simulatedApiCall({ success: true });
};

// --- W-8 & W-9: Onboarding ---

// API Endpoint: GET /api/proposals/:proposalId (Public details for onboarding context)
export const getProposalDetails = async (proposalId: string): Promise<ProposalDetails> => {
    const mockProposal: ProposalDetails = {
        proposal_id: proposalId,
        event: {
            event_id: 'e1',
            title: 'Summer Music Festival',
        },
        host: { user_id: 'h1', username: 'FestivalHost', is_username_autogenerated: false },
        role_title: 'Stage Manager',
        profit_share_percentage: 20,
        is_cohost: true, // Test Co-host flow
        invited_phone_number: '+15551234567',
    };
    return simulatedApiCall(mockProposal);
}

// W-8 Step 1: Simulate Account Creation (Auth Placeholder)
// API Endpoints: POST /api/auth/register or /api/auth/oauth
export const createProvisionalAccount = async (provider: 'google' | 'apple' | 'email', credentials?: any): Promise<{ userId: string }> => {
    console.log(`Creating provisional account via ${provider}`);
    // Simulates creating account with is_username_autogenerated=TRUE (SOW W-8)
    return simulatedApiCall({ userId: 'new-user-id' });
}

// W-8 Step 2: Simulate Sending OTP
// API Endpoint: POST /api/verification/phone/send-code
export const sendOTP = async (phoneNumber: string): Promise<void> => {
    console.log(`Sending OTP to ${phoneNumber}. (Mock: Use 123456 to verify.)`);
}

// W-8 Step 2: Verify OTP, Update Profile, Accept Proposal
// API Endpoints: POST /api/verification/phone/verify-code, PUT /api/users/me, POST /api/proposals/:id/accept
export const verifyAndFinalizeOnboarding = async (userId: string, proposalId: string, username: string, otp: string): Promise<{ success: boolean }> => {
    if (otp !== '123456') {
        return simulatedApiCall({ success: false });
    }
    console.log(`Verified user ${userId}, setting username to ${username}, accepting proposal ${proposalId}.`);
    return simulatedApiCall({ success: true });
}

// W-9 / W-4 Step 2: Update Profile (Bio/Avatar)
// API Endpoints: PUT /api/users/me, POST /api/users/me/avatar
export const updateProfile = async (userId: string, data: { bio?: string, avatarFile?: File }): Promise<{ success: boolean }> => {
    console.log(`Updating profile for ${userId}`, data);
    // Simulate avatar upload if file is present
    return simulatedApiCall({ success: true });
}
```

## 4. Common Components

### 4.1 UserProfileLink Component

Create `src/components/common/UserProfileLink.tsx`.

```typescript
// src/components/common/UserProfileLink.tsx
import Image from 'next/image';
import Link from 'next/link';
import { User } from '@/types/index';

interface UserProfileLinkProps {
  user: Pick<User, 'user_id' | 'username' | 'profile_picture_url'>;
  size?: 'small' | 'medium';
}

export const UserProfileLink: React.FC<UserProfileLinkProps> = ({ user, size = 'medium' }) => {
  const avatarSize = size === 'small' ? 32 : 48;
  const textSize = size === 'small' ? 'text-sm' : 'text-base';

  // Placeholder for when W-7 (Public User Profile Page) is implemented
  const profileUrl = `/users/${user.user_id}`;

  return (
    <Link href={profileUrl} className="flex items-center space-x-3 hover:opacity-80 transition-opacity">
      <Image
        src={user.profile_picture_url || '/default-avatar.png'} // Ensure a default avatar exists in /public
        alt={`${user.username}'s avatar`}
        width={avatarSize}
        height={avatarSize}
        className="rounded-full object-cover"
      />
      <span className={`${textSize} font-medium text-text-primary`}>{user.username}</span>
    </Link>
  );
};
```

### 4.2 Badge Component

Create `src/components/common/Badge.tsx`.

```typescript
// src/components/common/Badge.tsx

interface BadgeProps {
  text: string;
  type?: 'primary' | 'neutral' | 'success';
}

export const Badge: React.FC<BadgeProps> = ({ text, type = 'neutral' }) => {
  let colors = '';
  switch (type) {
    case 'primary':
      colors = 'bg-primary/10 text-primary';
      break;
    case 'success':
      colors = 'bg-success/10 text-success';
      break;
    case 'neutral':
    default:
      colors = 'bg-gray-200 text-text-secondary';
      break;
  }

  return (
    <span className={`inline-block px-3 py-1 text-sm font-medium rounded-full ${colors}`}>
      {text}
    </span>
  );
};
```

### 4.3 Modal Component

Create `src/components/common/Modal.tsx`. This will be used for W-4.

```typescript
// src/components/common/Modal.tsx
import React from 'react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}

export const Modal: React.FC<ModalProps> = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm" onClick={onClose}>
      {/* Stop propagation so clicking inside the modal doesn't close it */}
      <div className="card max-w-lg w-full m-4 max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-text-primary">{title}</h2>
          <button onClick={onClose} className="text-text-secondary hover:text-text-primary text-3xl leading-none">
            &times;
          </button>
        </div>
        <div>
          {children}
        </div>
      </div>
    </div>
  );
};
```

## 5. Implementation: Screen W-1 (Public Event Page) and W-4 (Application Modal)

We will implement W-1 first, and include the W-4 modal triggered from W-1.

**Route:** `/src/app/events/[eventId]/page.tsx`

### 5.1 W-1 Components

#### 5.1.1 EventHeader Component

Create `src/components/event/EventHeader.tsx`.

```typescript
// src/components/event/EventHeader.tsx
import Image from 'next/image';
import { EventDetails } from '@/types/index';

interface EventHeaderProps {
  event: EventDetails;
}

export const EventHeader: React.FC<EventHeaderProps> = ({ event }) => {
  // Format dates (requires a date library like date-fns in production)
  const formattedDate = new Date(event.start_time).toLocaleDateString('en-US', {
    weekday: 'long', month: 'long', day: 'numeric',
  });
  const formattedTime = new Date(event.start_time).toLocaleTimeString('en-US', {
    hour: 'numeric', minute: '2-digit', hour12: true,
  });

  return (
    <header className="mb-8">
      <div className="relative w-full h-64 md:h-96 mb-6">
        <Image
          src={event.cover_image_url}
          alt={event.title}
          layout="fill"
          objectFit="cover"
          className="rounded-xl shadow-soft"
        />
      </div>
      <h1 className="text-3xl md:text-4xl font-bold text-text-primary mb-4">{event.title}</h1>
      <div className="space-y-3 text-text-secondary text-lg">
        <p className="flex items-center">
          {/* Calendar Icon */}
          <svg className="w-6 h-6 mr-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
          {formattedDate} at {formattedTime}
        </p>
        <p className="flex items-center">
          {/* Location Icon */}
          <svg className="w-6 h-6 mr-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
          {/* Location visibility is handled by the backend, so we display what we receive */}
          {event.location_address}
        </p>
      </div>
    </header>
  );
};
```

#### 5.1.2 EventTeam Component

Create `src/components/event/EventTeam.tsx`.

```typescript
// src/components/event/EventTeam.tsx
import { Collaboration } from '@/types/index';
import { UserProfileLink } from '../common/UserProfileLink';
import { Badge } from '../common/Badge';

interface EventTeamProps {
  team: Collaboration[];
}

export const EventTeam: React.FC<EventTeamProps> = ({ team }) => {
  if (team.length === 0) return null;

  return (
    <section className="mb-10">
      <h2 className="text-2xl font-semibold mb-5">The Team</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {team.map(member => {
          // W-1 Requirement: Display role badges
          let roleText = member.role_title;
          if (member.role_title === 'Host') {
            roleText = 'Host';
          } else if (member.is_cohost) {
            roleText = 'Co-host';
          }

          return (
            <div key={member.collaboration_id} className="flex items-center justify-between p-4 bg-surface rounded-lg shadow-soft">
              <UserProfileLink user={member.user} />
              <Badge text={roleText} type={roleText === 'Host' || roleText === 'Co-host' ? 'primary' : 'neutral'} />
            </div>
          );
        })}
      </div>
    </section>
  );
};
```

#### 5.1.3 WhoIsGoing Component

Create `src/components/event/WhoIsGoing.tsx`. This component handles the complex visibility logic (W-1, SOW 5).

```typescript
// src/components/event/WhoIsGoing.tsx
import { EventDetails, UserEventContext } from '@/types/index';
import { UserProfileLink } from '../common/UserProfileLink';

interface WhoIsGoingProps {
  event: EventDetails;
  context: UserEventContext;
}

export const WhoIsGoing: React.FC<WhoIsGoingProps> = ({ event, context }) => {
  const { guest_list_visibility, attendee_count, attendees } = event;
  const { role } = context;

  // Rule: Hosts, Co-hosts, and Collaborators always see the full list (SOW 5).
  if (role === 'host' || role === 'cohost' || role === 'collaborator') {
    return renderFullList(attendee_count, attendees);
  }

  // Rule: Handle visibility settings for others
  switch (guest_list_visibility) {
    case 'private':
      // Private: Hidden to everyone else.
      return null;

    case 'public':
      // Public: Always visible to everyone.
      return renderFullList(attendee_count, attendees);

    case 'attendees_live':
      // Attendees Live Logic:
      if (role === 'attendee') {
        const now = new Date();
        const startTime = new Date(event.start_time);
        const isLiveOrPast = now >= startTime;

        if (isLiveOrPast) {
          return renderFullList(attendee_count, attendees);
        } else {
          // Pre-event: Show count only
          return renderCountOnly(attendee_count, "Full guest list will be available once the event begins.");
        }
      }

      // Public users (non-attendees) see nothing for 'attendees_live'.
      return null;

    default:
      return null;
  }
};

const renderFullList = (count: number, attendees: EventDetails['attendees']) => (
  <section className="mb-10">
    <h2 className="text-2xl font-semibold mb-5">Who's Going ({count})</h2>
    {count === 0 ? (
      <p className="text-text-secondary">Be the first to RSVP!</p>
    ) : (
      <div className="space-y-4">
        {attendees.slice(0, 5).map(user => (
          <UserProfileLink key={user.user_id} user={user} size="small" />
        ))}
        {count > 5 && <p className="text-text-secondary mt-4">...and {count - 5} others.</p>}
      </div>
    )}
  </section>
);

const renderCountOnly = (count: number, message: string) => (
    <section className="mb-10">
        <h2 className="text-2xl font-semibold mb-5">Who's Going</h2>
        <div className='p-5 bg-surface rounded-lg shadow-soft'>
            <p className="text-xl font-bold">{count} people are attending</p>
            <p className="text-sm text-text-secondary mt-2">{message}</p>
        </div>
    </section>
);
```

#### 5.1.4 OpenPositionsList Component (Client Component)

Create `src/components/event/OpenPositionsList.tsx`. This is a client component because it handles the click event to open the W-4 modal.

```typescript
// src/components/event/OpenPositionsList.tsx
"use client";

import { OpenPosition, UserEventContext } from '@/types/index';
import { Badge } from '../common/Badge';

interface OpenPositionsListProps {
  positions: OpenPosition[];
  context: UserEventContext;
  onApplyClick: (position: OpenPosition) => void;
}

export const OpenPositionsList: React.FC<OpenPositionsListProps> = ({ positions, context, onApplyClick }) => {
  if (positions.length === 0) return null;

  return (
    <section id="open-positions" className="mb-10">
      <h2 className="text-2xl font-semibold mb-5">Open Positions</h2>
      <div className="space-y-5">
        {positions.map(position => (
          <div key={position.position_id} className="card flex justify-between items-center">
            <div>
              <h3 className="text-xl font-medium">{position.role_title}</h3>
              <p className="text-sm text-text-secondary mt-1">{position.description}</p>
              {position.profit_share_percentage && (
                <div className="mt-2">
                    <Badge text={`${position.profit_share_percentage}% Profit Share`} type="success" />
                </div>
              )}
            </div>
            {renderApplyButton(position, context, onApplyClick)}
          </div>
        ))}
      </div>
    </section>
  );
};

const renderApplyButton = (position: OpenPosition, context: UserEventContext, onClick: (position: OpenPosition) => void) => {
    if (position.status !== 'open') {
        return <button disabled className="btn-secondary">Filled</button>;
    }

    // W-4 Requirement: Prevent duplicate applications (SOW 2.2)
    if (context.has_applied_to_position_ids.includes(position.position_id)) {
        return <button disabled className="btn-secondary bg-success/10 text-success border-success">Applied ✓</button>;
    }

    // Trigger W-4 Modal
    return (
        <button onClick={() => onClick(position)} className="btn-primary">
            Apply
        </button>
    );
}
```

#### 5.1.5 EventCTAs Component (Client Component)

Create `src/components/event/EventCTAs.tsx`. This is a client component to handle button clicks and smooth scrolling.

```typescript
// src/components/event/EventCTAs.tsx
"use client";

import { EventDetails, UserEventContext, PricingModel } from '@/types/index';

interface EventCTAsProps {
  event: EventDetails;
  context: UserEventContext;
}

export const EventCTAs: React.FC<EventCTAsProps> = ({ event, context }) => {
  const hasOpenPositions = event.open_positions.some(p => p.status === 'open');

  const handlePrimaryAction = () => {
    // This should trigger Screen W-2 (Conditional Checkout & RSVP Flow)
    // Implementation of W-2 is out of scope for Stage 1.4.
    console.log(`Triggering W-2 flow for pricing model: ${event.pricing_model}`);
    alert(`Checkout/RSVP flow (W-2) initiated.`);
  };

  // W-1 Requirement: Secondary CTA scrolls smoothly to Open Positions section
  const handleScrollToPositions = (e: React.MouseEvent<HTMLAnchorElement, MouseEvent>) => {
    e.preventDefault();
    document.getElementById('open-positions')?.scrollIntoView({ behavior: 'smooth' });
  };

  // Logic for RSVP status display (W-1 requirement for authenticated users)
  if (context.is_authenticated && context.rsvp_status) {
    return <RSVPStatus context={context} />;
  }

  const primaryButtonText = getButtonText(event.pricing_model);

  return (
    // Sticky Footer CTA
    <div className="fixed bottom-0 left-0 right-0 bg-surface p-5 border-t border-border-color shadow-medium md:static md:p-0 md:border-t-0 md:shadow-none mt-8">
        <div className="container mx-auto max-w-4xl flex flex-col space-y-4 md:flex-row md:space-y-0 md:space-x-4">
            <button
                onClick={handlePrimaryAction}
                className="btn-primary flex-1"
            >
                {primaryButtonText}
            </button>

            {hasOpenPositions && (
                <a
                href="#open-positions"
                onClick={handleScrollToPositions}
                className="btn-secondary flex-1 text-center"
                >
                Apply to Collaborate
                </a>
            )}
        </div>
    </div>
  );
};

const getButtonText = (pricingModel: PricingModel): string => {
    switch (pricingModel) {
      case 'fixed_price':
      case 'choose_your_price':
        return 'Buy Ticket';
      case 'donation_based':
        return 'RSVP & Donate';
      case 'free_rsvp':
        return 'RSVP';
    }
  };

// Placeholder for RSVP management (W-1)
const RSVPStatus: React.FC<{ context: UserEventContext }> = ({ context }) => {
    const handleChangeRSVP = () => {
        alert("Opening RSVP management modal (W-1/W-2 feature).");
    }
    return (
        <div className="p-5 bg-surface rounded-lg shadow-soft border border-border-color flex justify-between items-center mt-8">
            <p className="font-semibold text-lg">
                {context.rsvp_status === 'going' && "✅ You're going!"}
                {context.rsvp_status === 'maybe' && "🤔 You're interested (Maybe)"}
            </p>
            <button onClick={handleChangeRSVP} className="text-primary hover:underline font-medium">
                Change RSVP Status
            </button>
        </div>
    );
};
```

### 5.2 W-4 Implementation (Application Modal)

Create `src/components/application/ApplicationModal.tsx`. This component implements the multi-step flow required by W-4.

```typescript
// src/components/application/ApplicationModal.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { Modal } from '@/components/common/Modal';
import { OpenPosition, User } from '@/types/index';
import { submitApplication, updateProfile, createProvisionalAccount } from '@/lib/api';

interface ApplicationModalProps {
  isOpen: boolean;
  onClose: () => void;
  position: OpenPosition;
  currentUser: User | null;
  onSuccess: () => void;
}

// W-4 defines a multi-step flow: Auth -> Profile Completion -> Application Message
type Step = 'AUTH' | 'PROFILE_NUDGE' | 'APPLICATION_FORM' | 'SUBMITTING';

export const ApplicationModal: React.FC<ApplicationModalProps> = ({ isOpen, onClose, position, currentUser: initialUser, onSuccess }) => {
  const [step, setStep] = useState<Step>('AUTH');
  const [currentUser, setCurrentUser] = useState<User | null>(initialUser);
  const [userId, setUserId] = useState<string | null>(initialUser?.user_id || null);
  const [message, setMessage] = useState('');
  const [bio, setBio] = useState('');
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setCurrentUser(initialUser);
    setUserId(initialUser?.user_id || null);
    determineStep(initialUser);
  }, [initialUser]);

  const determineStep = (user: User | null) => {
    if (!user && !userId) {
        setStep('AUTH'); // W-4 Step 1
    // Check if profile is incomplete (W-4 Step 2 condition)
    } else if (!user?.bio || !user?.profile_picture_url) {
        setStep('PROFILE_NUDGE');
    } else {
        setStep('APPLICATION_FORM'); // W-4 Step 3
    }
  };

  // --- Handlers ---

  const handleAuth = async (provider: 'google' | 'apple') => {
    // Placeholder for authentication (W-4 Step 1)
    setError(null);
    try {
        // Simulate login/signup
        const result = await createProvisionalAccount(provider);
        setUserId(result.userId);
        // Move to next step (Profile Nudge, as new accounts often lack bio/avatar)
        setStep('PROFILE_NUDGE');
    } catch (err) {
        setError('Authentication failed.');
    }
  };

  const handleProfileNudge = async (skip = false) => {
    // (W-4 Step 2)
    setError(null);
    if (!skip && (bio || avatarFile) && userId) {
        try {
            await updateProfile(userId, { bio, avatarFile: avatarFile || undefined });
        } catch (err) {
            setError('Failed to update profile. You can still continue.');
        }
    }
    setStep('APPLICATION_FORM');
  };

  const handleSubmitApplication = async () => {
    // (W-4 Step 3)
    if (!message.trim()) {
        setError('Application message is required.');
        return;
    }
    setStep('SUBMITTING');
    setError(null);
    try {
        const result = await submitApplication(position.position_id, message);
        if (result.success) {
            onSuccess();
        } else {
            throw new Error('Application submission failed.');
        }
    } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred.');
        setStep('APPLICATION_FORM');
    }
  };

  // --- Render Steps ---

  const renderStep = () => {
    switch (step) {
      case 'AUTH':
        return (
          <div>
            <p className="mb-6">You need to sign in or create an account to apply for this position.</p>
            <button onClick={() => handleAuth('google')} className="btn-primary w-full mb-4">Continue with Google (Demo)</button>
            <button onClick={() => handleAuth('apple')} className="btn-primary w-full">Continue with Apple (Demo)</button>
          </div>
        );
      case 'PROFILE_NUDGE':
        return (
          <div>
            <p className="mb-6">Help the host get to know you! A complete profile makes a great first impression.</p>
             <div className="mb-4">
                <label className="block text-sm font-medium mb-2">Profile Picture (Optional)</label>
                <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setAvatarFile(e.target.files?.[0] || null)}
                    className="input-field"
                />
            </div>
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Bio (Optional)</label>
              <textarea
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={3}
                className="input-field"
                placeholder="Tell us about yourself..."
              />
            </div>
            <button onClick={() => handleProfileNudge(false)} className="btn-primary w-full mb-3">Save & Continue</button>
            <button onClick={() => handleProfileNudge(true)} className="btn-ghost w-full">Skip for Now</button>
          </div>
        );
      case 'APPLICATION_FORM':
      case 'SUBMITTING':
        return (
          <div>
            <h3 className="text-xl font-semibold mb-6">Applying for: {position.role_title}</h3>
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Your Message</label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={6}
                className="input-field"
                placeholder="Why are you a good fit for this role?"
                disabled={step === 'SUBMITTING'}
              />
            </div>
            {error && <p className="text-error text-sm mb-4">{error}</p>}
            <button onClick={handleSubmitApplication} className="btn-primary w-full" disabled={step === 'SUBMITTING' || !message.trim()}>
              {step === 'SUBMITTING' ? 'Submitting...' : 'Submit Application'}
            </button>
          </div>
        );
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Apply to Collaborate">
      {renderStep()}
    </Modal>
  );
};
```

### 5.3 W-1 Page Implementation (Server Component with Client Interactivity)

Create the main page file `src/app/events/[eventId]/page.tsx`. We will use a Server Component to fetch the data and a Client Component wrapper to manage the modal state.

#### 5.3.1 EventPageClientWrapper

Create `src/components/event/EventPageClientWrapper.tsx`.

```typescript
// src/components/event/EventPageClientWrapper.tsx
"use client";

import { useState } from 'react';
import { EventDetails, UserEventContext, OpenPosition, User } from '@/types/index';
import { OpenPositionsList } from './OpenPositionsList';
import { EventCTAs } from './EventCTAs';
import { ApplicationModal } from '../application/ApplicationModal';
import { useRouter } from 'next/navigation';

interface EventPageClientWrapperProps {
    event: EventDetails;
    context: UserEventContext;
    currentUser: User | null;
    children: React.ReactNode;
}

export const EventPageClientWrapper: React.FC<EventPageClientWrapperProps> = ({ event, context, currentUser, children }) => {
    const router = useRouter();
    const [isApplicationModalOpen, setIsApplicationModalOpen] = useState(false);
    const [selectedPosition, setSelectedPosition] = useState<OpenPosition | null>(null);
    // We need to manage context client-side if it can change (e.g., after applying)
    const [currentContext, setCurrentContext] = useState(context);

    const handleApplyClick = (position: OpenPosition) => {
        setSelectedPosition(position);
        setIsApplicationModalOpen(true);
    };

    const handleApplicationSuccess = () => {
        setIsApplicationModalOpen(false);
        setSelectedPosition(null);

        // Update context locally to reflect the application (disable the button)
        if (selectedPosition) {
            setCurrentContext(prev => ({
                ...prev,
                has_applied_to_position_ids: [...prev.has_applied_to_position_ids, selectedPosition.position_id]
            }));
        }

        // Optionally navigate to W-5 (Success Page)
        router.push('/success?type=application');
    };

    return (
        <>
            {children}

            <OpenPositionsList
                positions={event.open_positions}
                context={currentContext}
                onApplyClick={handleApplyClick}
            />

            <EventCTAs event={event} context={currentContext} />

            {/* W-4 Modal Instance */}
            {selectedPosition && (
                <ApplicationModal
                    isOpen={isApplicationModalOpen}
                    onClose={() => setIsApplicationModalOpen(false)}
                    position={selectedPosition}
                    currentUser={currentUser}
                    onSuccess={handleApplicationSuccess}
                />
            )}
        </>
    );
};
```

#### 5.3.2 Event Page (Server Component)

Create `src/app/events/[eventId]/page.tsx`.

```typescript
// src/app/events/[eventId]/page.tsx
import { getEventDetails, getCurrentUser } from '@/lib/api';
import { EventHeader } from '@/components/event/EventHeader';
import { EventTeam } from '@/components/event/EventTeam';
import { WhoIsGoing } from '@/components/event/WhoIsGoing';
import { EventPageClientWrapper } from '@/components/event/EventPageClientWrapper';
import { Metadata } from 'next';
import { notFound } from 'next/navigation';

interface EventPageProps {
  params: { eventId: string };
  searchParams: { ref?: string; invitation_id?: string };
}

// Dynamic Metadata for SEO/Sharing
export async function generateMetadata({ params }: EventPageProps): Promise<Metadata> {
    try {
        const { details } = await getEventDetails(params.eventId);
        return {
          title: `${details.title} | Micasa Events`,
          description: details.description,
        };
    } catch (error) {
        return { title: 'Event Not Found | Micasa Events' };
    }
  }

export default async function EventPage({ params, searchParams }: EventPageProps) {
  const { eventId } = params;

  // Fetch data server-side
  const currentUser = await getCurrentUser();
  let details;
  let context;

  try {
    const result = await getEventDetails(eventId);
    details = result.details;
    context = result.context;
  } catch (error) {
    notFound();
  }


  // Handle Referral/Invitation Tracking (Backend logs this via the API call)
  if (searchParams.invitation_id) {
    // W-1 Requirement: Display personalized invitation banner (if needed)
    console.log("Invitation context detected:", searchParams.invitation_id);
  }

  return (
    // Use Client Wrapper to manage interactive elements (CTAs, Modals)
    <div className="container mx-auto px-4 py-8 max-w-4xl">
        <EventPageClientWrapper event={details} context={context} currentUser={currentUser}>
            <EventHeader event={details} />

            <section className="mb-10">
                <h2 className="text-2xl font-semibold mb-5">Description</h2>
                <p className="text-text-primary whitespace-pre-line">{details.description}</p>
            </section>

            <EventTeam team={details.team} />

            <WhoIsGoing event={details} context={context} />

        </EventPageClientWrapper>
         {/* Spacing for the sticky footer CTA */}
         <div className="h-32 md:h-0"></div>
    </div>
  );
}
```

## 6. Implementation: Screens W-8 (Onboarding Gate) and W-9 (Profile Nudge)

These screens form the sequential onboarding flow for invited collaborators (W-8 Step 1 -> W-8 Step 2 -> W-9). We implement this as a multi-step client component on a single page.

**Route:** `/src/app/onboarding/collaborator/page.tsx`

### 6.1 OnboardingFlowManager Component

Create `src/components/onboarding/OnboardingFlowManager.tsx`. This manages the W-8/W-9 flow.

```typescript
// src/components/onboarding/OnboardingFlowManager.tsx
"use client";

import { useState } from 'react';
import { ProposalDetails } from '@/types/index';
import { useRouter } from 'next/navigation';
import { Step1AccountCreation } from './Step1AccountCreation';
import { Step2Verification } from './Step2Verification';
import { Step3ProfileNudge } from './Step3ProfileNudge'; // W-9
import * as api from '@/lib/api';

interface OnboardingFlowManagerProps {
  proposal: ProposalDetails;
}

// W-8 consists of Step 1 (Account) and Step 2 (Verification). W-9 is Step 3 (Nudge).
type Step = 'W8_ACCOUNT' | 'W8_VERIFICATION' | 'W9_NUDGE';

export const OnboardingFlowManager: React.FC<OnboardingFlowManagerProps> = ({ proposal }) => {
  const [step, setStep] = useState<Step>('W8_ACCOUNT');
  const [userId, setUserId] = useState<string | null>(null);
  const router = useRouter();

  // Handle Step 1 Completion (W-8 Part 1)
  const handleAccountCreated = async (provider: 'google' | 'apple' | 'email', credentials?: any) => {
    try {
        const result = await api.createProvisionalAccount(provider, credentials);
        setUserId(result.userId);
        // W-8 Requirement: Auto-send OTP when this step loads (Step 2)
        await api.sendOTP(proposal.invited_phone_number);
        setStep('W8_VERIFICATION');
    } catch (error) {
        alert('Account creation failed.');
    }
  };

  // Handle Step 2 Completion (W-8 Part 2)
  const handleVerificationComplete = async (username: string, otp: string) => {
    if (!userId) return;
    try {
        const result = await api.verifyAndFinalizeOnboarding(userId, proposal.proposal_id, username, otp);
        if (result.success) {
            // Proposal accepted. Move to W-9.
            setStep('W9_NUDGE');
        } else {
            alert('Verification failed. Please check the OTP and username.');
        }
    } catch (error) {
        alert('An error occurred during verification.');
    }
  };

  // Handle Step 3 Completion (W-9)
  const handleNudgeComplete = async (data: { bio?: string, avatarFile?: File }, skipped = false) => {
    if (!userId) return;

    if (!skipped && (data.bio || data.avatarFile)) {
        await api.updateProfile(userId, data);
    }

    // Flow complete. Check for Hyperwallet requirement (W-6, out of scope for 1.4)
    // Navigate to W-5 (Success Funnel)
    router.push('/success?type=proposal');
  };

  return (
    <div className="max-w-lg mx-auto mt-10">
      <div className="card">
        {step === 'W8_ACCOUNT' && (
            <Step1AccountCreation proposal={proposal} onComplete={handleAccountCreated} />
        )}
        {step === 'W8_VERIFICATION' && (
            <Step2Verification proposal={proposal} onComplete={handleVerificationComplete} onResendOTP={() => api.sendOTP(proposal.invited_phone_number)} />
        )}
        {step === 'W9_NUDGE' && (
            <Step3ProfileNudge onComplete={handleNudgeComplete} />
        )}
      </div>
    </div>
  );
};
```

### 6.2 W-8 Step 1: Account Creation

Create `src/components/onboarding/Step1AccountCreation.tsx`.

```typescript
// src/components/onboarding/Step1AccountCreation.tsx
import { ProposalDetails } from '@/types/index';

interface Step1Props {
  proposal: ProposalDetails;
  onComplete: (provider: 'google' | 'apple' | 'email', credentials?: any) => void;
}

export const Step1AccountCreation: React.FC<Step1Props> = ({ proposal, onComplete }) => {
  // Email/Password flow is omitted for brevity, focusing on the primary social auth buttons (W-8 Step 1)

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">You're Invited! Create an Account to Accept.</h1>

      <div className="mb-8 p-5 bg-background rounded-lg border border-border-color">
        <p className="text-lg font-semibold">{proposal.event.title}</p>
        <p className="text-sm text-text-secondary">Invited by: @{proposal.host.username}</p>
        <p className="text-sm font-medium mt-2">Role: {proposal.role_title} ({proposal.profit_share_percentage}% share)</p>
      </div>

      <div className="space-y-4">
        <button
          onClick={() => onComplete('google')}
          className="btn-primary w-full"
        >
          Continue with Google (Demo)
        </button>
        <button
          onClick={() => onComplete('apple')}
          className="btn-primary w-full"
        >
          Continue with Apple (Demo)
        </button>
        <button
          onClick={() => alert('Email flow not implemented in this mock.')}
          className="btn-secondary w-full"
        >
          Sign up with Email
        </button>
      </div>
    </div>
  );
};
```

### 6.3 W-8 Step 2: Verification

Create `src/components/onboarding/Step2Verification.tsx`.

```typescript
// src/components/onboarding/Step2Verification.tsx
import { ProposalDetails } from '@/types/index';
import { useState } from 'react';

interface Step2Props {
  proposal: ProposalDetails;
  onComplete: (username: string, otp: string) => void;
  onResendOTP: () => void;
}

export const Step2Verification: React.FC<Step2Props> = ({ proposal, onComplete, onResendOTP }) => {
  const [username, setUsername] = useState('');
  const [otp, setOtp] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!username.trim() || !otp.trim()) return;
    setIsLoading(true);
    onComplete(username, otp);
    // Note: Loading state isn't perfectly managed here as onComplete might fail in the parent
  };

  return (
    <form onSubmit={handleSubmit}>
      <h1 className="text-2xl font-bold mb-4">Just one last step...</h1>
      <p className="mb-6 text-text-secondary">Please set a unique username and confirm your phone number to finalize your acceptance.</p>

      {/* W-8 Step 2 Contextual Messaging */}
      {proposal.is_cohost ? (
        <div className="mb-6 p-4 bg-primary/10 text-primary rounded-lg">
          ✨ Welcome! As a co-host, you'll have access to guest management tools and your own promotional link.
        </div>
      ) : (
        <div className="mb-6 p-4 bg-background rounded-lg">
           Welcome to the team! You'll receive your personal referral link to track your promotional impact.
        </div>
      )}

      <div className="mb-6">
        <label htmlFor="username" className="block text-sm font-medium mb-2">Username</label>
        <input
          type="text"
          id="username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          className="input-field"
          required
        />
      </div>

      <div className="mb-6">
        <p className="text-sm font-medium mb-2">Verifying Phone Number:</p>
        <p className="font-semibold text-lg">{proposal.invited_phone_number}</p>
      </div>

      <div className="mb-8">
        <label htmlFor="otp" className="block text-sm font-medium mb-2">Verification Code (OTP)</label>
        <input
          type="text"
          id="otp"
          value={otp}
          onChange={(e) => setOtp(e.target.value)}
          className="input-field"
          placeholder="Enter the code sent via SMS (Use 123456)"
          required
        />
        <button type="button" onClick={onResendOTP} className="text-sm text-primary mt-2 hover:underline">
            Resend Code
        </button>
      </div>

      <button
        type="submit"
        className="btn-primary w-full"
        disabled={isLoading || !username || !otp}
      >
        {isLoading ? 'Verifying...' : 'Verify & Complete Acceptance'}
      </button>
    </form>
  );
};
```

### 6.4 W-9: Profile Nudge

Create `src/components/onboarding/Step3ProfileNudge.tsx`.

```typescript
// src/components/onboarding/Step3ProfileNudge.tsx
import { useState } from 'react';

interface Step3Props {
  onComplete: (data: { bio?: string, avatarFile?: File }, skipped?: boolean) => void;
}

export const Step3ProfileNudge: React.FC<Step3Props> = ({ onComplete }) => {
  const [bio, setBio] = useState('');
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSave = async () => {
    setIsLoading(true);
    // Parent handles the actual API call and navigation
    onComplete({ bio, avatarFile: avatarFile || undefined }, false);
  };

  const handleSkip = () => {
    onComplete({}, true);
  };

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
        setAvatarFile(e.target.files[0]);
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Make a Great First Impression</h1>
      <p className="mb-6 text-text-secondary">We highly recommend adding a profile picture and a short bio. It helps the host and other collaborators get to know you.</p>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Profile Picture</label>
        <input
          type="file"
          accept="image/*"
          onChange={handleAvatarChange}
          className="input-field"
        />
      </div>

      <div className="mb-8">
        <label htmlFor="bio" className="block text-sm font-medium mb-2">Bio</label>
        <textarea
          id="bio"
          rows={4}
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          className="input-field"
          placeholder="Tell us a bit about yourself..."
        />
      </div>

      <button
        onClick={handleSave}
        className="btn-primary w-full mb-4"
        disabled={isLoading}
      >
        {isLoading ? 'Saving...' : 'Save & Continue'}
      </button>
      <button
        onClick={handleSkip}
        className="btn-ghost w-full"
        disabled={isLoading}
      >
        Skip for Now
      </button>
    </div>
  );
};
```

### 6.5 Onboarding Page Implementation

Create the page file `src/app/onboarding/collaborator/page.tsx`.

```typescript
// src/app/onboarding/collaborator/page.tsx
import { getProposalDetails } from '@/lib/api';
import { OnboardingFlowManager } from '@/components/onboarding/OnboardingFlowManager';
import { Suspense } from 'react';
import { Metadata } from 'next';

interface OnboardingPageProps {
  searchParams: { proposalId?: string };
}

export const metadata: Metadata = {
    title: 'Collaborator Onboarding | Micasa',
};

async function OnboardingContent({ searchParams }: OnboardingPageProps) {
    const { proposalId } = searchParams;

    if (!proposalId) {
      return <div className="text-center p-8 mt-10">Error: Missing proposal ID. Please use the link provided in your invitation.</div>;
    }

    try {
      // Fetch proposal details server-side to provide context
      const proposal = await getProposalDetails(proposalId);
      return <OnboardingFlowManager proposal={proposal} />;
    } catch (error) {
      return <div className="text-center p-8 mt-10">Error: Invalid or expired proposal ID.</div>;
    }
}

// Next.js requires Suspense if a child component (like OnboardingFlowManager via OnboardingContent) uses searchParams implicitly or explicitly
export default function OnboardingPage({ searchParams }: OnboardingPageProps) {
    return (
      <Suspense fallback={<div className="text-center p-8 mt-10">Loading onboarding...</div>}>
          <OnboardingContent searchParams={searchParams} />
      </Suspense>
    );
  }
```

## 7. Implementation: Screen W-5 (App Funnel / Success Page)

This screen confirms a successful action and encourages the user to download the mobile app.

**Route:** `/src/app/success/page.tsx`

### 7.1 Success Page Implementation

Create the page file `src/app/success/page.tsx`.

```typescript
// src/app/success/page.tsx
"use client";

import { useSearchParams } from 'next/navigation';
import Image from 'next/image';
import { Suspense } from 'react';
import { Metadata } from 'next';

// Metadata cannot be dynamic when using useSearchParams in a client component page directly
// export const metadata: Metadata = { title: 'Success | Micasa' };

const SuccessContent = () => {
    const searchParams = useSearchParams();
    const type = searchParams.get('type'); // 'application' or 'proposal'

    let title = "Success!";
    let message = "Your action was completed successfully.";

    if (type === 'application') {
        title = "Application Sent!";
        message = "The host will review your application shortly.";
    } else if (type === 'proposal') {
        title = "Proposal Accepted!";
        message = "Welcome to the team! You are now officially part of the event.";
    }

    return (
        <div className="max-w-xl mx-auto text-center mt-10">
            <div className="card">
                <div className="text-4xl mb-4">🎉</div>
                <h1 className="text-3xl font-bold text-success mb-4">{title}</h1>
                <p className="text-lg mb-10">{message}</p>

                <div className="border-t border-border-color pt-8 mt-8">
                    <h2 className="text-2xl font-semibold mb-4">Get the full experience on the Micasa app.</h2>
                    <p className="mb-6 text-text-secondary">Manage your events, track your earnings, and connect with your community on the go.</p>

                    <div className="flex justify-center space-x-6">
                        {/* W-5 Actions: Links to App Stores */}
                        <a href="https://apps.apple.com/app/micasa" target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                            {/* Placeholder SVG/PNGs needed in /public */}
                            <img src="/app-store-badge.svg" alt="Download on the App Store" width={160} height={50} />
                        </a>
                        <a href="https://play.google.com/store/apps/details?id=com.micasa" target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                             <img src="/google-play-badge.svg" alt="Get it on Google Play" width={160} height={50} />
                        </a>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default function SuccessPage() {
    return (
        <div className="container mx-auto px-4 py-8">
            {/* Suspense is required when using useSearchParams */}
            <Suspense fallback={<div>Loading...</div>}>
                <SuccessContent />
            </Suspense>
        </div>
    );
}
```

## 8. Finalization

### 8.1 Add Placeholder Images

Ensure placeholder images exist in the `public` directory for the components to work correctly. The agent must download or create these files.

1. `public/default-avatar.png`
2. `public/app-store-badge.svg`
3. `public/google-play-badge.svg`

### 8.2 Create Temporary Landing Page

Create a temporary `src/app/page.tsx` for navigation testing.

```typescript
// src/app/page.tsx
import Link from 'next/link';

export default function Home() {
  return (
    <div className="p-10 container mx-auto">
      <h1 className="text-3xl font-bold mb-6">Micasa Web MVP (Stage 1.4) - Temporary Links</h1>
      <ul className="list-disc pl-5 space-y-3 text-lg">
        <li>
          <Link href="/events/mock-event-1" className="text-primary hover:underline">
            W-1: Public Event Page (Mock Event)
          </Link>
          <p className="text-sm text-text-secondary">Includes W-4 (Application Modal) via 'Apply' buttons.</p>
        </li>
        <li>
          <Link href="/onboarding/collaborator?proposalId=mock-proposal-1" className="text-primary hover:underline">
            W-8 & W-9: Collaborator Onboarding Flow (Mock Proposal)
          </Link>
          <p className="text-sm text-text-secondary">Includes Account Creation, Verification, and Profile Nudge.</p>
        </li>
        <li>
          <Link href="/success?type=application" className="text-primary hover:underline">
            W-5: Success Page (Application Sent)
          </Link>
        </li>
         <li>
          <Link href="/success?type=proposal" className="text-primary hover:underline">
            W-5: Success Page (Proposal Accepted)
          </Link>
        </li>
      </ul>
    </div>
  );
}
```
