Trips = {
  build: () => {
    // UI.waypoints.forEach(point =>
      // Locations.get(point)
    // )
    // Locations.get(UI.departureAddress, Locations.get(UI.destinationAddress, Path.build))
  },

  show: () => {
    app.step = 3
    UI.disableButtons(false)
    UI.path = `https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:${trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0`
  },

  create: () => {
    data = new FormData(UI.form)
    data.append('trip[departure_address]', trip.departure_address)
    data.append('trip[destination_address]', trip.destination_address)
    data.append('trip[departure]', trip.departure)
    data.append('trip[destination]', trip.destination)
    data.append('trip[path]', trip.path)
    data.append('trip[comment]', trip.comment)
    if (localStorage.ready) {
      ajax('trips', 'POST', data, data => {
        localStorage.trip = data['id']
        app.step = 4
        app.subscribe()
      })
    } else {
      alert('На даний момент CabLook підтримує лише безготівковий спосіб оплати. \n Щоб продовжити додайте свою платіжну картку')
      pay()
    }
  },

  destroy: () => {
    trip = { waypoints: [] }
    app.step = 2
  },

  cancel: () => {
    ajax(`trips/${localStorage.trip}/cancel`, 'PATCH', {trip_id: 1}, data => {
      localStorage.removeItem('trip')
      app.step = 2
    })
  }
}
