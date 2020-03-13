import firebase from '@firebase/app';
import '@firebase/messaging';
import '@firebase/auth';

firebase.initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/serviceworker.js').then((registration) => {
    firebase.messaging().useServiceWorker(registration)
    firebase.messaging().onMessage((payload) => {
      let { title, ...options } = payload.notification
      options = Object.assign(options, { data: payload.data.trip })
      if (payload.data.actions){
        let actions = JSON.parse(payload.data.actions)
        options = {...options, ...actions}
      }
      registration.showNotification(title, options)
    })
  });
}

export const messaging = (firebase.messaging.isSupported() ? firebase.messaging() : null )
export const firebaseAuth = firebase.auth
