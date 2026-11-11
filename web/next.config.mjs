/** @type {import('next').NextConfig} */
const nextConfig = {
  // these server-only packages are loaded directly by Node, not bundled
  serverExternalPackages: ['@huggingface/transformers', 'mysql2', 'redis'],
};

export default nextConfig;
