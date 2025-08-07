// src/components/event/EventPageClientWrapper.tsx
"use client";

import { useState } from 'react';
import { EventDetails, UserEventContext, OpenPosition, User } from '@/types/index';
import { OpenPositionsList } from './OpenPositionsList';
import { EventCTAs } from './EventCTAs';
import { ApplicationModal } from '../application/ApplicationModal';
import { useRouter } from 'next/navigation';

interface EventPageClientWrapperProps {
    event: EventDetails;
    context: UserEventContext;
    currentUser: User | null;
    children: React.ReactNode;
}

export const EventPageClientWrapper: React.FC<EventPageClientWrapperProps> = ({ event, context, currentUser, children }) => {
    const router = useRouter();
    const [isApplicationModalOpen, setIsApplicationModalOpen] = useState(false);
    const [selectedPosition, setSelectedPosition] = useState<OpenPosition | null>(null);
    // We need to manage context client-side if it can change (e.g., after applying)
    const [currentContext, setCurrentContext] = useState(context);

    const handleApplyClick = (position: OpenPosition) => {
        setSelectedPosition(position);
        setIsApplicationModalOpen(true);
    };

    const handleApplicationSuccess = () => {
        setIsApplicationModalOpen(false);
        setSelectedPosition(null);

        // Update context locally to reflect the application (disable the button)
        if (selectedPosition) {
            setCurrentContext(prev => ({
                ...prev,
                has_applied_to_position_ids: [...prev.has_applied_to_position_ids, selectedPosition.position_id]
            }));
        }

        // Optionally navigate to W-5 (Success Page)
        router.push('/success?type=application');
    };

    return (
        <>
            {children}

            <OpenPositionsList
                positions={event.open_positions}
                context={currentContext}
                onApplyClick={handleApplyClick}
            />

            <EventCTAs event={event} context={currentContext} />

            {/* W-4 Modal Instance */}
            {selectedPosition && (
                <ApplicationModal
                    isOpen={isApplicationModalOpen}
                    onClose={() => setIsApplicationModalOpen(false)}
                    position={selectedPosition}
                    currentUser={currentUser}
                    onSuccess={handleApplicationSuccess}
                />
            )}
        </>
    );
};