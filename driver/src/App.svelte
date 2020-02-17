<script>
  import { onMount, onDestroy } from 'svelte'
  import { Router, Route } from 'svelte-routing'
  import sounds from './sounds'
  import actioncable from '@rails/actioncable'

  import axios from 'axios';
  axios.defaults.baseURL = 'https://cablook.taxi/api/drivers_app/'
  axios.defaults.headers.common['Auth-Token'] = localStorage.token;
  axios.defaults.headers.common['Content-Type'] = 'application/json'

  import Home from './routes/Home.svelte'
  import Session from './routes/Session.svelte'
  import Map from './routes/Map.svelte'
  import Nav from './Nav.svelte'

  let token = localStorage.token
  let carSpeed = 0
  let location = [32.0734339, 49.4185698]
  let watcher

  let subscription = null
  const cable = actioncable.createConsumer('wss://cablook.taxi/cable')
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
    console.log(geo)
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
    if (trip && attrs.status !== 4) {
      trips[i] = attrs
    } else if (trip && attrs.status === 4) {
      trips.splice(i, 1)
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
      console.log(data)
      sounds.proposal.play()
    },

    TripUnavailable: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      if (i < 0) return
      trips.splice(i, 1)
      trips = trips
      sounds.cancel.play()
    },

    TripAccepted: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      let trip = trips[i]
      trip.driver_id = data.driver_id
      trip.car_id = data.car_id
      trip.status = 1
      trips[i] = trip
      sounds.accept.play()
    },

    TripUpdated: (data) => {
      console.log(data)
      sounds.update.play()
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
      console.log(data)
    },

    TripDeclined: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      trips.splice(i, 1)
      trips = trips
      sounds.decline.play()
    }
  }

</script>

<style>
  html, body {
    position: relative;
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
    overflow: hidden;
  }

  main {
    height: calc(100vh - 41px);
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
    <Nav speed={carSpeed} logout={logout}/>
  {:else}
    <main>
      <Route path="/" component={Session} login={login} />
    </main>
  {/if}
</Router>
