// Shared Nuxt layer. Every Nuxt app extends it:  extends: ['../../packages/nuxt-base']
// Override at runtime with NUXT_PUBLIC_API_BASE / NUXT_API_BASE_INTERNAL.
export default defineNuxtConfig({
  srcDir: 'app',
  future: { compatibilityVersion: 4 },
  devtools: { enabled: process.env.NODE_ENV !== 'production' },
  devServer: { host: '0.0.0.0', port: 3000 },
  typescript: { strict: true },
  runtimeConfig: {
    // Server-only: internal Docker URL used during SSR
    apiBaseInternal: 'http://go-backend:8080',
    public: {
      // Browser-facing API URL
      apiBase: 'http://api.localhost',
    },
  },
})

