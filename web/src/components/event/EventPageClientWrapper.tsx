// src/components/event/EventPageClientWrapper.tsx
"use client";

import { EventDetails, UserEventContext } from '@/types/index';
import { OpenPositions } from './OpenPositions';
import { EventCTAs } from './EventCTAs';

interface EventPageClientWrapperProps {
    event: EventDetails;
    context: UserEventContext;
    currentUser: any;
    children: React.ReactNode;
}

export const EventPageClientWrapper: React.FC<EventPageClientWrapperProps> = ({ event, context, currentUser, children }) => {
    return (
        <>
            {children}

            <OpenPositions positions={event.open_positions} />

            <EventCTAs event={event} context={context} />
        </>
    );
};