import type { Metadata } from "next";
import "./globals.css";
import Link from "next/link";
import { AuthProvider } from "@/lib/auth-context";
import AuthModal from "@/components/common/AuthModal";

export const metadata: Metadata = {
  title: "Micasa Events",
  description: "Collaborate, create, and monetize events.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          <header className="shadow-soft bg-surface">
              <nav className="container mx-auto px-4 py-4 flex justify-between items-center">
                  <Link href="/" className="text-2xl font-bold text-primary">Micasa</Link>
                  {/* Auth status will be updated with client component */}
                  <div className="space-x-4">
                      <Link href="/login" className="text-text-secondary hover:text-primary">Login</Link>
                  </div>
              </nav>
          </header>
          <main>
              {children}
          </main>
          <AuthModal />
        </AuthProvider>
      </body>
    </html>
  );
}
