<script>
  import axios from 'axios'

  export let trip

  let accept = () => {
    axios.patch(`trips/${trip.id}/accept`)
  }
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
  <blockquote>{trip.comment}</blockquote>
  <br/>
  <button type='button' on:click={accept}>GO</button>
</li>
