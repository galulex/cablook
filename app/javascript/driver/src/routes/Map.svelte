<script>
  import { onDestroy } from 'svelte'
  import { Map, controls } from '@beyonk/svelte-mapbox'
  import Marker from './map/marker.svelte'
  import Path from './map/path.svelte'
  import axios from 'axios'

  import '../../css/map.css'

  const { GeolocateControl, NavigationControl } = controls

  export let cable
  export let location
  export let trips
  export let sos

  let cars = []
  let subscription
  let mapComponent

  let init = () => {
    let map = mapComponent.getMap()

    map.on('rotatestart', () => {
      document.body.classList.add('rotate')
    })

    map.on('rotate', () => {
      document.documentElement.style.setProperty('--bearing', Math.trunc((180 + map.getBearing()) / 3))
      document.body.style.setProperty('--steps', 1)
    })

    map.on('rotateend', () => {
      document.body.classList.remove('rotate')
    })

    map.on('zoom', () => {
      document.documentElement.style.setProperty('--zoom-level', map.getZoom())
    })

    map.on('pitch', () => {
      const y = (Math.round(map.getPitch() / 19) + 1)
      document.documentElement.style.setProperty('--y', y)
    })
  }

  const isDarkTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
  const darkModeMapStyle = 'mapbox://styles/galulex/ckvficxop4zs514qzkozc0u1e'
  const lightModeMapStyle = 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z'

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let subscribe = () => {
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => {
        if (data.action === 'SendLocation') updateCar(data.payload)
      }
    })
  }

  let updateCar = (data) => {
    data.forEach((car_data) => {
      let i = cars.findIndex(car => car.id === car_data.id)
      let car = cars[i]
      if (i < 0) return
      car.position = car.location
      car.location = car_data.location
      car.speed = car_data.speed
      cars[i] = car
    })
  }

  let getCars = (async () => {
    let res = await axios.get('maps')
    cars = res.data
    subscribe()
    return cars
  })
</script>

<style>
  :global(.mapboxgl-ctrl-top-left) {
    right: 0;
    bottom: 10vh;
    top: unset !important;
    left: unset !important;
  }
  :global(.mapboxgl-ctrl-top-left>.mapboxgl-ctrl-group) {
    margin: 15px 10px 0 0 !important;
  }
  :global(.mapboxgl-ctrl-top-right) {
    top: unset !important;
    bottom: calc(10vh + 75px);
  }
</style>

<Map
  accessToken='pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'
  style= { isDarkTheme ? darkModeMapStyle : lightModeMapStyle }
  center={location}
  zoom={12}
  bind:this={mapComponent}
  on:ready={init}
  options={{minZoom: 8, maxZoom: 17, pitch: 40, maxPitch: 69 }}
  >
  {#await getCars()}
    <slot></slot>
  {:then}
    {#each cars as car (car.id)}
      <Marker car={car} sos={sos} />
    {/each}
  {/await}
  {#each trips as trip (trip.id)}
    <Path trip={trip} />
  {/each}
  <NavigationControl options={{ visualizePitch: true }} />
  <GeolocateControl/>
</Map>
