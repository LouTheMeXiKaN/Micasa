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
    alert(`Checkout/RSVP flow (W-2) will be implemented in the next stage.`);
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