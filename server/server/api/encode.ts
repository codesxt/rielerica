import * as crypto from 'crypto'

export default defineEventHandler(async event => {
  // const body = await readBody(event)
  const initVector = crypto.randomBytes(16)
  console.log(JSON.stringify(initVector))
  // TODO: Handle body and add user
  return { updated: true }
})