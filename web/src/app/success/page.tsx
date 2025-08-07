// src/app/success/page.tsx
"use client";

import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';

const SuccessContent = () => {
    const searchParams = useSearchParams();
    const type = searchParams.get('type'); // 'application' or 'proposal'

    let title = "Success!";
    let message = "Your action was completed successfully.";

    if (type === 'application') {
        title = "Application Sent!";
        message = "The host will review your application shortly.";
    } else if (type === 'proposal') {
        title = "Proposal Accepted!";
        message = "Welcome to the team! You are now officially part of the event.";
    }

    return (
        <div className="max-w-xl mx-auto text-center mt-10">
            <div className="card">
                <div className="text-4xl mb-4">🎉</div>
                <h1 className="text-3xl font-bold text-success mb-4">{title}</h1>
                <p className="text-lg mb-10">{message}</p>

                <div className="border-t border-border-color pt-8 mt-8">
                    <h2 className="text-2xl font-semibold mb-4">Get the full experience on the Micasa app.</h2>
                    <p className="mb-6 text-text-secondary">Manage your events, track your earnings, and connect with your community on the go.</p>

                    <div className="flex justify-center space-x-6">
                        {/* W-5 Actions: Links to App Stores */}
                        <a href="https://apps.apple.com/app/micasa" target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                            {/* Using placeholder text for now - real badges would be SVG/PNG files */}
                            <div className="bg-black text-white px-4 py-2 rounded-lg">
                                <div className="text-xs">Download on the</div>
                                <div className="text-lg font-semibold">App Store</div>
                            </div>
                        </a>
                        <a href="https://play.google.com/store/apps/details?id=com.micasa" target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                            <div className="bg-black text-white px-4 py-2 rounded-lg">
                                <div className="text-xs">Get it on</div>
                                <div className="text-lg font-semibold">Google Play</div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default function SuccessPage() {
    return (
        <div className="container mx-auto px-4 py-8">
            {/* Suspense is required when using useSearchParams */}
            <Suspense fallback={<div>Loading...</div>}>
                <SuccessContent />
            </Suspense>
        </div>
    );
}