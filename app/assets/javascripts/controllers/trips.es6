Trips = {
  build: () => {
    Locations.get(UI.departureAddress, Locations.get(UI.destinationAddress, Path.build))
  },

  show: () => {
    app.step = 3
    UI.disableButtons(false)
    UI.path = `https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:${trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0`
  },

  create: () => {
    data = new FormData(UI.form)
    data.append('trip[departure_address]', trip.departure)
    data.append('trip[destination_address]', trip.destination)
    data.append('trip[departure][]', trip.departure[0])
    data.append('trip[departure][]', trip.departure[1])
    data.append('trip[destination][]', trip.destination[0])
    data.append('trip[destination][]', trip.destination[1])
    data.append('trip[path]', trip.path)
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
    trip = {}
    app.step = 2
  },

  cancel: () => {
    ajax(`trips/${localStorage.trip}/cancel`, 'PATCH', {trip_id: 1}, data => {
      localStorage.removeItem('trip')
      app.step = 2
    })
  }
}
