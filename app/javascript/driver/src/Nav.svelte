<script>
  import { Link } from 'svelte-routing'

  import Home from '../images/Home.svelte'
  import Pin from '../images/Pin.svelte'
  import Profile from '../images/Profile.svelte'

  import '../css/nav_bar.css'

  export let speed
  export let getTrips
</script>

<nav>
  <Link to="/map"><Pin/></Link>
  <Link to="/"><Home/></Link>
  <button type='button' on:click={getTrips}>{speed}</button>
  <Link to="/statistic"><Profile/></Link>
</nav>
