Path = {
  build(callback){
    setTimeout(() => {
      let directionsService = new google.maps.DirectionsService()
      let params = {
        origin: trip.departure.join(),
        destination: trip.destination.join(),
        travelMode: 'DRIVING'
      }

      directionsService.route(params, function (response, status) {
        if (status === 'OK'){
          let points = response.routes[0].overview_polyline
          trip.path = points
          Trips.show()
        }else{
          console.log('Directions request failed due to ' + status)
        }
      })
    }, 500)
  }
}
