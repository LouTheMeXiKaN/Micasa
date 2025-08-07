// src/components/common/Badge.tsx

interface BadgeProps {
  text: string;
  type?: 'primary' | 'neutral' | 'success';
}

export const Badge: React.FC<BadgeProps> = ({ text, type = 'neutral' }) => {
  let colors = '';
  switch (type) {
    case 'primary':
      colors = 'bg-primary/10 text-primary';
      break;
    case 'success':
      colors = 'bg-success/10 text-success';
      break;
    case 'neutral':
    default:
      colors = 'bg-gray-200 text-text-secondary';
      break;
  }

  return (
    <span className={`inline-block px-3 py-1 text-sm font-medium rounded-full ${colors}`}>
      {text}
    </span>
  );
};