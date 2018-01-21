class App {
  constructor() {
    document.getElementById('account').innerHTML = localStorage.number
    if (localStorage.trip) {
      UI.step(3)
      trip = this.cable.subscriptions.create(
        { channel: 'TripChannel', trip_id: localStorage.trip },
        { received: function(data){
          console.log(data)
        }}
      )
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
    ajax('session', 'POST', {phone_number: val}).then(res => {
      if (res.ok) {
        document.getElementById('account').innerHTML = val
        this.phone = val
        UI.step(1)
      } else {
        UI.validate(input)
      }
    })
  }

  verify(event) {
    if (!this.isValid(event)) return false
    let input = event.target
    ajax('session', 'PATCH', {phone_number: this.phone, token: input.value}).then(res => {
      if (res.ok) {
        res.json().then(data => {
          localStorage.token = data['auth_token']
          localStorage.number = data['phone_number']
        })
        UI.step(2)
      } else {
        UI.validate(input)
      }
    })
  }

  signOut() {
    localStorage.removeItem('token')
    localStorage.removeItem('number')
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
    ajax('trips', 'POST', {trip: trip}).then(res => {
      if (res.ok) {
        res.json().then(data => {
          localStorage.trip = data['id']
          trip = this.cable.subscriptions.create(
            { channel: 'TripChannel', trip_id: data['id'] },
            { received: function(data){
              console.log(data)
            }}
          )
        })
        UI.step(3)
      } else {
        UI.validate(input)
      }
    })
  }

  cancelTrip() {
    ajax('trips/' + localStorage.trip + '/cancel', 'PATCH', {trip_id: 1}).then(res => {
      if (res.ok) {
        localStorage.removeItem('trip')
        UI.step(2)
      } else {
        UI.validate(input)
      }
    })
  }
}

let ajax = (path, method, attrs) => {
  return fetch(path, { method: method, headers: { 'Content-Type': 'application/json', 'Auth-Token': localStorage.token }, body: JSON.stringify(attrs) })
}

var app = new App
