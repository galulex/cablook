class App {
  constructor() {
    this.step = 0
    UI.number = localStorage.number || ''
    UI.disableCurrentLink()
    if (localStorage.trip) {
      ajax('trips/' + localStorage.trip, 'GET', null, trip => {
        if (trip.status == 0) {
          this.step = 4
          this.subscribe()
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
    Trips.destroy()
    localStorage.removeItem('trip')
    alert('Поїздка скасована.')
  }

  PaymentResponse(data) {
    //TODO Handle payment response
    console.log(data)
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
    if (confirm('Нажаль машинку не знайдено.\n Спробувати ще?')) {
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
      for (var i = 0; i < data.length; i++) {
        input.nextElementSibling.innerHTML += `<li onclick='app.setLocation(this)' data-place='${data[i].place_id}'><b>${data[i].structured_formatting.main_text}</b></br>${data[i].structured_formatting.secondary_text}</li>`
      }
    })
  }

  setLocation(li) {
    let i = Array.prototype.indexOf.call(li.parentElement.children, li)
    let input = li.parentElement.previousElementSibling
    input.value = this.suggestions[i].structured_formatting.main_text + ' '
    trip[input.id] = input.value
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
  xhr = new XMLHttpRequest()
  xhr.open(method, 'api/' + path, true)
  xhr.setRequestHeader('Auth-Token', localStorage.token)
  xhr.onreadystatechange = function() {
    UI.disableButtons(false)
    if (xhr.readyState != 4) return false
    if (xhr.status === 200 || xhr.status === 201) {
      onSuccess(JSON.parse(xhr.response))
    } else {
      alert(JSON.parse(xhr.response)['errors'])
    }
  }
  xhr.send(attrs)
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
