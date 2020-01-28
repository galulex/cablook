<script>
  import { onMount, onDestroy } from 'svelte'

  import { Map, NavigationControl, Marker, Popup } from 'mapbox-gl'

  export let cable

  let markers = {}
  let mapContainer
  let map
  let subscription

  onMount(async () => {
    initMap()
    subscribe()
    document.addEventListener('visibilitychange', onVisibilityChange, false);
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let onVisibilityChange = () => {
    document.documentElement.style.setProperty('--car-transition', '0s')
    if (document.visibilityState !== 'visible') return;
    document.documentElement.style.setProperty('--car-transition', '10s')
  }

  let subscribe = () => {
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => {
        if (data.action === 'SendLocation') updateCar(data)
      }
    })
  }

  let updateCar = (data) => {
    let marker = markers[data.car_id.toString()]
    if (!marker) return
    let { lng, lat } = marker.getLngLat()
    let deg = (bearing(data.location.reverse(), [lng, lat]) - map.getBearing())
    if (marker.deg - deg < -320 || marker.deg - deg > 320 ) {
      document.documentElement.style.setProperty('--car-rotation', '0s')
    }
    marker.deg = deg
    marker.setLngLat(data.location)
    marker._element.firstChild.style.transform = `rotate(${marker.deg}deg)`;
    document.documentElement.style.setProperty('--car-rotation', '4s')
  }

  let getCars = async () => {
    const res = await fetch('http://localhost:3000/api/drivers_app/maps')
    let cars = await res.json()
    cars.forEach(car => { renderCar(car) })
  }

  let initMap = () => {
    map = new Map({
      container: mapContainer,
      accessToken: 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA',
      style: 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z',
      center: [32.059769, 49.444431],
      minZoom: 8,
      maxZoom: 17,
      zoom: 12
    })
    map.addControl(new NavigationControl({showCompass: false}), 'bottom-right')

    map.on('load', getCars)
    map.on('movestart', () => {
      document.documentElement.style.setProperty('--car-transition', '0s')
    })

    map.on('moveend', () => {
      document.documentElement.style.setProperty('--car-transition', '10s')
    })
  }

  let bearing = (start, end) => {
    let y = Math.sin(end[0] - start[0]) * Math.cos(end[1]);
    let x = Math.cos(start[1]) * Math.sin(end[1]) -
      Math.sin(start[1]) * Math.cos(end[1]) * Math.cos(end[0] - start[0]);
    return Math.atan2(y, x) * 180 / Math.PI
  }

  let renderCar = (car) => {
    let div = document.createElement('div')
    let img = document.createElement('img')
    img.src = `https://res.cloudinary.com/active-bridge/image/upload/leafs/leaf_lights_${car.color}.svg`
    div.appendChild(img)
    let marker = new Marker(div)
    marker.deg = (bearing(car.location.reverse(), car.position.reverse()) || 180) - map.getBearing()
    marker._element.firstChild.style.transform = `rotate(${marker.deg}deg)`;
    marker.setLngLat(car.location)
    marker.setPopup(popup(car)).addTo(map)
    markers[car.id] = marker
  }

  let popup = (car) => {
    return new Popup({ offset: 25, className: car.status }).setHTML(`
      <a href='tel:${car.phone_number}'>
        ${car.number}: ${car.speed || 0}km/h
        </br>
        ${car.driver.name}
      </a>
    `)
  }

</script>

<div class='map' bind:this={mapContainer}></div>
