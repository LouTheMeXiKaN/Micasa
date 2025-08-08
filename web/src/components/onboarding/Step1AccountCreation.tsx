// src/components/onboarding/Step1AccountCreation.tsx
import { ProposalDetails } from '@/types/index';

interface Step1Props {
  proposal: ProposalDetails;
  onComplete: (provider: 'google' | 'apple' | 'email', credentials?: { email: string; password: string }) => void;
}

export const Step1AccountCreation: React.FC<Step1Props> = ({ proposal, onComplete }) => {
  // Email/Password flow is omitted for brevity, focusing on the primary social auth buttons (W-8 Step 1)

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">You&apos;re Invited! Create an Account to Accept.</h1>

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
          Continue with Google
        </button>
        <button
          onClick={() => onComplete('apple')}
          className="btn-primary w-full"
        >
          Continue with Apple
        </button>
        <button
          onClick={() => alert('Email flow will be implemented with full auth system.')}
          className="btn-secondary w-full"
        >
          Sign up with Email
        </button>
      </div>
      <p className="text-sm text-text-secondary mt-4 text-center">
        Note: OAuth integration is pending. This will connect to the real authentication service.
      </p>
    </div>
  );
};