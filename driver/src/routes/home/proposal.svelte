<script>
  import axios from 'axios'

  export let trip
  export let location

  let accept = () => {
    axios.patch(`trips/${trip.id}/accept`)
  }

  let start = location
  let finish = trip.waypoints[0].split(',').reverse().join(',')

  let osrm =(async () => {
    let res = await fetch(`https://osrm.cablook.taxi/route/v1/driving/${start};${finish}?overview=false`)
    let json = await res.json()
    let result = json.routes[0]
    return { distance: Math.round(result.distance/1000), duration: Math.round(result.duration/60) }
  })
</script>

<style>
  li {
    scroll-snap-align: start;
    height: inherit;
  }
</style>

<li>
  <ul>
    {#each trip.stops as stop, i}
      <li>{stop}</li>
    {/each}
  </ul>
  {#await osrm()}
    <p>⌛</p>
  {:then result}
    <p>📍{result.distance}KM - ⏰{result.duration}XB</p>
  {/await}
  <blockquote>{trip.comment}</blockquote>
  <br/>
  <button type='button' on:click={accept}>GO</button>
</li>
