import firebase from 'firebase/app';
import 'firebase/messaging'

firebase.initializeApp({ messagingSenderId: '530018467398' });

export const messaging = (firebase.messaging.isSupported() ? firebase.messaging() : null )
