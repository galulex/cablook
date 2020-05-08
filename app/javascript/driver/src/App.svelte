<script>
  import { onMount, onDestroy, setContext } from 'svelte'
  import { Router, Route, navigate } from 'svelte-routing'
  import Sounds from './Sounds.svelte'
  import { createConsumer } from '@rails/actioncable'

  import axios from 'axios'
  axios.defaults.baseURL = '/api/drivers_app'
  axios.defaults.headers.common['Content-Type'] = 'application/json'

  import Home from './routes/Home.svelte'
  import Session from './routes/Session.svelte'
  import Map from './routes/Map.svelte'
  import Nav from './Nav.svelte'
  import Spinner from './Spinner.svelte'
  import Sos from './Sos.svelte'

  let isLoggedIn = !!document.cookie.match(/token/)
  let carSpeed = 0
  let location = [32.073095,49.418461]
  let watcher
  let sos

  let subscription = null
  const cable = createConsumer()
  let trips = []

  onMount(() => {
    if (!isLoggedIn) return
    subscribe()
    watcher = navigator.geolocation.watchPosition(sendLocation, null, { enableHighAccuracy: true })
    loadScript()
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
    localStorage.id = driver.id
    localStorage.carId = car.id
    localStorage.carNumber = car.number
    localStorage.token = driver.auth_token
    isLoggedIn = true
    subscribe()
    watcher = navigator.geolocation.watchPosition(sendLocation, null, { enableHighAccuracy: true })
  }

  let logout = () => {
    if (!confirm('Are you sure?')) return
    localStorage.clear()
    isLoggedIn = false
    if (subscription) subscription.unsubscribe()
    navigate('/', { replace: true })
    axios.delete('sessions')
  }

  let sendSos = () => {
    if (!confirm('Відправити SOS повідомлення іншим водіям?')) return
    if (!subscription) return
    let params = { car_id: parseInt(localStorage.carId) }
    subscription.perform('sos', { body: JSON.stringify(params) })
  }

  let getTrips = (async () => {
    let res = await axios.get('trips/all')
    trips = res.data.trips
    return trips
  })

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => { cableActions[data.action](data) }
    })
  }

  let loadScript = () => {
    if (document.getElementById('google-script') === null) {
      let script = document.createElement('script');
      script.setAttribute('id', 'google-script');
      script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDg2-aLroQJWY8LV8x1Gv5ZYDhIArWCDeU&libraries=places`);
      document.body.appendChild(script);
    }
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
    trips = trips.sort((a, b ) => {return (a.start_at - b.start_at)})
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
      let parsedData = JSON.parse(data.body)
      window.play('sos')
      sos = parsedData.car_id
      navigate('/map', { replace: true })
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
  main {
    height: calc(100vh - 39px);
    background: linear-gradient(to right, var(--bg_gradient_color_2), var(--bg_gradient_color_1), var(--bg_gradient_color_2));
  }

  :global(.mapboxgl-popup.background-red>.mapboxgl-popup-content) {
    background-color: red;
  }
  :global(.mapboxgl-popup.background-red>.mapboxgl-popup-tip) {
    border-top-color: red;
  }
</style>

<Router>
  {#if isLoggedIn}
    <Sounds/>
    <main>
      <Route path="/">
        {#await getTrips()}
          <Spinner/>
        {:then}
          <Home trips={trips} updateTrip={updateTrip} location={location} cable={cable} />
        {:catch error}
          <h3>Сталася помилка перезайдіть в акаунт</h3>
        {/await}
      </Route>
      <Route path="/map">
        <Map cable={cable} location={location} sos={sos} trips={trips.filter(trip => { return trip.driver_id === parseInt(localStorage.id) && trip.status !== 0 })}/>
      </Route>
    </main>
    <Nav speed={carSpeed} logout={logout} getTrips={getTrips}/>
    <Sos sendSos={sendSos}/>
  {:else}
    <Route path="/" component={Session} login={login} />
  {/if}
</Router>
