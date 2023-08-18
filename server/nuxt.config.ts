// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss'
  ],
  components: [
    '~/components/ui',
    '~/components'
  ],
  runtimeConfig: {
    public: {
      twitchClientId: process.env.TWITCH_CLIENT_ID || ''
    }
  }
})
