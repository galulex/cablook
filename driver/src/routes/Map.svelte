<script>
  import { onDestroy } from 'svelte'

  import mapboxgl from 'mapbox-gl'
  import { Map, controls } from '@beyonk/svelte-mapbox'
  import Marker from './map/marker.svelte'
  import axios from 'axios'

  const { GeolocateControl, NavigationControl, ScalingControl } = controls

  export let cable
  export let location

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
    car.position = car.location
    car.location = data.location
    cars[i] = car
  }

  let getCars = (async () => {
    let res = await axios.get('maps')
    cars = res.data
    subscribe()
    return cars
  })
</script>

<style>
  .map {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100%;
    height: 100%;
    height: 100vh;
  }
</style>

<Map
  accessToken='pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'
  style='mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z'
  options={{center: location, minZoom: 8, maxZoom: 17, zoom: 12}}
  >
  {#await getCars()}
  {:then}
    {#each cars as car (car.id)}
      <Marker car={car} />
    {/each}
  {/await}
  <NavigationControl/>
  <GeolocateControl/>
</Map>
