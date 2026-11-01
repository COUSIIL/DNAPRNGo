// https://nuxt.com/docs/api/configuration/nuxt-config
// Override at runtime with NUXT_PUBLIC_API_BASE / NUXT_API_BASE_INTERNAL.
export default defineNuxtConfig({
  devtools: { enabled: process.env.NODE_ENV !== 'production' },
  future: { compatibilityVersion: 4 },
  devServer: { host: '0.0.0.0', port: 3000 },
  app: {
    head: { title: 'nuxt-center' },
  },
  runtimeConfig: {
    // Server-only: internal Docker URL used during SSR
    apiBaseInternal: 'http://go-backend:8080',
    public: {
      // Browser-facing API URL
      apiBase: 'http://api.localhost',
    },
  },
})
