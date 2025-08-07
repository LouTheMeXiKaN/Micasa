// src/components/application/ApplicationModal.tsx
"use client";

import React, { useState, useEffect } from 'react';
import { Modal } from '@/components/common/Modal';
import { OpenPosition, User } from '@/types/index';
import { submitApplication, updateProfile, createProvisionalAccount } from '@/lib/api';

interface ApplicationModalProps {
  isOpen: boolean;
  onClose: () => void;
  position: OpenPosition;
  currentUser: User | null;
  onSuccess: () => void;
}

// W-4 defines a multi-step flow: Auth -> Profile Completion -> Application Message
type Step = 'AUTH' | 'PROFILE_NUDGE' | 'APPLICATION_FORM' | 'SUBMITTING';

export const ApplicationModal: React.FC<ApplicationModalProps> = ({ isOpen, onClose, position, currentUser: initialUser, onSuccess }) => {
  const [step, setStep] = useState<Step>('AUTH');
  const [currentUser, setCurrentUser] = useState<User | null>(initialUser);
  const [userId, setUserId] = useState<string | null>(initialUser?.user_id || null);
  const [message, setMessage] = useState('');
  const [bio, setBio] = useState('');
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setCurrentUser(initialUser);
    setUserId(initialUser?.user_id || null);
    determineStep(initialUser);
  }, [initialUser]);

  const determineStep = (user: User | null) => {
    if (!user && !userId) {
        setStep('AUTH'); // W-4 Step 1
    // Check if profile is incomplete (W-4 Step 2 condition)
    } else if (!user?.bio || !user?.profile_picture_url) {
        setStep('PROFILE_NUDGE');
    } else {
        setStep('APPLICATION_FORM'); // W-4 Step 3
    }
  };

  // --- Handlers ---

  const handleAuth = async (provider: 'google' | 'apple') => {
    // Authentication (W-4 Step 1)
    setError(null);
    try {
        // Real API call for authentication
        const result = await createProvisionalAccount(provider);
        setUserId(result.userId);
        // Move to next step (Profile Nudge, as new accounts often lack bio/avatar)
        setStep('PROFILE_NUDGE');
    } catch (err) {
        setError('Authentication failed. Please try again.');
    }
  };

  const handleProfileNudge = async (skip = false) => {
    // (W-4 Step 2)
    setError(null);
    if (!skip && (bio || avatarFile) && userId) {
        try {
            await updateProfile(userId, { bio, avatarFile: avatarFile || undefined });
        } catch (err) {
            setError('Failed to update profile. You can still continue.');
        }
    }
    setStep('APPLICATION_FORM');
  };

  const handleSubmitApplication = async () => {
    // (W-4 Step 3)
    if (!message.trim()) {
        setError('Application message is required.');
        return;
    }
    setStep('SUBMITTING');
    setError(null);
    try {
        const result = await submitApplication(position.position_id, message);
        if (result.success) {
            onSuccess();
        } else {
            throw new Error('Application submission failed.');
        }
    } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred.');
        setStep('APPLICATION_FORM');
    }
  };

  // --- Render Steps ---

  const renderStep = () => {
    switch (step) {
      case 'AUTH':
        return (
          <div>
            <p className="mb-6">You need to sign in or create an account to apply for this position.</p>
            <button onClick={() => handleAuth('google')} className="btn-primary w-full mb-4">Continue with Google</button>
            <button onClick={() => handleAuth('apple')} className="btn-primary w-full">Continue with Apple</button>
            <p className="text-sm text-text-secondary mt-4 text-center">
              Note: OAuth integration is pending. This will connect to the real authentication service.
            </p>
          </div>
        );
      case 'PROFILE_NUDGE':
        return (
          <div>
            <p className="mb-6">Help the host get to know you! A complete profile makes a great first impression.</p>
             <div className="mb-4">
                <label className="block text-sm font-medium mb-2">Profile Picture (Optional)</label>
                <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setAvatarFile(e.target.files?.[0] || null)}
                    className="input-field"
                />
            </div>
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Bio (Optional)</label>
              <textarea
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={3}
                className="input-field"
                placeholder="Tell us about yourself..."
              />
            </div>
            <button onClick={() => handleProfileNudge(false)} className="btn-primary w-full mb-3">Save & Continue</button>
            <button onClick={() => handleProfileNudge(true)} className="btn-ghost w-full">Skip for Now</button>
          </div>
        );
      case 'APPLICATION_FORM':
      case 'SUBMITTING':
        return (
          <div>
            <h3 className="text-xl font-semibold mb-6">Applying for: {position.role_title}</h3>
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Your Message</label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={6}
                className="input-field"
                placeholder="Why are you a good fit for this role?"
                disabled={step === 'SUBMITTING'}
              />
            </div>
            {error && <p className="text-error text-sm mb-4">{error}</p>}
            <button onClick={handleSubmitApplication} className="btn-primary w-full" disabled={step === 'SUBMITTING' || !message.trim()}>
              {step === 'SUBMITTING' ? 'Submitting...' : 'Submit Application'}
            </button>
          </div>
        );
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Apply to Collaborate">
      {renderStep()}
    </Modal>
  );
};