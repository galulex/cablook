import firebase from 'firebase/app';
import 'firebase/messaging';
import 'firebase/auth';

firebase.initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  projectId: 'cablook-2225665',
  messagingSenderId: '530018467398'
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/serviceworker.js').then((registration) => {
    firebase.messaging().useServiceWorker(registration)
  });
}

export const messaging = (firebase.messaging.isSupported() ? firebase.messaging() : null );
export const firebaseAuth = firebase.auth;
