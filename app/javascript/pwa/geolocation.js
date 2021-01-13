import axios from 'axios';
import i18n from '../pwa/i18n.js'

async function geoLocation() {
  if (navigator.geolocation) {
    try {
      let { lng, lat } = await getCurrentPosition()
      let coords = `${lat},${lng}`
      let address = await geocode(lng, lat)
      return { address, coords }
    } catch (error) {
      console.log(i18n.location.position_unavailable)
    }
  }
}

async function getCurrentPosition() {
  try {
    const res = await new Promise(function (resolve, reject) {
      navigator.geolocation.getCurrentPosition(resolve, reject);
    });
    let lat = res.coords.latitude;
    let lng = res.coords.longitude;
    return { lng, lat };
  } catch (error) {
    switch (error.code) {
      case error.PERMISSION_DENIED:
        console.log(i18n.location.permission_denied);
        break;
      case error.TIMEOUT:
        alert(i18n.location.timeout);
        break;
      case error.POSITION_UNAVAILABLE:
        console.log(i18n.location.position_unavailable);
        break;
      default:
        alert(error.message);
        break;
    }
  }
}

async function geocode(lng, lat) {
  try {
    const res = await axios.get(`address?coords=${lng},${lat}`);
    return res.data.address;
  } catch (error) {
    if (error.response)
      return alert(error.response.data.errors);
  }  
}

export { geoLocation, geocode }
