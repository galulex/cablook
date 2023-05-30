<script>
  import { Link } from 'svelte-routing'
  import { onMount, afterUpdate } from 'svelte'
  import Home from '../images/Home.svelte'
  import Pin from '../images/Pin.svelte'
  import Profile from '../images/Profile.svelte'

  import '../css/nav_bar.css'

  export let speed
  export let getTrips

  onMount(() => {
    document.documentElement.style.setProperty('--speed-color', 'var(--white)');
  })

  afterUpdate(() => {
    document.documentElement.style.setProperty('--speed-color', speedColor(speed));
	});

  const speedColor = (value) => {
    let red,green,blue

    if (value < 60) {
      red = 240 + value / 10
      green = 200 - value * 1.7
      blue = 220 - value * 5
    } else {
      red = 255
      green = 200 - value * 1.7
      blue = 0
    }

    return `rgb(${red}, ${green}, ${blue})`
  }

</script>

<nav>
  <Link to="/map"><Pin/></Link>
  <Link to="/"><Home/></Link>
  <button type='button' on:click={getTrips}>{speed}</button>
  <Link to="/statistic"><Profile/></Link>
</nav>
