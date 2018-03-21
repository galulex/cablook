Path = {
  build(callback){
    let directionsService = new google.maps.DirectionsService()
    let waypoints = Array.from(UI.waypoints)

    let departure = waypoints.shift().getAttribute('data-place')
    let destination = waypoints.pop().getAttribute('data-place')

    let steps = []
    waypoints.forEach(w => {
      steps.push({ location: { placeId: w.getAttribute('data-place') }, stopover: true })
    })

    let params = {
      origin: { placeId: departure },
      destination: { placeId: destination },
      waypoints: steps,
      travelMode: 'DRIVING'
    }

    directionsService.route(params, function (response, status) {
      if (status === 'OK'){
        let route = response.routes[0]
        let departure = route.legs[0].start_location
        let destination = route.legs.pop().end_location

        trip.path = route.overview_polyline
        trip.departure = [departure.lat(), departure.lng()]
        trip.destination = [destination.lat(), destination.lng()]

        route.legs.forEach(w => {
          trip.waypoints.push([w.end_location.lat(), w.end_location.lng()].join())
        })

        Trips.show()
      } else {
        console.log('Directions request failed due to ' + status)
      }
    })
  }
}
