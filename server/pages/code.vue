<template>
  <div class="h-screen flex items-center">
    <div class="mx-auto">
      <div v-if="error">
        <ErrorMessage :errorMessage=(error.data.message)></ErrorMessage>
      </div>
      <div v-else-if="pending">
        <LoadingMessage></LoadingMessage>
      </div>
      <div v-else>
        <button
          class="bg-blue-500 hover:bg-blue-400 text-white font-bold py-2 px-4 border-b-4 border-blue-700 hover:border-blue-500 rounded"
          @click="onButtonClick"
        >
          Volver al juego
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
const route = useRoute()
const config = useRuntimeConfig()
const { twitchClientId } = config.public
const {
  code,
  scope
} = route.query
const base_url = 'https://id.twitch.tv/oauth2/token'
const parameters = {
  client_id: twitchClientId,
  client_secret: process.env.TWITCH_SECRET,
  code: code,
  grant_type: 'authorization_code',
  redirect_uri: process.env.TWITCH_REDIRECT_URI
}
const { data, pending, error, refresh } = await useFetch(base_url,  {
  method: 'POST',
  body: JSON.stringify(parameters)
})
console.log(data.value)
console.log(error.value)

const onButtonClick = async () => {
  const channel_data = await getChannelData(data.value.access_token)
  const base_url = 'http://localhost:18297'
  const parameters = {
    ...data.value,
    id: channel_data.id,
    login: channel_data.login,
    display_name: channel_data.display_name
  }
  const params_string = new URLSearchParams(parameters).toString()
  const full_url = base_url + '?' + params_string
  window.location = full_url
}

const getChannelData = async (accessToken) => {
  const url = 'https://api.twitch.tv/helix/users'
  const { data: data } = await useFetch(
    url, {
      method: 'GET',
      headers: {
        'Client-ID': twitchClientId,
        'Authorization': `Bearer ${accessToken}`,
      }
    }
  )
  const result = data.value.data.length  > 0
    ? data.value.data[0]
    : null
  return {
    id: result?.id,
    login: result?.login,
    display_name: result?.display_name
  }
}
</script>

<style>

</style>