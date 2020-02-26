<script>
  import { Link } from 'svelte-routing'

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
    border-top: 1px solid grey;
    background: white;
    z-index: 1000;
    flex-wrap: nowrap;
    align-items: stretch;
    background: linear-gradient(to left, #19a160, #312d50);
  }
</style>

<nav>
  <Link to="/map"><i>🌐</i></Link>
  <Link to="/"><i>🏠</i></Link>
  <button type='button' on:click={getTrips}>{speed}</button>
  <button type='button' on:click={logout}>x</button>
</nav>
