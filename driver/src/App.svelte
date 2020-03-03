<script>
  import { onMount, onDestroy, setContext } from 'svelte'
  import { Router, Route } from 'svelte-routing'
  import Sounds from './Sounds.svelte'
  import actioncable from '@rails/actioncable'

  import axios from 'axios'
  axios.defaults.baseURL = 'https://cablook.taxi/api/drivers_app/'
  axios.defaults.headers.common['Auth-Token'] = localStorage.token
  axios.defaults.headers.common['Content-Type'] = 'application/json'

  import Home from './routes/Home.svelte'
  import Session from './routes/Session.svelte'
  import Map from './routes/Map.svelte'
  import Nav from './Nav.svelte'

  let token = localStorage.token
  let carSpeed = 0
  let location
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
      location: location
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
    watcher = navigator.geolocation.watchPosition(sendLocation, null, { enableHighAccuracy: true })
  }

  let logout = () => {
    if (!confirm('Are you sure?')) return
    localStorage.clear()
    token = null
    if (subscription) subscription.unsubscribe()
    axios.delete('sessions')
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
      window.play('proposal')
    },

    TripUnavailable: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      if (i < 0) return
      trips.splice(i, 1)
      trips = trips
      window.play('cancel')
    },

    TripAccepted: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      let trip = trips[i]
      if (i < 0) return
      trip.driver_id = data.driver_id
      trip.car_id = data.car_id
      trip.status = 1
      trips[i] = trip
    },

    DriverSignOut: (data) => {
      console.log(data)
    },

    SOS: (data) => {
      console.log(data)
    },

    TripDeclined: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      trips.splice(i, 1)
      trips = trips
      window.play('decline')
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
      <Sounds/>
      <Route path="/">
        {#await getTrips()}
          <h1><b>⌛</b> Завантаження...</h1>
        {:then}
          <Home trips={trips} updateTrip={updateTrip} location={location} cable={cable} />
        {:catch error}
          <h1>Сталася помилка перезайдіть в акаунт</h1>
          <br/>
          <h2>{error}</h2>
          <h3>{localStorage.token}</h3>
        {/await}
      </Route>
      <Route path="/map">
        <Map cable={cable} location={location} trips={trips.filter(trip => { return trip.driver_id === parseInt(localStorage.id) && trip.status !== 0 })}/>
      </Route>
    </main>
    <Nav speed={carSpeed} logout={logout} getTrips={getTrips}/>
  {:else}
    <main>
      <Route path="/" component={Session} login={login} />
    </main>
  {/if}
</Router>
