// src/app/events/[eventId]/page.tsx
import { getEventDetails, getCurrentUser } from '@/lib/api';
import { EventHeader } from '@/components/event/EventHeader';
import { EventTeam } from '@/components/event/EventTeam';
import { WhoIsGoing } from '@/components/event/WhoIsGoing';
import { EventPageClientWrapper } from '@/components/event/EventPageClientWrapper';
import { Metadata } from 'next';
import { notFound } from 'next/navigation';

interface EventPageProps {
  params: Promise<{ eventId: string }>;
  searchParams: Promise<{ ref?: string; invitation_id?: string }>;
}

// Dynamic Metadata for SEO/Sharing
export async function generateMetadata({ params }: EventPageProps): Promise<Metadata> {
    const resolvedParams = await params;
    try {
        const { details } = await getEventDetails(resolvedParams.eventId);
        return {
          title: `${details.title} | Micasa Events`,
          description: details.description || 'Join us for this amazing event!',
        };
    } catch (error) {
        return { title: 'Event Not Found | Micasa Events' };
    }
  }

export default async function EventPage({ params, searchParams }: EventPageProps) {
  const resolvedParams = await params;
  const resolvedSearchParams = await searchParams;
  const { eventId } = resolvedParams;

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
  if (resolvedSearchParams.invitation_id) {
    // W-1 Requirement: Display personalized invitation banner (if needed)
    console.log("Invitation context detected:", resolvedSearchParams.invitation_id);
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