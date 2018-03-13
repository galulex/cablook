trip = {
  departure: null,
  destination: null,
  path: null,
  status: 0,
  cost: 40,

  get departure_address() {
    return document.getElementById('departure').value
  },

  get destination_address() {
    return document.getElementById('destination').value
  }
}
