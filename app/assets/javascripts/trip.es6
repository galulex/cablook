trip = {
  departure: null,
  destination: null,
  path: 'path',
  status: 0,
  cost: 40,

  get departure_address() {
    return document.getElementById('from').value
  },

  get destination_address() {
    return document.getElementById('to').value
  }
}

