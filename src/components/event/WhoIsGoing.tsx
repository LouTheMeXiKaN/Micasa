// src/components/event/WhoIsGoing.tsx
import { EventDetails, UserEventContext } from '@/types/index';
import { UserProfileLink } from '../common/UserProfileLink';

interface WhoIsGoingProps {
  event: EventDetails;
  context: UserEventContext;
}

export const WhoIsGoing: React.FC<WhoIsGoingProps> = ({ event, context }) => {
  const { guest_list_visibility, attendee_count, attendees } = event;
  const { role } = context;

  // Rule: Hosts, Co-hosts, and Collaborators always see the full list (SOW 5).
  if (role === 'host' || role === 'cohost' || role === 'collaborator') {
    return renderFullList(attendee_count, attendees);
  }

  // Rule: Handle visibility settings for others
  switch (guest_list_visibility) {
    case 'private':
      // Private: Hidden to everyone else.
      return null;

    case 'public':
      // Public: Always visible to everyone.
      return renderFullList(attendee_count, attendees);

    case 'attendees_live':
      // Attendees Live Logic:
      if (role === 'attendee') {
        const now = new Date();
        const startTime = new Date(event.start_time);
        const isLiveOrPast = now >= startTime;

        if (isLiveOrPast) {
          return renderFullList(attendee_count, attendees);
        } else {
          // Pre-event: Show count only
          return renderCountOnly(attendee_count, "Full guest list will be available once the event begins.");
        }
      }

      // Public users (non-attendees) see nothing for 'attendees_live'.
      return null;

    default:
      return null;
  }
};

const renderFullList = (count: number, attendees: EventDetails['attendees']) => (
  <section className="mb-10">
    <h2 className="text-2xl font-semibold mb-5">Who&apos;s Going ({count})</h2>
    {count === 0 ? (
      <p className="text-text-secondary">Be the first to RSVP!</p>
    ) : (
      <div className="space-y-4">
        {attendees.slice(0, 5).map(user => (
          <UserProfileLink key={user.user_id} user={user} size="small" />
        ))}
        {count > 5 && <p className="text-text-secondary mt-4">...and {count - 5} others.</p>}
      </div>
    )}
  </section>
);

const renderCountOnly = (count: number, message: string) => (
    <section className="mb-10">
        <h2 className="text-2xl font-semibold mb-5">Who&apos;s Going</h2>
        <div className='p-5 bg-surface rounded-lg shadow-soft'>
            <p className="text-xl font-bold">{count} people are attending</p>
            <p className="text-sm text-text-secondary mt-2">{message}</p>
        </div>
    </section>
);