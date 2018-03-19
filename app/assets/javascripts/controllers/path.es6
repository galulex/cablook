Path = {
  build(callback){
    let directionsService = new google.maps.DirectionsService()
    let waypoints = Array.from(UI.waypoints)
    waypoints.slice(1, waypoints.length - 1).forEach(w => {
      trip.waypoints.push({ location: { placeId: w.getAttribute('data-place') }, stopover: true })
    })

    trip.departure = waypoints[0].getAttribute('data-place')
    trip.destination = waypoints.pop().getAttribute('data-place')

    let params = {
      origin: { placeId: trip.departure },
      destination: { placeId: trip.destination },
      waypoints: trip.waypoints,
      travelMode: 'DRIVING'
    }

    directionsService.route(params, function (response, status) {
      if (status === 'OK'){
        let points = response.routes[0].overview_polyline
        console.log(response)
        trip.path = points
        trip.distance = 100
        trip.duration = 100
        Trips.show()
      }else{
        console.log('Directions request failed due to ' + status)
      }
    })
  }
}
