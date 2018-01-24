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

  subscribe() {
    return this.cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: localStorage.trip },
      { received: function(data){
        console.log(data)
      }}
    )
  }

  tripAccepted() {
    //TODO
  }

  tripDeclined() {
    //TODO
  }
}

let ajax = (path, method, attrs, onSuccess) => {
  fetch('api/' + path, {
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

let isValid = function(event) {
  if (event.keyCode != 13) return false
  input = event.target
  input.setCustomValidity('')
  input.reportValidity()
  return input.checkValidity()
}

var app = new App
