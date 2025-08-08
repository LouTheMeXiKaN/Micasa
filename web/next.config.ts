import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    // Disable SWC minification which can cause Jest worker issues
    swcMinify: false,
  },
  // Increase timeout for slow backends
  httpAgentOptions: {
    keepAlive: true,
  },
  // Ensure client-side navigation works
  reactStrictMode: true,
};

export default nextConfig;
