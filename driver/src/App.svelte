<script>
  import './styles/App.scss';

  import { onMount } from 'svelte'
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
  export let url = ''

  let subscription = null
  const cable = createConsumer('wss://cablook.taxi/cable')
  let car
  let location

  onMount(async () => {
    /* subscribe() */
  })

  let login = (driver) => {
    localStorage.token = driver.auth_token
    token = driver.auth_token
  }

  let logout = () => {
    if (!confirm('Are you sure?')) return
    axios.delete('sessions').then(() => {
      localStorage.clear()
      token = null
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'DriverMapChannel' },
      {
        received: data => {
          cableActions[data.action](data)
        }
      }
    )
  }

  let cableActions = {
    SendLocation: (data) => {
      console.log(data)
    }
  }

</script>

<Router url={url}>
  <main>
    {#if token}
      <nav>
        <Link to="/">Home</Link>
        <Link to="/map">Map</Link>
      </nav>
      <button type='button' on:click={logout}>Log out</button>
      <Route path="/" component={Home} />
      <Route path="/map">
        <Map cable={cable}/>
      </Route>
    {:else}
      <Route path="/" component={Session} login={login} />
    {/if}
  </main>
</Router>
