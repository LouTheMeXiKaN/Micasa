'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="card max-w-lg mx-auto text-center">
        <h2 className="text-2xl font-bold text-error mb-4">Error Loading Event</h2>
        <p className="mb-4">There was a problem loading this event page.</p>
        <details className="text-left mb-4 p-4 bg-gray-100 rounded">
          <summary className="cursor-pointer font-semibold">Error Details</summary>
          <pre className="mt-2 text-sm overflow-auto">{error.message}</pre>
        </details>
        <button 
          onClick={reset}
          className="btn-primary"
        >
          Try Again
        </button>
      </div>
    </div>
  );
}