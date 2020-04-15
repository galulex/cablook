<script>
  import { onDestroy } from 'svelte'

  import mapboxgl from 'mapbox-gl'
  import { Map, controls } from '@beyonk/svelte-mapbox'
  import Marker from './map/marker.svelte'
  import Path from './map/path.svelte'
  import axios from 'axios'

  import '../../css/map.css'

  const { GeolocateControl, NavigationControl, ScalingControl } = controls

  export let cable
  export let location
  export let trips
  export let sos

  let map
  let cars = []
  let subscription

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let subscribe = () => {
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => {
        if (data.action === 'SendLocation') updateCar(data)
      }
    })
  }

  let updateCar = (data) => {
    let i = cars.findIndex(car => car.id === data.car_id)
    let car = cars[i]
    if (i < 0) return
    car.position = car.location
    car.location = data.location
    car.speed = data.speed
    cars[i] = car
  }

  let getCars = (async () => {
    let res = await axios.get('maps')
    cars = res.data
    subscribe()
    return cars
  })
</script>

<Map
  accessToken='pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'
  style='mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z'
  options={{center: location, minZoom: 8, maxZoom: 17, zoom: 12}}
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
  <NavigationControl/>
  <GeolocateControl/>
</Map>
