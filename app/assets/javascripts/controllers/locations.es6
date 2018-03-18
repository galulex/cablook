Locations = {
  get(input, callback) {
    let service = new google.maps.places.PlacesService(document.createElement('div'))
    let placeId = input.getAttribute('data-place')
    if (!placeId) {
      input.setCustomValidity('Адреса введена не вірно')
      input.reportValidity()
      UI.disableButtons(false)
      return false
    }
    service.getDetails({ placeId: placeId }, (place, status) => {
      if (status !== google.maps.places.PlacesServiceStatus.OK) {
        input.setCustomValidity('Адреса введена не вірно')
        input.reportValidity()
        UI.disableButtons(false)
        return false
      } else {
        input.setCustomValidity('')
        let location = place.geometry.location
        let field = input.getAttribute('data-field')
        trip.waypoints.push([location.lat(), location.lng()])
        trip[`${field}_address`] = input.value
        input.nextElementSibling.innerHTML = ''
        if (callback) callback()
        UI.disableButtons(false)
        if (input.parentElement.nextElementSibling.id != 'add_point') return false
        Path.build()
      }
      UI.disableButtons(false)
    })
  }
}
