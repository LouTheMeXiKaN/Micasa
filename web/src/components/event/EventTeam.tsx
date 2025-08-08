// src/components/event/EventTeam.tsx
import { Collaboration } from '@/types/index';
import { UserProfileLink } from '../common/UserProfileLink';
import { Badge } from '../common/Badge';

interface EventTeamProps {
  team: Collaboration[];
}

export const EventTeam: React.FC<EventTeamProps> = ({ team }) => {
  if (team.length === 0) return null;

  return (
    <section className="mb-10">
      <h2 className="text-2xl font-semibold mb-5">The Team</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {team.map(member => {
          // W-1 Requirement: Display role badges
          let roleText = member.role_title;
          if (member.role_title === 'Host') {
            roleText = 'Host';
          } else if (member.is_cohost) {
            roleText = 'Co-host';
          }

          return (
            <div key={member.collaboration_id} className="flex items-center justify-between p-4 bg-surface rounded-lg shadow-soft">
              <UserProfileLink user={member.user} />
              <Badge text={roleText} type={roleText === 'Host' || roleText === 'Co-host' ? 'primary' : 'neutral'} />
            </div>
          );
        })}
      </div>
    </section>
  );
};