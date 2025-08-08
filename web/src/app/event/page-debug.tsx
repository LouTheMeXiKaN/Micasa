'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

function EventContent() {
  const searchParams = useSearchParams();
  const eventId = searchParams.get('id') || 'no-id-provided';
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [eventData, setEventData] = useState<any>(null);

  useEffect(() => {
    const fetchEvent = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://micasa-g1w3.onrender.com';
        const fullUrl = `${apiUrl}/events/${eventId}`;
        console.log('Fetching from:', fullUrl);
        console.log('API URL from env:', process.env.NEXT_PUBLIC_API_URL);
        
        // Add timeout to prevent hanging
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 60000); // 60 second timeout for cold start
        
        const response = await fetch(fullUrl, {
          signal: controller.signal,
          headers: {
            'Content-Type': 'application/json',
          }
        });
        
        clearTimeout(timeoutId);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        setEventData(data);
      } catch (err: any) {
        console.error('Error fetching event:', err);
        if (err.name === 'AbortError') {
          setError('Request timed out. The backend might be starting up. Please try again in 30-60 seconds.');
        } else {
          setError(err.message || 'Failed to load event');
        }
      } finally {
        setLoading(false);
      }
    };

    if (eventId && eventId !== 'no-id-provided') {
      fetchEvent();
    } else {
      setLoading(false);
      setError('No event ID provided');
    }
  }, [eventId]);

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="card max-w-lg mx-auto text-center">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded mb-4"></div>
            <div className="h-4 bg-gray-200 rounded mb-2"></div>
            <div className="h-4 bg-gray-200 rounded"></div>
          </div>
          <p className="mt-4 text-text-secondary">Loading event...</p>
          <p className="text-sm text-text-secondary mt-2">
            Note: If the backend is cold-starting on Render, this may take 30-60 seconds.
          </p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="card max-w-lg mx-auto text-center">
          <h2 className="text-2xl font-bold text-error mb-4">Error Loading Event</h2>
          <p className="mb-4">{error}</p>
          <button 
            onClick={() => window.location.reload()}
            className="btn-primary"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="card">
        <h1 className="text-3xl font-bold mb-4">
          {eventData?.title || `Event ${eventId}`}
        </h1>
        <p className="text-text-secondary mb-4">
          {eventData?.description || 'No description available'}
        </p>
        
        <div className="mt-6 p-4 bg-gray-100 rounded">
          <h3 className="font-semibold mb-2">Debug Info:</h3>
          <p className="text-sm">Event ID: {eventId}</p>
          <p className="text-sm">API URL: {process.env.NEXT_PUBLIC_API_URL}</p>
          <details className="mt-2">
            <summary className="cursor-pointer text-sm font-semibold">Raw Data</summary>
            <pre className="mt-2 text-xs overflow-auto">
              {JSON.stringify(eventData, null, 2)}
            </pre>
          </details>
        </div>
      </div>
    </div>
  );
}

export default function EventPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <EventContent />
    </Suspense>
  );
}