// src/app/onboarding/collaborator/page.tsx
import { getProposalDetails } from '@/lib/api';
import { OnboardingFlowManager } from '@/components/onboarding/OnboardingFlowManager';
import { Suspense } from 'react';
import { Metadata } from 'next';

interface OnboardingPageProps {
  searchParams: Promise<{ proposalId?: string }>;
}

export const metadata: Metadata = {
    title: 'Collaborator Onboarding | Micasa',
};

async function OnboardingContent({ searchParams }: OnboardingPageProps) {
    const resolvedSearchParams = await searchParams;
    const { proposalId } = resolvedSearchParams;

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

// Next.js requires Suspense if a child component uses searchParams
export default function OnboardingPage({ searchParams }: OnboardingPageProps) {
    return (
      <Suspense fallback={<div className="text-center p-8 mt-10">Loading onboarding...</div>}>
          <OnboardingContent searchParams={searchParams} />
      </Suspense>
    );
  }