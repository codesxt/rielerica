<template>
  <div>
  </div>
</template>

<script setup>
const base_url = 'https://id.twitch.tv/oauth2/authorize'
const parameters = {
  client_id: process.env.TWITCH_CLIENT_ID,
  force_verify: false,
  redirect_uri: process.env.TWITCH_REDIRECT_URI,
  response_type: 'code',
  scope: process.env.TWITCH_SCOPES
}
const params_string = new URLSearchParams(parameters).toString()
const full_url = base_url + '?' + params_string
await navigateTo(full_url, {
  external: true
})
</script>

<style>

</style>