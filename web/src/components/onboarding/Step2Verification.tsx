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
          ✨ Welcome! As a co-host, you&apos;ll have access to guest management tools and your own promotional link.
        </div>
      ) : (
        <div className="mb-6 p-4 bg-background rounded-lg">
           Welcome to the team! You&apos;ll receive your personal referral link to track your promotional impact.
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
          placeholder="Enter the 6-digit code sent via SMS"
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