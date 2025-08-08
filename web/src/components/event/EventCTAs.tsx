// src/components/event/EventCTAs.tsx
"use client";

import { EventDetails, UserEventContext, PricingModel } from '@/types/index';
import { useAuth } from '@/lib/auth-context';
import { useState } from 'react';

interface EventCTAsProps {
  event: EventDetails;
  context: UserEventContext;
}

export const EventCTAs: React.FC<EventCTAsProps> = ({ event, context }) => {
  const hasOpenPositions = event.open_positions.some(p => p.status === 'open');
  const { user, setShowAuthModal, setAuthMode } = useAuth();
  const [isCreatingRSVP, setIsCreatingRSVP] = useState(false);

  const handlePrimaryAction = async () => {
    // Check if user is authenticated
    if (!user) {
      // Open auth modal in signup mode
      setAuthMode('signup');
      setShowAuthModal(true);
      return;
    }

    // User is authenticated, proceed with RSVP
    setIsCreatingRSVP(true);
    try {
      const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://micasa-g1w3.onrender.com';
      const token = localStorage.getItem('token');
      
      // Create RSVP/ticket
      const response = await fetch(`${API_URL}/events/${event.event_id}/rsvp`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          rsvp_status: 'going'
        })
      });

      if (response.ok) {
        // Redirect to success page
        window.location.href = '/success?type=rsvp';
      } else {
        const error = await response.json();
        alert(error.message || 'Failed to RSVP');
      }
    } catch (error) {
      console.error('RSVP error:', error);
      alert('Failed to RSVP. Please try again.');
    } finally {
      setIsCreatingRSVP(false);
    }
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
                disabled={isCreatingRSVP}
                className="btn-primary flex-1 disabled:opacity-50 disabled:cursor-not-allowed"
            >
                {isCreatingRSVP ? 'Processing...' : primaryButtonText}
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
        alert("RSVP management modal will be implemented in the next stage.");
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