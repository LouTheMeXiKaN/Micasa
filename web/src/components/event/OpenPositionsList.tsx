// src/components/event/OpenPositionsList.tsx
"use client";

import { OpenPosition, UserEventContext } from '@/types/index';
import { Badge } from '../common/Badge';

interface OpenPositionsListProps {
  positions: OpenPosition[];
  context: UserEventContext;
  onApplyClick: (position: OpenPosition) => void;
}

export const OpenPositionsList: React.FC<OpenPositionsListProps> = ({ positions, context, onApplyClick }) => {
  if (positions.length === 0) return null;

  return (
    <section id="open-positions" className="mb-10">
      <h2 className="text-2xl font-semibold mb-5">Open Positions</h2>
      <div className="space-y-5">
        {positions.map(position => (
          <div key={position.position_id} className="card flex justify-between items-center">
            <div>
              <h3 className="text-xl font-medium">{position.role_title}</h3>
              <p className="text-sm text-text-secondary mt-1">{position.description}</p>
              {position.profit_share_percentage && (
                <div className="mt-2">
                    <Badge text={`${position.profit_share_percentage}% Profit Share`} type="success" />
                </div>
              )}
            </div>
            {renderApplyButton(position, context, onApplyClick)}
          </div>
        ))}
      </div>
    </section>
  );
};

const renderApplyButton = (position: OpenPosition, context: UserEventContext, onClick: (position: OpenPosition) => void) => {
    if (position.status !== 'open') {
        return <button disabled className="btn-secondary">Filled</button>;
    }

    // W-4 Requirement: Prevent duplicate applications (SOW 2.2)
    if (context.has_applied_to_position_ids.includes(position.position_id)) {
        return <button disabled className="btn-secondary bg-success/10 text-success border-success">Applied ✓</button>;
    }

    // Trigger W-4 Modal
    return (
        <button onClick={() => onClick(position)} className="btn-primary">
            Apply
        </button>
    );
}