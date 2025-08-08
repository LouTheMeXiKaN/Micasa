# Micasa Web Frontend - Stage 1.4 Implementation

## Overview
This is the Micasa Web Frontend implementation for Stage 1.4, built with Next.js 15, TypeScript, and Tailwind CSS. The application implements the core web-facing screens (W-1, W-4, W-8, W-9, W-5) and is configured to make **REAL API calls** to the backend.

## ✅ Implementation Status

### Completed Features
1. **W-1: Public Event Page** - View event details with team, attendees, and open positions
2. **W-4: Application Modal** - Multi-step flow for applying to open positions
3. **W-8: Collaborator Onboarding Gate** - Two-step account creation and phone verification
4. **W-9: Profile Augmentation Nudge** - Optional profile completion step
5. **W-5: Success Page** - Confirmation screens for applications and proposals

### Key Highlights
- **Real Backend Integration**: All API calls in `/src/lib/api.ts` use actual `fetch()` calls to `https://api.micasa.events/v1`
- **Micasa Design System**: Implemented with custom color palette (#FF6B35 accent orange)
- **Responsive Design**: Mobile-first approach with responsive layouts
- **Type Safety**: Full TypeScript implementation with interfaces matching API Contract 1.4
- **Modern Stack**: Next.js 15 with App Router, React Server Components, and Tailwind CSS

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation
```bash
# Navigate to the web directory
cd web

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Update .env.local with your API URL if different
# NEXT_PUBLIC_API_URL=https://api.micasa.events/v1
```

### Development
```bash
# Run the development server
npm run dev

# Open http://localhost:3000
```

### Build
```bash
# Build for production
npm run build

# Start production server
npm start
```

## 📁 Project Structure

```
web/
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── events/[eventId]/   # W-1: Event page
│   │   ├── onboarding/         # W-8/W-9: Onboarding flow
│   │   ├── success/            # W-5: Success page
│   │   └── page.tsx            # Landing page with test links
│   ├── components/
│   │   ├── common/             # Reusable components (Badge, Modal, etc.)
│   │   ├── event/              # Event-related components
│   │   ├── application/        # Application modal components
│   │   └── onboarding/         # Onboarding flow components
│   ├── lib/
│   │   └── api.ts              # API client with REAL backend calls
│   └── types/
│       └── index.ts            # TypeScript interfaces
├── public/                     # Static assets
└── .env.example               # Environment variables template
```

## 🔌 API Integration

All API functions are implemented in `/src/lib/api.ts` and make real HTTP requests to the backend:

- `getCurrentUser()` - Get authenticated user profile
- `getEventDetails()` - Fetch event details with user context
- `submitApplication()` - Apply for an open position
- `getProposalDetails()` - Get collaboration proposal details
- `createProvisionalAccount()` - Create account via OAuth or email
- `sendOTP()` - Send phone verification code
- `verifyAndFinalizeOnboarding()` - Complete onboarding process
- `updateProfile()` - Update user profile and avatar

## 🧪 Testing the Application

### Test Links (from landing page)
1. **Event Page**: `/events/test-event-123` (replace with real event ID)
2. **Onboarding**: `/onboarding/collaborator?proposalId=test-proposal-456` (replace with real proposal ID)
3. **Success Pages**: `/success?type=application` or `/success?type=proposal`

### Important Notes
- OAuth authentication (Google/Apple) requires provider setup
- File uploads require backend storage configuration
- OTP verification requires SMS service (Twilio) integration
- Replace mock IDs with real data from your backend

## 🎨 Design System

The application implements the Micasa design system with:
- **Colors**: Primary orange (#FF6B35), warm background (#F9F8F4)
- **Typography**: Inter font family
- **Components**: Consistent buttons, cards, forms, and modals
- **Responsive**: Mobile-first with breakpoints for tablet and desktop

## 📝 Future Enhancements

Features planned for future stages:
- W-2: Conditional Checkout & RSVP Flow
- W-3: Proposal Acceptance Page
- W-6: Hyperwallet Onboarding Modal
- W-7: Public User Profile Page
- Enhanced error handling and loading states
- Progressive Web App features
- Internationalization support

## 🐛 Known Issues

- OAuth providers need to be configured
- Some ESLint warnings in build (non-critical)
- Avatar uploads need backend storage setup
- OTP verification requires SMS service integration

## 📞 Support

For issues or questions about the implementation, please refer to the project documentation or contact the development team.