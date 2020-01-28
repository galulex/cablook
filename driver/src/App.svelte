<script>
  import './styles/App.scss';

  import { onMount, onDestroy } from 'svelte'
  import { Router, Route, Link } from 'svelte-routing'
  import { createConsumer } from '@rails/actioncable'

  import axios from 'axios';
  axios.defaults.baseURL = 'http://localhost:3000/api/drivers_app/'
  axios.defaults.headers.common['Auth-Token'] = localStorage.token;
  axios.defaults.headers.common['Content-Type'] = 'application/json';

  import Home from './routes/Home.svelte';
  import Session from './routes/Session.svelte';
  import Map from './routes/Map.svelte';

  let token = localStorage.token

  let subscription = null
  const cable = createConsumer('wss://cablook.taxi/cable')
  let trips = {}

  onMount(() => {
    if (!token) return
    subscribe()
    getTrips()
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let login = (driver) => {
    localStorage.token = driver.auth_token
    localStorage.id = driver.id
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
      console.log(trip)
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
    }
  }

</script>

<Router>
  {#if token}
    <main>
      <Route path="/"><Home trips={trips} /></Route>
      <Route path="/map"><Map cable={cable}/></Route>
    </main>
    <nav>
      <Link to="/map">🌐</Link>
      <Link to="/">🏠</Link>
      <button class='button-clear' type='button' on:click={logout}>⏻</button>
    </nav>
  {:else}
    <Route path="/" component={Session} login={login} />
  {/if}
</Router>
