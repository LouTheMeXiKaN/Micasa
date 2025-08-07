import Link from 'next/link';

// Mock event IDs for testing
const MOCK_EVENT_ID = 'test-event-123';
const MOCK_PROPOSAL_ID = 'test-proposal-456';

export default function Home() {
  return (
    <div className="p-10 container mx-auto">
      <h1 className="text-3xl font-bold mb-6">Micasa Web MVP (Stage 1.4) - Test Links</h1>
      
      <div className="mb-8 p-6 bg-primary/10 rounded-lg">
        <h2 className="text-xl font-semibold mb-3">Important: Backend Connection</h2>
        <p className="text-sm mb-2">
          ✅ This application is configured to make REAL API calls to: <code className="bg-gray-200 px-2 py-1 rounded">https://micasa-g1w3.onrender.com</code>
        </p>
        <p className="text-sm">
          All API functions in <code className="bg-gray-200 px-2 py-1 rounded">src/lib/api.ts</code> use actual fetch() calls to the backend endpoints.
        </p>
      </div>

      <ul className="list-disc pl-5 space-y-3 text-lg">
        <li>
          <Link href={`/event?id=${MOCK_EVENT_ID}`} className="text-primary hover:underline">
            W-1: Public Event Page
          </Link>
          <p className="text-sm text-text-secondary">
            View event details with team, attendees, and open positions. Includes W-4 (Application Modal) via &apos;Apply&apos; buttons.
          </p>
          <p className="text-xs text-text-secondary mt-1">
            Note: Replace {MOCK_EVENT_ID} with a real event ID from your backend to see actual data.
          </p>
        </li>
        
        <li>
          <Link href={`/onboarding/collaborator?proposalId=${MOCK_PROPOSAL_ID}`} className="text-primary hover:underline">
            W-8 & W-9: Collaborator Onboarding Flow
          </Link>
          <p className="text-sm text-text-secondary">
            Three-step onboarding: Account Creation, Phone Verification, and Profile Completion.
          </p>
          <p className="text-xs text-text-secondary mt-1">
            Note: Replace {MOCK_PROPOSAL_ID} with a real proposal ID from your backend.
          </p>
        </li>
        
        <li>
          <Link href="/success?type=application" className="text-primary hover:underline">
            W-5: Success Page (Application Sent)
          </Link>
          <p className="text-sm text-text-secondary">Shows success message after applying to a position.</p>
        </li>
        
        <li>
          <Link href="/success?type=proposal" className="text-primary hover:underline">
            W-5: Success Page (Proposal Accepted)
          </Link>
          <p className="text-sm text-text-secondary">Shows success message after accepting a collaboration proposal.</p>
        </li>
      </ul>

      <div className="mt-10 p-6 bg-surface border border-border-color rounded-lg">
        <h2 className="text-xl font-semibold mb-3">Testing Notes:</h2>
        <ul className="list-disc pl-5 space-y-2 text-sm">
          <li>OAuth authentication (Google/Apple) requires additional setup with the providers</li>
          <li>File uploads (avatars) require backend storage configuration</li>
          <li>OTP verification requires SMS service integration (Twilio)</li>
          <li>Replace mock IDs with real data from your backend for full functionality</li>
          <li>Some features like W-2 (Checkout) and W-6 (Hyperwallet) are planned for future stages</li>
        </ul>
      </div>
    </div>
  );
}
