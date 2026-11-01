// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  extends: ['../../packages/nuxt-base'],
  app: {
    head: {
      title: 'Center - Administration',
      // Back-office: must never be indexed by search engines
      meta: [{ name: 'robots', content: 'noindex, nofollow' }],
    },
  },
})
