import firebase from '@firebase/app'
import '@firebase/messaging'
import '@firebase/auth'

firebase.initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
})

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/serviceworker.js').then((registration) => {
    firebase.messaging().useServiceWorker(registration)
    firebase.messaging().onMessage((payload) => {
      let { title, body, icon, tag, renotify, actions } = payload.data
      let options = { title, body, icon, tag, renotify }
      if (actions) {
        let actionsData = JSON.parse(actions)
        let showActions = true
        actionsData.actions.map((el) => {
          if (el.action === 'reply') return showActions = false
        })
        if (showActions) options = { ...options, ...actionsData }
      }
      options = Object.assign(options, { data: payload.data.trip })
      registration.showNotification(title, options)
    })
  })
}

export const messaging = (firebase.messaging.isSupported() ? firebase.messaging() : null )
export const firebaseAuth = firebase.auth
