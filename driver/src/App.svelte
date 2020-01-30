<script>
  import { onMount, onDestroy } from 'svelte'
  import { Router, Route, Link } from 'svelte-routing'
  import actioncable from '@rails/actioncable'

  import axios from 'axios';
  axios.defaults.baseURL = 'https://cablook.taxi/api/drivers_app/'
  axios.defaults.headers.common['Auth-Token'] = localStorage.token;
  axios.defaults.headers.common['Content-Type'] = 'application/json';

  import Home from './routes/Home.svelte';
  import Session from './routes/Session.svelte';
  import Map from './routes/Map.svelte';

  let token = localStorage.token
  let carSpeed
  let watcher

  let subscription = null
  const cable = actioncable.createConsumer('wss://cablook.taxi/cable')
  let trips = {}


  onMount(() => {
    if (!token) return
    subscribe()
    getTrips()
    watcher = navigator.geolocation.watchPosition(sendLocation)
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
    if (watcher) watcher.clearWatch()
  })

  let sendLocation = (geo) => {
    let { latitude, longitude, speed } = geo.coords
    carSpeed = speed
    if (!subscription) return

    let params = {
      car_id: parseInt(localStorage.carId),
      speed: speed,
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

  let getTrips = () => {
    axios.get('trips').then((res) => {
      res.data.trips.forEach(trip => {
        trips[trip.id] = trip
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
    axios.get('trips/currents').then((res) => {
      res.data.trips.forEach(trip => {
        trips[trip.id] = trip
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => { cableActions[data.action](data) }
    })
  }

  let cableActions = {
    SendLocation: (data) => {
    },

    TripPropose: (data) => {
      let trip = JSON.parse(data.trip)
      trips[trip.id] = trip
    },

    TripUnavailable: (data) => {
      console.log(data)
    },

    TripAccepted: (data) => {
      console.log(data)
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

    TripAccepted: (data) => {
      console.log(data)
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
      <Route path="/"><Home trips={trips} /></Route>
      <Route path="/map"><Map cable={cable}/></Route>
    </main>
    <nav>
      <Link to="/map">🌐</Link>
      <Link to="/">🏠</Link>
      <a href='#'>👠</a>
      <button class='button-clear' type='button' on:click={logout}>⏻</button>
    </nav>
  {:else}
    <Route path="/" component={Session} login={login} />
  {/if}
</Router>
