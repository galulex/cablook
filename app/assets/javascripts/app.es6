class App {
  constructor() {
    this.step = 0
    UI.number = localStorage.number || ''
    UI.disableCurrentLink()
    if (localStorage.trip) {
      this.subscribe()
      ajax('trips/' + localStorage.trip, 'GET', null, trip => {
        if (trip.status == 0) {
          this.step = 4
          return false
        }
        if (trip.status < 3) {
          UI.showTrip({trip: trip})
          this.step = 4
        } else {
          localStorage.removeItem('trip')
          this.step = 2
        }
      })
      return false
    }
    if (!localStorage.token) return false
    this.step = 2
  }

  get cable() {
    return ActionCable.createConsumer();
  }

  set step(val) {
    this._step = val
    UI.step(val)
  }

  get step() {
    return this._step
  }

  subscribe() {
    return this.cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: localStorage.trip },
      { received: trip => { this[trip['action']](trip) }}
    )
  }

  TripUnavailable(data) {
    app.step = 2
    localStorage.removeItem('trip')
    alert('Поїздка скасована.')
  }

  TripAccepted(data) {
    localStorage.data = data
    UI.showTrip(data)
  }

  finish_trip(data) {
    app.step = 2
    localStorage.removeItem('trip')
    alert('Поїздка завершена.')
  }

  TripDeclined(trip) {
    if (confirm('Нажаль машинку не знайдено.\n Спробувати ще,')) {
      Trips.retry()
    } else {
      Trips.cancel()
      localStorage.removeItem('trip')
      app.step = 2
    }
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
        input.nextElementSibling.innerHTML += `<li onclick='app.setLocation(this)' data-place='${l.place_id}'><b>${l.structured_formatting.main_text}</b></br>${l.structured_formatting.secondary_text}</li>`
      })
    })
  }

  setAddress(event) {
    if (!isValid(event) || this.suggestions.length < 1) return false
    Locations.get(event.target, 0)
    UI.destination.focus()
  }

  setLocation(li) {
    let i = Array.prototype.indexOf.call(li.parentElement.children, li)
    let input = li.parentElement.previousElementSibling
    trip[input.id] = this.suggestions[i].description
    input.value = this.suggestions[i].structured_formatting.main_text + ' '
    input.setAttribute('data-place', li.getAttribute('data-place'))
    li.parentElement.innerHTML = ''
    input.focus()
  }

  submit(event) {
    event.preventDefault()
    UI.disableButtons()
    eval(UI.fieldsets[this.step].getAttribute('data-action'))
  }
}

let ajax = (path, method, attrs, onSuccess) => {
  fetch('api/' + path, {
    method: method,
    headers: { 'Auth-Token': localStorage.token },
    body: attrs
  }).then(res => {
    UI.disableButtons(false)
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
