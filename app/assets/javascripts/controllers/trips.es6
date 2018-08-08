Trips = {
  build: () => {
    let waypoints = Array.from(UI.waypoints)
    data = new FormData(UI.form)
    data.append('trip[departure_address]', trip.departure_address)
    data.append('trip[destination_address]', trip.destination_address)
    data.append('trip[departure]', waypoints.shift().getAttribute('data-place'))
    data.append('trip[destination]', waypoints.pop().getAttribute('data-place'))

    waypoints.forEach(w => {
      data.append('trip[waypoints][]', w.getAttribute('data-place'))
      data.append('trip[stops][]', w.value)
    })

    ajax(`trips/new`, 'POST', data, data => {
      trip = data
      Trips.show()
    })
  },

  show: () => {
    app.step = 3
    UI.disableButtons(false)
    UI.path = `https://maps.googleapis.com/maps/api/staticmap?size=400x400&path=enc:${trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0`
    UI.tripCost = `${trip.cost}грн`
    UI.tripDistance = `${(trip.distance/1000).toFixed(1)}KM`
  },

  create: () => {
    data = new FormData(UI.form)
    data.append('trip[departure_address]', trip.departure_address)
    data.append('trip[destination_address]', trip.destination_address)
    data.append('trip[departure][]', trip.departure[0])
    data.append('trip[departure][]', trip.departure[1])
    data.append('trip[destination][]', trip.destination[0])
    data.append('trip[destination][]', trip.destination[1])

    trip.waypoints.forEach(w => {
      data.append('trip[waypoints][]', w)
    })

    trip.stops.forEach(w => {
      data.append('trip[stops][]', w)
    })

    data.append('trip[path]', trip.path)

    if (trip['bonus'] == 'true') data.append('trip[bonus]', trip.bonus)

    data.append('trip[comment]', trip.comment)
    if (localStorage.ready) {
      ajax('trips', 'POST', data, data => {
        localStorage.trip = data['id']
        app.step = 4
        app.subscribe()
        dataLayer.push({ 'event': 'formSubmission', 'formType': 'Order Taxi' })
      })
    } else {
      alert('На даний момент CabLook підтримує лише безготівковий спосіб оплати. \n Щоб продовжити додайте свою платіжну картку')
      pay()
    }
  },

  destroy: () => {
    trip = { waypoints: [] }
    UI.destroyTrip()
    app.step = 2
  },

  cancel: () => {
    ajax(`trips/${localStorage.trip}/cancel`, 'PATCH', {trip_id: 1}, data => {
      localStorage.removeItem('trip')
      Trips.destroy()
    })
  },

  retry: () => {
    ajax(`trips/${localStorage.trip}/retry`, 'PATCH', {trip_id: 1}, data => {
    })
  }
}
