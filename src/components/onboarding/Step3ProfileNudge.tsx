// src/components/onboarding/Step3ProfileNudge.tsx
import { useState } from 'react';

interface Step3Props {
  onComplete: (data: { bio?: string, avatarFile?: File }, skipped?: boolean) => void;
}

export const Step3ProfileNudge: React.FC<Step3Props> = ({ onComplete }) => {
  const [bio, setBio] = useState('');
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSave = async () => {
    setIsLoading(true);
    // Parent handles the actual API call and navigation
    onComplete({ bio, avatarFile: avatarFile || undefined }, false);
  };

  const handleSkip = () => {
    onComplete({}, true);
  };

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
        setAvatarFile(e.target.files[0]);
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Make a Great First Impression</h1>
      <p className="mb-6 text-text-secondary">We highly recommend adding a profile picture and a short bio. It helps the host and other collaborators get to know you.</p>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Profile Picture</label>
        <input
          type="file"
          accept="image/*"
          onChange={handleAvatarChange}
          className="input-field"
        />
      </div>

      <div className="mb-8">
        <label htmlFor="bio" className="block text-sm font-medium mb-2">Bio</label>
        <textarea
          id="bio"
          rows={4}
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          className="input-field"
          placeholder="Tell us a bit about yourself..."
        />
      </div>

      <button
        onClick={handleSave}
        className="btn-primary w-full mb-4"
        disabled={isLoading}
      >
        {isLoading ? 'Saving...' : 'Save & Continue'}
      </button>
      <button
        onClick={handleSkip}
        className="btn-ghost w-full"
        disabled={isLoading}
      >
        Skip for Now
      </button>
    </div>
  );
};