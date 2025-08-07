"use client";

import React, { useState, useEffect } from 'react';
import { OpenPosition } from '@/types/index';
import { useAuth } from '@/lib/auth-context';

interface ApplicationModalProps {
  isOpen: boolean;
  onClose: () => void;
  position: OpenPosition;
  onSuccess: () => void;
}

export const ApplicationModal: React.FC<ApplicationModalProps> = ({ 
  isOpen, 
  onClose, 
  position, 
  onSuccess 
}) => {
  const { user, setShowAuthModal, setAuthMode } = useAuth();
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasAlreadyApplied, setHasAlreadyApplied] = useState(false);

  useEffect(() => {
    // Reset state when modal opens
    if (isOpen) {
      setMessage('');
      setError(null);
      setHasAlreadyApplied(false);
      
      // Check if user is authenticated
      if (!user) {
        // Close this modal and open auth modal
        onClose();
        setAuthMode('signup');
        setShowAuthModal(true);
      }
    }
  }, [isOpen, user, onClose, setAuthMode, setShowAuthModal]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    
    setError(null);
    setIsSubmitting(true);

    try {
      const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://micasa-g1w3.onrender.com';
      const token = localStorage.getItem('token');
      
      const response = await fetch(`${API_URL}/positions/${position.position_id}/applications`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ message })
      });

      if (response.status === 409) {
        setHasAlreadyApplied(true);
        setError('You have already applied for this position.');
        return;
      }

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Failed to submit application');
      }

      // Success!
      onSuccess();
      onClose();
    } catch (err: any) {
      setError(err.message || 'An error occurred while submitting your application');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen || !user) return null;

  // If user has already applied
  if (hasAlreadyApplied) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="text-center">
            <div className="mb-4">
              <svg className="w-16 h-16 mx-auto text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h2 className="text-2xl font-bold mb-2">Already Applied</h2>
            <p className="text-gray-600 mb-6">
              You've already submitted an application for this position. The host will review it and get back to you soon!
            </p>
            <button
              onClick={onClose}
              className="btn-primary"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="p-6 border-b">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-2xl font-bold mb-2">Apply for {position.role_title}</h2>
              <p className="text-gray-600">
                {position.profit_share_percentage ? 
                  `${position.profit_share_percentage}% profit share` : 
                  'Volunteer position'}
              </p>
            </div>
            <button
              onClick={onClose}
              className="text-gray-500 hover:text-gray-700"
              disabled={isSubmitting}
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Position Details */}
        <div className="p-6 bg-gray-50">
          <h3 className="font-semibold mb-2">Position Description</h3>
          <p className="text-gray-700 whitespace-pre-line">
            {position.description || 'No additional details provided.'}
          </p>
        </div>

        {/* Application Form */}
        <form onSubmit={handleSubmit} className="p-6">
          <div className="mb-6">
            <label className="block text-sm font-medium mb-2">
              Why are you interested in this role? *
            </label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
              rows={6}
              placeholder="Tell the host about your experience, skills, and why you'd be great for this role..."
              required
              minLength={50}
              maxLength={1000}
              disabled={isSubmitting}
            />
            <p className="text-sm text-gray-500 mt-1">
              {message.length}/1000 characters (minimum 50)
            </p>
          </div>

          {/* Profile Nudge */}
          {(!user.bio || !user.profile_picture_url) && (
            <div className="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="text-sm text-yellow-800">
                <strong>Tip:</strong> Complete your profile with a bio and photo to make a great first impression! 
                You can update it in your profile settings after applying.
              </p>
            </div>
          )}

          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
              {error}
            </div>
          )}

          <div className="flex space-x-3">
            <button
              type="submit"
              disabled={isSubmitting || message.length < 50}
              className="flex-1 btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSubmitting ? 'Submitting...' : 'Submit Application'}
            </button>
            <button
              type="button"
              onClick={onClose}
              disabled={isSubmitting}
              className="flex-1 btn-secondary"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};