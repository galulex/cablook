import axios from 'axios';
import i18n from '../pwa/i18n.js'

async function geoLocation() {
  if (navigator.geolocation) {
    try {
      let { lng, lat } = await getCurrentPosition()
      let coords = `${lat}, ${lng}`
      let address = await getAddress(lng, lat)
      return { address, coords}
    } catch (error) {
      console.log(i18n.location.position_unavailable)
    }
  }
}

function getCurrentPosition() {
  return new Promise(function (resolve, reject) {
    navigator.geolocation.getCurrentPosition(resolve, reject);
  }).then((res) => {
    let lat = res.coords.latitude
    let lng = res.coords.longitude
    return { lng, lat }
  }).catch((error) => {
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

function getAddress(lng, lat) {
  return axios.get(`address?coords=${lng},${lat}`).then((res) => {
    return res.data.address 
  }).catch((error) => {
    if (error.response) return alert(error.response.data.errors)
  })  
}

function geocode(point, callback) {
  axios.get(`address?coords=${point}`).then((res) => {
    callback(res.data.address)
  }).catch((error) => {
    if (error.response) alert(error.response.data.errors)
  })  
}

export { geoLocation, geocode }
