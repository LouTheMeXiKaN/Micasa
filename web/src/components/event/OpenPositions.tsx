"use client";

import React, { useState } from 'react';
import { OpenPosition } from '@/types/index';
import { ApplicationModal } from '@/components/application/ApplicationModal';

interface OpenPositionsProps {
  positions: OpenPosition[];
}

export const OpenPositions: React.FC<OpenPositionsProps> = ({ positions }) => {
  const [selectedPosition, setSelectedPosition] = useState<OpenPosition | null>(null);
  const [showApplicationModal, setShowApplicationModal] = useState(false);
  const [appliedPositions, setAppliedPositions] = useState<string[]>([]);

  // Filter only open positions
  const openPositions = positions.filter(p => p.status === 'open');

  if (openPositions.length === 0) {
    return null;
  }

  const handleApply = (position: OpenPosition) => {
    setSelectedPosition(position);
    setShowApplicationModal(true);
  };

  const handleApplicationSuccess = () => {
    if (selectedPosition) {
      // Add to applied positions list
      setAppliedPositions([...appliedPositions, selectedPosition.position_id]);
      
      // Show success message
      alert('Application submitted successfully! The host will review it and get back to you.');
    }
    setShowApplicationModal(false);
    setSelectedPosition(null);
  };

  const isApplied = (positionId: string) => appliedPositions.includes(positionId);

  return (
    <>
      <section id="open-positions" className="mb-10">
        <h2 className="text-2xl font-semibold mb-5">Open Positions</h2>
        <div className="space-y-4">
          {openPositions.map((position) => (
            <div key={position.position_id} className="card p-6">
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <h3 className="text-xl font-semibold mb-2">{position.role_title}</h3>
                  {position.profit_share_percentage && (
                    <p className="text-primary font-medium mb-3">
                      {position.profit_share_percentage}% profit share
                    </p>
                  )}
                  <p className="text-text-primary whitespace-pre-line">
                    {position.description || 'No additional details provided.'}
                  </p>
                </div>
                <div className="ml-4">
                  {isApplied(position.position_id) ? (
                    <button
                      disabled
                      className="btn-secondary px-6 py-2 opacity-50 cursor-not-allowed"
                    >
                      Applied ✓
                    </button>
                  ) : position.status === 'filled' ? (
                    <button
                      disabled
                      className="btn-secondary px-6 py-2 opacity-50 cursor-not-allowed"
                    >
                      Position Filled
                    </button>
                  ) : (
                    <button
                      onClick={() => handleApply(position)}
                      className="btn-primary px-6 py-2"
                    >
                      Apply
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {selectedPosition && (
        <ApplicationModal
          isOpen={showApplicationModal}
          onClose={() => {
            setShowApplicationModal(false);
            setSelectedPosition(null);
          }}
          position={selectedPosition}
          onSuccess={handleApplicationSuccess}
        />
      )}
    </>
  );
};