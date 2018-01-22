class App {
  constructor() {
    UI.number = localStorage.number || ''
    if (localStorage.trip) {
      UI.step(3)
      this.subscribe()
      return false
    }
    if (!localStorage.token) return false
    UI.step(2)
  }

  get cable() {
    return ActionCable.createConsumer();
  }

  signIn(event) {
    if (!this.isValid(event)) return false
    let input = event.target
    let val = "+380" + input.value
    ajax('session', 'POST', {phone_number: val}, data => {
      this.phone = val
      UI.number = val
      UI.step(1)
    })
  }

  verify(event) {
    if (!this.isValid(event)) return false
    let input = event.target
    ajax('session', 'PATCH', {phone_number: this.phone, token: input.value}, data => {
      localStorage.token = data['auth_token']
      localStorage.number = data['phone_number']
      //if (data['ready']) localStorage.ready = data['ready']
      localStorage.ready = data['ready']
      UI.step(2)
    })
  }

  signOut() {
    localStorage.removeItem('token')
    localStorage.removeItem('number')
    localStorage.removeItem('ready')
    UI.number = ''
    UI.step(0)
  }

  isValid(event) {
    if (event.keyCode != 13) return false
    input = event.target
    input.setCustomValidity('')
    input.reportValidity()
    return input.checkValidity()
  }

  createTrip() {
    if (localStorage.ready) {
      ajax('trips', 'POST', {trip: trip}, data => {
        localStorage.trip = data['id']
        UI.step(3)
        this.subscribe()
      })
    } else {
      pay()
    }
  }

  cancelTrip() {
    ajax('trips/' + localStorage.trip + '/cancel', 'PATCH', {trip_id: 1}, data => {
      localStorage.removeItem('trip')
      UI.step(2)
    })
  }

  subscribe() {
    return this.cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: localStorage.trip },
      { received: function(data){
        console.log(data)
      }}
    )
  }
}

let ajax = (path, method, attrs, onSuccess) => {
  fetch(path, {
    method: method,
    headers: { 'Content-Type': 'application/json', 'Auth-Token': localStorage.token },
    body: JSON.stringify(attrs)
  }).then(res => {
    if (res.ok) {
      res.json().then(data => onSuccess(data))
    } else {
      UI.validate(input)
    }
  })
}

var app = new App
