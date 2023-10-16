import { initializeApp } from '@firebase/app'
import { getMessaging, getToken, isSupported } from '@firebase/messaging'
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber } from '@firebase/auth'
import { initializeAppCheck, ReCaptchaV3Provider } from "@firebase/app-check"

export { RecaptchaVerifier, signInWithPhoneNumber, getToken, getMessaging, isSupported }

export const firebaseApp = initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
})

initializeAppCheck(firebaseApp, {
  provider: new ReCaptchaV3Provider('6LcDJqcoAAAAAInevjR2DhmuKRWM70DVneiyGiHT'),
  isTokenAutoRefreshEnabled: true
})

export const firebaseAuth = getAuth(firebaseApp)
