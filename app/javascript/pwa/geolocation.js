function geoLocation(geocode, setTrip) {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition((result) => {
        let lat = result.coords.latitude
        let lng = result.coords.longitude
        geocode(`${lng},${lat}`, (address) => {
          setTrip(address, lat, lng)
        })
      },
        (error) => {
          switch (error.code) {
            case error.PERMISSION_DENIED:
              console.log(i18n.location.permission_denied)
              break
            case error.TIMEOUT:
              alert(i18n.location.timeout)
              break
            case error.POSITION_UNAVAILABLE:
              console.log(i18n.location.position_unavailable)
              break
            default:
              alert(error.message)
              break
          }
        }
      )
    }
  }
export default geoLocation
