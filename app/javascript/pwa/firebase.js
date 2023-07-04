import { initializeApp } from '@firebase/app'
import { getMessaging, getToken, onMessage } from '@firebase/messaging'
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber } from '@firebase/auth'

export { RecaptchaVerifier, signInWithPhoneNumber, getToken, onMessage, getMessaging }

export const firebaseApp = initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
})

export const firebaseAuth = getAuth(firebaseApp)
