<script>
  import { onMount, onDestroy } from 'svelte'
  import { Router, Route, Link } from 'svelte-routing'
  import actioncable from '@rails/actioncable'

  import axios from 'axios';
  axios.defaults.baseURL = 'http://localhost:3000/api/drivers_app/'
  axios.defaults.headers.common['Auth-Token'] = localStorage.token;
  axios.defaults.headers.common['Content-Type'] = 'application/json';

  import Home from './routes/Home.svelte';
  import Session from './routes/Session.svelte';
  import Map from './routes/Map.svelte';

  let token = localStorage.token
  let carSpeed = 0
  let location = [32.0734339, 49.4185698]
  let watcher

  let subscription = null
  const cable = actioncable.createConsumer('ws://localhost:3000/cable')
  let trips = []


  onMount(() => {
    if (!token) return
    watcher = navigator.geolocation.watchPosition(sendLocation, null, { enableHighAccuracy: true })
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
    if (watcher) watcher.clearWatch()
  })

  let sendLocation = (geo) => {
    let { latitude, longitude, speed } = geo.coords
    carSpeed = Math.round(speed * 3.6)
    location = [longitude, latitude]
    if (!subscription) return

    let params = {
      car_id: parseInt(localStorage.carId),
      speed: carSpeed,
      latitude: latitude,
      longitude: longitude
    }
    subscription.perform('send_location', { body: JSON.stringify(params) })
  }

  let login = (driver, car) => {
    localStorage.token = driver.auth_token
    localStorage.id = driver.id
    localStorage.carId = car.id
    localStorage.carNumber = car.number
    token = driver.auth_token
    subscribe()
  }

  let logout = () => {
    if (!confirm('Are you sure?')) return
    axios.delete('sessions').then(() => {
      localStorage.clear()
      token = null
      subscription.unsubscribe()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  let getTrips = (async () => {
    let res = await axios.get('trips/all')
    trips = res.data.trips
    subscribe()
    return trips
  })

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => { cableActions[data.action](data) }
    })
  }

  let updateTrip = (attrs) => {
    let i = trips.findIndex(trip => trip.id === attrs.id)
    let trip = trips[i]
    if (trip) {
      trips[i] = attrs
    } else {
      trips.unshift(attrs)
    }
    trips = trips
  }

  let cableActions = {
    SendLocation: (data) => {
    },

    TripPropose: (data) => {
      updateTrip(JSON.parse(data.trip))
    },

    TripUnavailable: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      trips.splice(i, 1)
      trips = trips
    },

    TripAccepted: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      let trip = trips[i]
      trip.driver_id = data.driver_id
      trip.car_id = data.car_id
      trip.status = 1
      trips[i] = trip
    },

    TripUpdated: (data) => {
      console.log(data)
    },

    DriverSignOut: (data) => {
      console.log(data)
    },

    PaymentResponse: (data) => {
      console.log(data)
    },

    SOS: (data) => {
      console.log(data)
    },

    TripAssigned: (data) => {
    },

    TripDeclined: (data) => {
    }
  }

</script>

<style>
  :root {
    --car-transition: 10s;
    --car-rotation: 4s;
  }

  html, body {
    position: relative;
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
    overflow: hidden;
  }

  nav a, nav button {
    width: 100%;
    text-align: center;
    margin: 0;
    padding: 0;
    height: auto;
    font-size: 2rem;
  }

  nav > a {
    border-right: 1px solid grey;
  }

  main {
    height: calc(100vh - 41px);
  }

  nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    border-top: 1px solid grey;
    background: white;
    z-index: 1000;
    flex-wrap: nowrap;
    align-items: stretch;
  }

  @media (min-width: 80.0rem) {
    ol {
      width: 50%;
    }
  }
</style>

<Router>
  {#if token}
    <main>
      <Route path="/">
        {#await getTrips()}
          <h1>Loading...</h1>
        {:then}
          <Home trips={trips} updateTrip={updateTrip} location={location} />
        {/await}
      </Route>
      <Route path="/map"><Map cable={cable}/></Route>
    </main>
    <nav>
      <Link to="/map">🌐</Link>
      <Link to="/">🏠</Link>
        <a href='#'>{carSpeed}</a>
      <button class='button-clear' type='button' on:click={logout}>⏻</button>
    </nav>
  {:else}
    <main>
      <Route path="/" component={Session} login={login} />
    </main>
  {/if}
</Router>
