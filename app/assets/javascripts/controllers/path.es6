Path = {
  build(callback){
    let directionsService = new google.maps.DirectionsService()
    UI.waypoints.forEach(w => {
      trip.waypoints.push({ placeId: w.getAttribute('data-place') })
    })

    let params = {
      origin: trip.waypoints[0],
      destination: trip.waypoints[1],
      waypoints: trip.waypoints,
      travelMode: 'DRIVING'
    }

    directionsService.route(params, function (response, status) {
      if (status === 'OK'){
        let points = response.routes[0].overview_polyline
        console.log(response)
        trip.path = points
        Trips.show()
      }else{
        console.log('Directions request failed due to ' + status)
      }
    })
  }
}
