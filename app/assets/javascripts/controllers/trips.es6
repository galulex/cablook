Trips = {
  create: () => {
    if (localStorage.ready) {
      ajax('trips', 'POST', {trip: trip}, data => {
        localStorage.trip = data['id']
        UI.step(3)
        app.subscribe()
      })
    } else {
      // alert('TEST DATA')
      // this.createCard(testDATA)
      pay()
    }
  },

  cancel: () => {
    ajax(`trips/${localStorage.trip}/cancel`, 'PATCH', {trip_id: 1}, data => {
      localStorage.removeItem('trip')
      UI.step(2)
    })
  }
}
