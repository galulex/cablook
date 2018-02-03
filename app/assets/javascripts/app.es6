class App {
  constructor() {
    UI.number = localStorage.number || ''
    if (localStorage.trip) {
      this.subscribe()
      ajax('trips/' + localStorage.trip, 'GET', null, trip => {
        if (trip.status == 0) {
          UI.step(3)
          return false
        }
        if (trip.status < 3) {
          UI.showTrip(trip)
          UI.step(3)
        } else {
          localStorage.removeItem('trip')
          UI.step(2)
        }
      })
      return false
    }
    if (!localStorage.token) return false
    UI.step(2)
  }

  get cable() {
    return ActionCable.createConsumer();
  }

  subscribe() {
    return this.cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: localStorage.trip },
      { received: trip => { this[trip['action']](trip) }}
    )
  }

  TripAccepted(data) {
    console.log(data)
    UI.showTrip(data.trip)
  }

  TripDeclined(trip) {
    UI.step(2)
    localStorage.removeItem('trip')
    alert('Налажь ми не можемо виконати ваше замовлення.\n Просимо вибачення за незручності')
  }

  autocomplete(input) {
    fetch(`https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=${input.value}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0&location=49.44444,32.05972&radius=50`, { mode: 'no-cors', method: 'GET'}).then(res => {
      // if (res.ok) {
        res.json().then(data => {
          console.log(data)
        })
      // } else {
        // console.log(res)
      // }
    })
  }
}

let ajax = (path, method, attrs, onSuccess) => {
  fetch('api/' + path, {
    method: method,
    headers: { 'Content-Type': 'application/json', 'Auth-Token': localStorage.token },
    body: (method == 'GET') ? null : JSON.stringify(attrs)
  }).then(res => {
    if (res.ok) {
      res.json().then(data => onSuccess(data))
    } else {
      res.json().then(data => alert(data['errors']))
    }
  })
}

let isValid = function(event) {
  if (event.keyCode != 13) return false
  input = event.target
  input.setCustomValidity('')
  input.reportValidity()
  return input.checkValidity()
}

var app = new App
