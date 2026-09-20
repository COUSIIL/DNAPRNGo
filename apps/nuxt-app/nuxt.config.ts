// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  future: {
    compatibilityVersion: 4,
  },
  devServer: {
    host: '0.0.0.0',
    port: 3000
  },
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://api.localhost'
    },
    // Server-side only base URL for SSR internal requests
    apiBaseInternal: process.env.NUXT_API_BASE_INTERNAL || 'http://go-backend:8080'
  }
})
