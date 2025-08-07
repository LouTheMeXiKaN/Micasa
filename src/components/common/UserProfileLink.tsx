// src/components/common/UserProfileLink.tsx
import Image from 'next/image';
import Link from 'next/link';
import { User } from '@/types/index';

interface UserProfileLinkProps {
  user: Pick<User, 'user_id' | 'username' | 'profile_picture_url'>;
  size?: 'small' | 'medium';
}

export const UserProfileLink: React.FC<UserProfileLinkProps> = ({ user, size = 'medium' }) => {
  const avatarSize = size === 'small' ? 32 : 48;
  const textSize = size === 'small' ? 'text-sm' : 'text-base';

  // Placeholder for when W-7 (Public User Profile Page) is implemented
  const profileUrl = `/users/${user.user_id}`;

  return (
    <Link href={profileUrl} className="flex items-center space-x-3 hover:opacity-80 transition-opacity">
      <Image
        src={user.profile_picture_url || '/default-avatar.svg'} // Ensure a default avatar exists in /public
        alt={`${user.username}'s avatar`}
        width={avatarSize}
        height={avatarSize}
        className="rounded-full object-cover"
      />
      <span className={`${textSize} font-medium text-text-primary`}>{user.username}</span>
    </Link>
  );
};