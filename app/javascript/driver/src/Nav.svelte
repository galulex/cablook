<script>
  import { Link } from 'svelte-routing'

  import Home from '../images/Home.svelte'
  import CrossX from '../images/Cross_X.svelte'
  import Pin from '../images/Pin.svelte'

  export let speed
  export let logout
  export let getTrips
</script>

<style>
  nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    background: white;
    z-index: 1000;
    flex-wrap: nowrap;
    align-items: stretch;
    background: linear-gradient(to left, #19a160, #312d50);
    padding: 10px 0px;
    height: 10vh;
  }
</style>

<nav>
  <Link to="/map"><Pin/></Link>
  <Link to="/"><Home/></Link>
  <button type='button' on:click={getTrips}>{speed}</button>
  <button type='button' on:click={logout}><CrossX/></button>
</nav>
