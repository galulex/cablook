<script>
  import "./styles/App.scss";

  import { Router, Route, Link } from "svelte-routing";

  import axios from 'axios';
  axios.defaults.baseURL = 'http://localhost:3000/api/drivers_app/';
  axios.defaults.headers.common['Auth-Token'] = localStorage.token;
  axios.defaults.headers.common['Content-Type'] = 'application/json';

  import Home from "./routes/Home.svelte";
  import Session from "./routes/Session.svelte";

  let token = localStorage.token

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
</script>

<Router>
  <main>
    {#if token}
      <nav>
        <Link to="/">Home</Link>
        <Link to="/map">Map</Link>
      </nav>
      <button type='button' on:click={logout}>Log out</button>
    {:else}
      <Route path="/" component={Session} login={login} />
    {/if}
  </main>
</Router>
