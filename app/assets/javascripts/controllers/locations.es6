Locations = {
  get(input, callback) {
    let geo = new google.maps.Geocoder()
    geo.geocode({ address: trip[input.id] }, result => {
      if (result.length == 0) {
        input.setCustomValidity('Адреса введена не вірно')
        input.reportValidity()
        return false
      } else {
        input.setCustomValidity('')
        let location = result[0].geometry.location
        let field = input.getAttribute('data-field')
        trip[field] = [location.lat(), location.lng()]
        trip[`${field}_address`] = input.value
        input.nextElementSibling.innerHTML = ''
        if (callback) callback()
        UI.disableButtons(false)
      }
      UI.disableButtons(false)
    })
  }
}
