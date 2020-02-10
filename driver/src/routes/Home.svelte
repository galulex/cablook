<script>
  import Trip from './home/trip.svelte'
  import Proposal from './home/proposal.svelte'

  export let trips = {}
  export let updateTrip
  export let location
</script>

<style>
  section {
    display: flex;
    width: 100%;
    overflow-x: auto;
    flex: 1 1 auto;
    scroll-snap-type: x mandatory;
    scroll-behavior: smooth;
    position: relative;
  }

  ol {
    height: calc(100vh - 41px);
    overflow-y: auto;
    overflow-x: hidden;
    flex: 0 0 auto;
    width: 100%;
    scroll-snap-align: start;
    list-style: none;
    padding: 0;
    margin: 0;
    scroll-snap-type: y mandatory;
    scroll-behavior: smooth;
  }

  .slider {
    position: absolute;
    bottom: 10px;
    right: 0;
    transform: translateX(48%);
    z-index: 100;
  }

  .slider button {
    padding: 0;
    font-size: 5rem;
    border: none;
    background: none;
  }
</style>

<section>
  <div class='slider'>
    <button type='button'>‹</button>
    <button type='button'>›</button>
  </div>
  <ol id='proposals'>
    {#each trips.filter(trip => { return trip.status === 0 }) as trip (trip.id)}
      <Proposal trip={trip} updateTrip={updateTrip} location={location} />
    {/each}
  </ol>
  <ol id='current'>
    {#each trips.filter(trip => { return trip.driver_id === parseInt(localStorage.id) && trip.status !== 0 }) as trip (trip.id)}
      <Trip trip={trip} updateTrip={updateTrip} />
    {/each}
  </ol>
</section>
