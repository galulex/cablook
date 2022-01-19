<script>
  import { onDestroy, onMount } from 'svelte'

  import mapboxgl from '!mapbox-gl'
  import { Map, controls } from '@beyonk/svelte-mapbox'
  import Marker from './map/marker.svelte'
  import Path from './map/path.svelte'
  import axios from 'axios'

  import 'mapbox-gl/dist/mapbox-gl.css'
  import '../../css/map.css'

  const { GeolocateControl, NavigationControl, ScalingControl } = controls

  export let cable
  export let location
  export let trips
  export let sos

  let map
  let cars = []
  let carElement
  let markers = []
  let subscription

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  onMount(async () => {
    mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA';

    map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z',
      center: [32.0542891, 49.428731],
      zoom: 16,
      minZoom: 5,
      maxZoom: 18,
      pitch: 60,
      bearing: 0,
      maxPitch: 79,
    })

    await getCars()
    cars.map(car => {
      car.marker = new mapboxgl.Marker(carElement.cloneNode(true), {}).setLngLat([32.0542891, 49.428731]).addTo(map)
    })


    map.on('move', (e) => {
      document.documentElement.style.setProperty('--y', Math.trunc((map.getPitch() || 100) / 16) + 1)
      if (!map.isRotating()) return
      document.documentElement.style.setProperty('--x', 240 - Math.trunc(map.getBearing() / 3))
    })
  })

  let subscribe = () => {
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => {
        if (data.action === 'SendLocation') updateCar(data)
      }
    })
  }

  let bearing = (start, end) => {
    let y = Math.sin(end[0] - start[0]) * Math.cos(end[1]);
    let x = Math.cos(start[1]) * Math.sin(end[1]) -
      Math.sin(start[1]) * Math.cos(end[1]) * Math.cos(end[0] - start[0]);
    return Math.atan2(y, x) * 180 / Math.PI
  }

  let updateCar = (data) => {
    let i = cars.findIndex(car => car.id === data.car_id)
    let car = cars[i]
    if (i < 0 || (car.location[0] === data.location[0] && car.location[1] === data.location[1])) return
    car.position = car.location
    car.location = data.location
    car.speed = data.speed
    cars[i] = car

    if (!isFarEnough(car.position, car.location)) return

    let deg = 240 - Math.trunc(bearing(car.position, car.location) / 3)
    let diff = Math.abs((car.bearing || 0) - deg)
    car.bearing = deg
    console.log(car.location)
    car.marker.setLngLat(car.location)
    car.marker._element.style.setProperty('--steps', diff)
    car.marker._element.style.setProperty('--bearing', car.bearing)
  }

  let isFarEnough = (start, end) => {
    let x = Math.abs(start[0] - end[0]) * 10000
    let y = Math.abs(start[1] - end[1]) * 10000
    return (x > 1 || y > 1)
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

  div#map {
    width: 100vw;
    height: 100vh;
    position: absolute;
  }

  figure {
    --bearing: 0;
    --x: 0;
    --speed: 10;
    --animation: ease-in;
    background: url('https://i.imgur.com/hgHsphP.png') transparent;
    width: 137px;
    height: 137px;
    background-position: calc((var(--x, 1) - var(--bearing)) * 137px) calc(var(--y, 1) * 137px);
    /* position: absolute; */
    /* top: 50%; */
    /* left: 50%; */
    /* transform: translate(-50%, -50%); */
    z-index: 100;
    margin: 0;
    display: inline-block;
    transition: transform 1s ease-in, background-position steps(var(--steps), start) 0.3s !important;
    position: absolute;
  }
</style>

<figure bind:this={carElement}></figure>
<div id='map'></div>
