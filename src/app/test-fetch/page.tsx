'use client';

import { useState } from 'react';

export default function TestFetchPage() {
  const [result, setResult] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const testFetch = async () => {
    setLoading(true);
    setResult('Testing...');
    
    try {
      // Test 1: Basic health check
      const healthUrl = 'https://micasa-g1w3.onrender.com/';
      console.log('Testing:', healthUrl);
      const response = await fetch(healthUrl);
      const data = await response.json();
      setResult(`Health check success: ${JSON.stringify(data)}`);
      
      // Test 2: Try events endpoint
      const eventsUrl = 'https://micasa-g1w3.onrender.com/events/test';
      console.log('Testing events:', eventsUrl);
      const eventsResponse = await fetch(eventsUrl);
      const eventsText = await eventsResponse.text();
      setResult(prev => `${prev}\n\nEvents endpoint: ${eventsText.substring(0, 200)}`);
      
    } catch (error: any) {
      console.error('Fetch error:', error);
      setResult(`Error: ${error.message}\n\nCheck browser console for CORS errors`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-4">Test Backend Connection</h1>
      
      <button 
        onClick={testFetch}
        disabled={loading}
        className="btn-primary mb-4"
      >
        {loading ? 'Testing...' : 'Test Fetch'}
      </button>
      
      <div className="card">
        <h2 className="font-semibold mb-2">Result:</h2>
        <pre className="whitespace-pre-wrap text-sm">{result || 'Click button to test'}</pre>
      </div>
      
      <div className="card mt-4">
        <h2 className="font-semibold mb-2">Environment:</h2>
        <p className="text-sm">API URL: {process.env.NEXT_PUBLIC_API_URL || 'Not set (using default)'}</p>
      </div>
    </div>
  );
}