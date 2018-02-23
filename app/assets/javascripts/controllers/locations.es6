Locations = {
  get(input, index = 0, callback) {
    let geo = new google.maps.Geocoder()
    geo.geocode({ address: app.suggestions[index].description }, result => {
      if (result.length == 0) return false
      let location = result[0].geometry.location
      trip[input.id] = [location.lat(),location.lng()]
      input.nextElementSibling.innerHTML = ''
      if (callback) callback()
    })
    input.value = app.suggestions[index].description
  }
}
