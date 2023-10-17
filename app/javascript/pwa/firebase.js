import { initializeApp, getApp, getApps } from '@firebase/app'
import { getMessaging, getToken, isSupported } from '@firebase/messaging'
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber, sendSignInLinkToEmail, isSignInWithEmailLink, signInWithEmailLink } from '@firebase/auth'
import { initializeAppCheck, ReCaptchaV3Provider } from "@firebase/app-check"

export const firebaseConfig = initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
})

export const firebaseApp = !getApps().length ? initializeApp(firebaseConfig) : getApp()
export const firebaseAuth = getAuth()

const actionCodeSettings = {
  url: 'http://app.lvh.me:3000/',
  handleCodeInApp: true,
  iOS: {
    bundleId: 'com.example.ios'
  },
  android: {
    packageName: 'com.example.android',
    installApp: true,
    minimumVersion: '12'
  }
}

initializeAppCheck(firebaseApp, {
  provider: new ReCaptchaV3Provider('6LcDJqcoAAAAAInevjR2DhmuKRWM70DVneiyGiHT'),
  isTokenAutoRefreshEnabled: true
})

export { RecaptchaVerifier, signInWithPhoneNumber, getToken, getMessaging, isSupported, actionCodeSettings, sendSignInLinkToEmail, isSignInWithEmailLink, signInWithEmailLink }
