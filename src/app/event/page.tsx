'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { getEventDetails, getCurrentUser } from '@/lib/api';
import { EventHeader } from '@/components/event/EventHeader';
import { EventTeam } from '@/components/event/EventTeam';
import { WhoIsGoing } from '@/components/event/WhoIsGoing';
import { EventPageClientWrapper } from '@/components/event/EventPageClientWrapper';

function EventContent() {
  const searchParams = useSearchParams();
  const eventId = searchParams.get('id') || 'no-id-provided';
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [eventData, setEventData] = useState<any>(null);
  const [context, setContext] = useState<any>(null);
  const [currentUser, setCurrentUser] = useState<any>(null);

  useEffect(() => {
    const fetchEvent = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch current user (may be null if not logged in)
        const user = await getCurrentUser();
        setCurrentUser(user);
        
        // Fetch event details
        const result = await getEventDetails(eventId);
        setEventData(result.details);
        setContext(result.context);
        
      } catch (err: any) {
        console.error('Error fetching event:', err);
        setError(err.message || 'Failed to load event');
      } finally {
        setLoading(false);
      }
    };

    if (eventId && eventId !== 'no-id-provided') {
      fetchEvent();
    } else {
      setLoading(false);
      setError('No event ID provided');
    }
  }, [eventId]);

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="card max-w-lg mx-auto text-center">
          <div className="animate-pulse">
            <div className="h-64 bg-gray-200 rounded mb-4"></div>
            <div className="h-8 bg-gray-200 rounded mb-4"></div>
            <div className="h-4 bg-gray-200 rounded mb-2"></div>
            <div className="h-4 bg-gray-200 rounded"></div>
          </div>
          <p className="mt-4 text-text-secondary">Loading event...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="card max-w-lg mx-auto text-center">
          <h2 className="text-2xl font-bold text-error mb-4">Error Loading Event</h2>
          <p className="mb-4">{error}</p>
          <button 
            onClick={() => window.location.reload()}
            className="btn-primary"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  if (!eventData) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="card max-w-lg mx-auto text-center">
          <p>Event not found</p>
        </div>
      </div>
    );
  }

  // Handle Referral/Invitation Tracking
  const invitationId = searchParams.get('invitation_id');
  const refId = searchParams.get('ref');
  
  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      {invitationId && (
        <div className="bg-primary/10 border border-primary rounded-lg p-4 mb-6">
          <p className="text-primary font-semibold">
            🎉 You&apos;ve been personally invited to this event!
          </p>
        </div>
      )}
      
      <EventPageClientWrapper event={eventData} context={context} currentUser={currentUser}>
        <EventHeader event={eventData} />

        <section className="mb-10">
          <h2 className="text-2xl font-semibold mb-5">Description</h2>
          <p className="text-text-primary whitespace-pre-line">
            {eventData.description || 'No description provided'}
          </p>
        </section>

        <EventTeam team={eventData.team || []} />

        <WhoIsGoing event={eventData} context={context} />

      </EventPageClientWrapper>
      
      {/* Spacing for the sticky footer CTA */}
      <div className="h-32 md:h-0"></div>
    </div>
  );
}

export default function EventPageFull() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <EventContent />
    </Suspense>
  );
}