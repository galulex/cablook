Locations = {
  get(event, callback) {
    let geo = new google.maps.Geocoder()
    geo.geocode({ address: app.suggestions[0].description }, result => {
      if (result.length == 0) return false
      let location = result[0].geometry.location
      trip[event.target.id] = [location.lat(),location.lng()]
      input.nextElementSibling.innerHTML = ''
      if (callback) callback()
    })
    event.target.value = app.suggestions[0].description
  }
}
