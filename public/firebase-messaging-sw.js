importScripts('https://www.gstatic.com/firebasejs/7.7.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/7.7.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCw0swS8LhKYSdxMXdMo2BLa46uE0i7vDA',
  authDomain: 'cablook-2225665.firebaseapp.com',
  databaseURL: 'https://cablook-2225665.firebaseio.com',
  projectId: 'cablook-2225665',
  storageBucket: 'cablook-2225665.appspot.com',
  messagingSenderId: '530018467398',
  appId: '1:530018467398:web:c5dd0a6d759483b95ad447'
})

const messaging = firebase.messaging()

messaging.setBackgroundMessageHandler((payload) => {
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
  return self.registration.showNotification(title, options)
})

function focusOnTab(event) {
  event.waitUntil(clients.matchAll({
    type: 'window'
  }).then(function(clientList) {
    for (var i = 0; i < clientList.length; i++) {
      var client = clientList[i]
      if ('focus' in client) { return client.focus() }
    }
    if (clients.openWindow) return clients.openWindow('/')
  }))
}

self.addEventListener('notificationclick', function(event) {
  let data = JSON.parse(event.notification.data)
  let action = event.action

  switch(action) {
    case 'retry':
      fetch('https://staging-app.cablook.taxi/api/trips/' + data.id + '/retry',{
        method: 'PATCH',
        headers: {
          'Auth-Token': data.user_token,
          'Content-Type': 'application/json'
        }
      })
      event.notification.close()
      focusOnTab(event)
      break
    case 'cancel':
      fetch('https://staging-app.cablook.taxi/api/trips/' + data.id + '/cancel',{
        method: 'PATCH',
        headers: {
          'Auth-Token': data.user_token,
          'Content-Type': 'application/json'
        }
      })
      focusOnTab(event)
      event.notification.close()
      break
    case 'coming':
      let params = { message_type: 'coming', trip_id: data.id }
      fetch('https://staging-app.cablook.taxi/api/notify_driver',{
        method: 'POST',
        headers: {
          'Auth-Token': data.user_token,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(params)
      })
      focusOnTab(event)
      event.notification.close()
      break

    default:
      event.notification.close()
      focusOnTab(event)
      break
  }
}, false)
