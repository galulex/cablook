<script>
  import { Link } from 'svelte-routing'

  import Home from '../images/Home.svelte'
  import CrossX from '../images/Cross_X.svelte'
  import Pin from '../images/Pin.svelte'

  import '../css/nav_bar.css'

  export let speed
  export let logout
  export let getTrips
</script>

<nav>
  <Link to="/map"><Pin/></Link>
  <Link to="/"><Home/></Link>
  <button type='button' on:click={getTrips}>{speed}</button>
  <button type='button' on:click={logout}><CrossX/></button>
</nav>
