<script>
  import { onMount, onDestroy } from 'svelte'
  import { Router, Route, navigate } from 'svelte-routing'
  import Sounds from './Sounds.svelte'
  import { createConsumer } from '@rails/actioncable'
  import Home from './routes/Home.svelte'
  import Wakelock from './Wakelock.svelte'
  import Session from './routes/Session.svelte'
  import Map from './routes/Map.svelte'
  import Nav from './Nav.svelte'
  import Spinner from './Spinner.svelte'
  import Sos from './Sos.svelte'
  import Profile from './routes/Profile.svelte'

  import axios from 'axios'
  axios.defaults.baseURL = '/api/drivers_app'
  axios.defaults.headers.common['Content-Type'] = 'application/json'

  let isLoggedIn = !!document.cookie.match(/token/) && localStorage.token
  let carSpeed = 0
  let location = [32.073095,49.418461]
  let watcher
  let sos
  let settings = {}
  let subscription = null

  let trips = []
  let currentTrips = []

  const cable = createConsumer()
  const removeFromCurrentTrips = (id) => currentTrips = currentTrips.filter((trip_id) => trip_id !== id)

  onMount(() => {
    if (isLoggedIn) onStart()
  })

  onDestroy(() => {
    subscription.unsubscribe()
    watcher.clearWatch()
  })

  let sendLocation = (geo) => {
    if (!isLoggedIn) return
    console.log(geo)
    let { latitude, longitude, speed } = geo.coords
    carSpeed = Math.round(speed * 3.6) || 0
    if (!subscription) return

    let params = {
      car_id: parseInt(localStorage.carId),
      speed: carSpeed,
      latitude: latitude,
      longitude: longitude,
      current_trips: currentTrips
    }
    subscription.perform('send_location', { body: JSON.stringify(params) })
  }

  let login = (driver, car) => {
    localStorage.id = driver.id
    localStorage.carId = car.id
    localStorage.carNumber = car.number
    localStorage.token = driver.auth_token
    isLoggedIn = true
    onStart()
  }

  const onStart = () => {
    subscribe()
    setWatcher()
    loadScript()
    getCurrentTrips()
  }

  let logout = () => {
    if (!confirm('Are you sure?')) return
    axios.delete('sessions')
    onLogout()
  }

  const onLogout = () => {
    localStorage.clear()
    isLoggedIn = false
    currentTrips = []
    subscription.unsubscribe()
    navigate('/', { replace: true })
  }

  let sendSos = () => {
    if (!confirm('Відправити SOS повідомлення іншим водіям?')) return
    if (!subscription) return
    let params = { car_id: parseInt(localStorage.carId) }
    subscription.perform('sos', { body: JSON.stringify(params) })
  }

  const getTrips = async () => {
    return { data: { trips, settings }} = await axios.get('trips/all').catch(onRequestError)
  }

  const getCurrentTrips = () => {
    axios.get('trips/currents').then(({data}) => currentTrips = data.trips.map((trip) => trip.id)).catch(onRequestError)
  }

  const onRequestError = ({response: {status}}) => {
    if (status === 401) onLogout()
  }

  let subscribe = () => {
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' }, {
      received: data => { cableActions[data.action](data) }
    })
  }

  let geoError = (error) => {
    alert(error.message)
  }

  let setWatcher = () => {
   watcher = navigator.geolocation.watchPosition(sendLocation, geoError, { enableHighAccuracy: true })
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
      window.play('proposal')
    },

    TripAccepted: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      let trip = trips[i]
      if (i < 0) return
      trip.driver_id = data.driver_id
      trip.car_id = data.car_id
      trip.status = 1
      trips[i] = trip
      if (data.driver_id === parseInt(localStorage.id)) currentTrips.push(trip.id)
    },

    TripUnavailable: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      removeFromCurrentTrips(data.trip_id)
      if (i < 0) return
      trips.splice(i, 1)
      trips = trips
      window.play('cancel')
    },

    TripDeclined: (data) => {
      let i = trips.findIndex(trip => trip.id === data.trip_id)
      removeFromCurrentTrips(data.trip_id)
      trips.splice(i, 1)
      trips = trips
      window.play('decline')
    },

    TripFinished: (data) => {
      removeFromCurrentTrips(data.trip_id)
    },

    TripUnrelised: (data) => {
      removeFromCurrentTrips(data.trip_id)
    },

    DriverSignIn: (data) => {
      if (data.id === parseInt(localStorage.id)) onLogout()
    },

    SOS: (data) => {
      let parsedData = JSON.parse(data.body)
      window.play('sos')
      sos = parsedData.car_id
      navigate('/map', { replace: true })
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
    <Wakelock/>
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
      <Route path="/statistic">
        <Profile logout={logout}/>
      </Route>
    </main>
    <Nav speed={carSpeed} getTrips={getTrips}/>
    {#if settings.sos } <Sos sendSos={sendSos}/>{/if}
  {:else}
    <Route path="/" component={Session} login={login} />
  {/if}
</Router>
