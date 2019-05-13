import firebase from 'firebase/app';
import 'firebase/messaging'

firebase.initializeApp({ messagingSenderId: '530018467398' });

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/serviceworker.js').then((registration) => {
    firebase.messaging().useServiceWorker(registration)
  });
}

export const messaging = (firebase.messaging.isSupported() ? firebase.messaging() : null )
