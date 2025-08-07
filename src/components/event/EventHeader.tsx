// src/components/event/EventHeader.tsx
import Image from 'next/image';
import { EventDetails } from '@/types/index';

interface EventHeaderProps {
  event: EventDetails;
}

export const EventHeader: React.FC<EventHeaderProps> = ({ event }) => {
  // Format dates (requires a date library like date-fns in production)
  const formattedDate = new Date(event.start_time).toLocaleDateString('en-US', {
    weekday: 'long', month: 'long', day: 'numeric',
  });
  const formattedTime = new Date(event.start_time).toLocaleTimeString('en-US', {
    hour: 'numeric', minute: '2-digit', hour12: true,
  });

  return (
    <header className="mb-8">
      <div className="relative w-full h-64 md:h-96 mb-6">
        <Image
          src={event.cover_image_url || '/event-placeholder.svg'}
          alt={event.title}
          fill
          className="rounded-xl shadow-soft object-cover"
        />
      </div>
      <h1 className="text-3xl md:text-4xl font-bold text-text-primary mb-4">{event.title}</h1>
      <div className="space-y-3 text-text-secondary text-lg">
        <p className="flex items-center">
          {/* Calendar Icon */}
          <svg className="w-6 h-6 mr-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
          {formattedDate} at {formattedTime}
        </p>
        <p className="flex items-center">
          {/* Location Icon */}
          <svg className="w-6 h-6 mr-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
          {/* Location visibility is handled by the backend, so we display what we receive */}
          {event.location_address}
        </p>
      </div>
    </header>
  );
};