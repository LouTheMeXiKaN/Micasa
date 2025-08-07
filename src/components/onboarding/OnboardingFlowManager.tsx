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
  const handleAccountCreated = async (provider: 'google' | 'apple' | 'email', credentials?: { email: string; password: string }) => {
    try {
        const result = await api.createProvisionalAccount(provider, credentials);
        setUserId(result.userId);
        // W-8 Requirement: Auto-send OTP when this step loads (Step 2)
        await api.sendOTP(proposal.invited_phone_number);
        setStep('W8_VERIFICATION');
    } catch (error) {
        alert('Account creation failed. Please try again.');
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