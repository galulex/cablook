import axios from 'axios';

import UI from './UI'

export default class Trip {
  static build = () => {
    const waypoints = Array.from(UI.waypoints())
    const comment = document.getElementById('comment')
    trip.comment = comment.value || ''
    let data = new FormData()
    data.append('trip[departure_address]', trip.departure_address)
    data.append('trip[destination_address]', trip.destination_address)
    data.append('trip[departure]', waypoints.shift().getAttribute('data-place'))
    data.append('trip[destination]', waypoints.pop().getAttribute('data-place'))
    data.append('trip[comment]', trip.comment)

    waypoints.forEach(w => {
      data.append('trip[waypoints][]', w.getAttribute('data-place'))
      data.append('trip[stops][]', w.value)
    })

    return axios({method: 'POST', url: '/api/trips/new', data: data, headers: {'Auth-Token': localStorage.token}})
  } 

  static showTrip = (data) => {
    let trip = data.trip
    const html = `
      <img class='map-img' src='${localStorage.mapURL}'></br>
      Вартість: <b>${trip.cost}грн</b></br>
      Відстань: <b>${(trip.distance/1000).toFixed(1)}КМ</b></br>
      Відправлення: <b>${trip.start_time}</b></br>
      Прибуття: <b>${trip.finish_time}</b></br>
      ${trip.driver_name}: <b><a href='tel:${trip.car_phone_number}'>${trip.car_phone_number}</a></b></br>
    `
    document.getElementById('loader').classList.add('hidden')
    document.getElementById('state').innerHTML = html
    const nissan = document.getElementById('nissan')
    if (nissan) nissan.className.baseVal = 'nissan gone'
  }

  static cable = () => {
    return ActionCable.createConsumer()
  } 

  static subscribe = (that) => {
    return Trip.cable().subscriptions.create(
      { channel: 'TripChannel', trip_id: localStorage.trip },
      { received: trip => { 
        return Trip[trip['action']](trip, that) }}
    )
  }

  static TripAccepted = (data, that) => {
    localStorage.data = data.trip
    Trip.showTrip(data)
  }

  static TripDeclined = (data, that) => {
    if (confirm('Нажаль машинку не знайдено.\n Спробувати ще?')) {
      Trip.retry()
    } else {
      Trip.cancel()
      localStorage.removeItem('trip')
      that.props.updateStep(3)
    }
  }

  static TripUnavailable = (data, that) => {
    UI.destroyTrip()
    Trip.destroy(that)
    localStorage.removeItem('trip')
    alert('Поїздка скасована.')
  }

  static finish_trip = (data, that) => {
    localStorage.removeItem('trip')
    alert('Поїздка завершена.')
    UI.destroyTrip()
    Trip.destroy(that)
  }

  static waiting_client = () => {
    alert('Водій прибув на місце і очікує Вас')
  }

  static cancel = () => {
    axios({method: 'PATCH', url: '/api/trips/'+ localStorage.trip + '/cancel', headers: {'Auth-Token': localStorage.token}}).then(response => {
    })
    .catch(err => {
      console.log(err.response.data.errors)
    })
  }

  static retry = () => {
    axios({method: 'PATCH', url: '/api/trips/'+ localStorage.trip + '/retry', headers: {'Auth-Token': localStorage.token}}).then(response => {
    })
  }

  static destroy = (that) => {
    trip = { waypoints: [] }
    if (that.state === null){
      that.props.updateStep(3)
    }
    else{
      that.setStep(3)
    }
  }

  static create = (that) => {
    let data = new FormData()
    data.append('trip[departure_address]', trip.departure_address)
    data.append('trip[destination_address]', trip.destination_address)
    data.append('trip[departure][]', trip.departure[0])
    data.append('trip[departure][]', trip.departure[1])
    data.append('trip[destination][]', trip.destination[0])
    data.append('trip[destination][]', trip.destination[1])

    trip.waypoints.forEach(w => {
      data.append('trip[waypoints][]', w)
    })

    trip.stops.forEach(w => {
      data.append('trip[stops][]', w)
    })

    data.append('trip[path]', trip.path)
    data.append('trip[card_id]', trip.card_id)

    if (trip['bonus'] == 'true') data.append('trip[bonus]', trip.bonus)

    data.append('trip[comment]', trip.comment)
    if (localStorage.ready) {
      axios({method: 'POST', url: '/api/trips', data: data, headers: {'Auth-Token': localStorage.token}}).then(response => {
        localStorage.trip = response.data['id']
        Trip.subscribe(that)
        that.props.updateStep(5)
        dataLayer.push({ 'event': 'formSubmission', 'formType': 'Order Taxi' })
      }).catch(error => alert(error.response.data.errors))
    } else {
      alert('На даний момент CabLook підтримує лише безготівковий спосіб оплати. \n Щоб продовжити додайте свою платіжну картку')
      that.pay()
    }
  }

  static show = () => {
    let departure = []
    let destination = []
    let waypoints = []
    trip.departure.map((el, index) => departure[index] = el)
    trip.destination.map((el, index) => destination[index] = el)
    destination.reverse()
    departure.reverse()
    console.log(departure)
    trip.waypoints.map((w, index) => {
      waypoints[index] = w.split(',').reverse().join(',')
    })
    localStorage.mapURL = 'https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+188753-0.8(' + encodeURIComponent(trip.path) + ')/auto/400x400?access_token=pk.eyJ1IjoiYnJ1Y2VsaWF0b3IiLCJhIjoiY2oxcTJ5dDNzMDA2ajMybnR6M3V5cGVubiJ9.qjyqnH72UUVnsaY63OzMGg'
    return localStorage.mapURL
  }
} 
