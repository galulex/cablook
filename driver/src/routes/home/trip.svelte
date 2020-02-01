<script>
  import axios from 'axios'
  import Map from './map.svelte'

  export let trip

  let duration = (trip.duration/60).toFixed(1)
  let distance = (trip.distance/1000).toFixed(1)

  let cancel = () => {
    axios.patch(`trips/${trip.id}/cancel`)
    /* if (!confirm('Are you sure?')) return */
  }
</script>

<style>
  li {
    scroll-snap-align: start;
    height: inherit;
  }
</style>

<li>
  <Map trip={trip}/>
  <div>
    {#each trip.stops as stop, i}
      <address>{stop}</address>
    {/each}
    <time datatime={trip.start_at}>⏰ {trip.start_time}</time>
    <br/>
    <span>{distance} KM</span>
    <blockquote>{trip.comment}</blockquote>
    <button type='button'>Arrived</button>
    <br/>
    <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>✆</a>
    <br/>
    <a class='button' href={`tel:${trip.user_number}`}>NAVIGATOR</a>
    <br/>
    <button type='button' on:click={cancel}>Cancel</button>
  </div>
</li>
