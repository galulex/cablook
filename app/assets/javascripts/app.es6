class App {
  constructor() {
    UI.number = localStorage.number || ''
    UI.disableCurrentLink()
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
    UI.showTrip(data.trip)
  }

  TripDeclined(trip) {
    UI.step(2)
    localStorage.removeItem('trip')
    alert('Нажаль ми не можемо виконати ваше замовлення.\n Просимо вибачення за незручності')
  }

  autocomplete(input) {
    input.nextElementSibling.innerHTML = ''
    if (input.value.length == 0) return false
    let service = new google.maps.places.AutocompleteService()
    service.getPlacePredictions({input: input.value, componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 10, strictbounds: true}, data => {
      this.suggestions = []
      if (!data) return false
      this.suggestions = data
      data.forEach(l => {
        input.nextElementSibling.innerHTML += `<li onclick='app.setLocation(this)'><b>${l.structured_formatting.main_text}</b></br>${l.structured_formatting.secondary_text}</li>`
      })
    })
  }

  setStart(event) {
    if (!isValid(event) || this.suggestions.length < 1) return false
    Locations.get(event.target, 0)
    UI.destination.disabled = false
    UI.destination.focus()
  }

  setFinish(event) {
    if (!isValid(event) || this.suggestions.length < 1) return false
    if (!trip.departure) {
      Locations.get(event.target, 0)
      UI.departure.focus()
    } else {
      Locations.get(event.target, 0, Trips.create)
    }
  }

  setLocation(li) {
    let i = Array.prototype.indexOf.call(li.parentElement.children, li)
    let input = li.parentElement.previousElementSibling
    input.value = this.suggestions[i].structured_formatting.main_text + ' '
    input.focus()
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

// IOS safari zoom hack
document.body.addEventListener('gesturestart', (e) => e.preventDefault())
