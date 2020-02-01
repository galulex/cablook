<script>
  import Trip from './home/trip.svelte'
  import Proposal from './home/proposal.svelte'

  export let trips = {}
</script>

<style>
  section {
    display: flex;
    width: 100%;
    overflow-x: auto;
    flex: 1 1 auto;
    scroll-snap-type: x mandatory;
    scroll-behavior: smooth;
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
    scroll-snap-type: y mandatory;
    scroll-behavior: smooth;
  }
</style>

<section>
  <ol id='proposals'>
    {#each trips.filter(trip => { return trip.status === 0 }) as trip (trip.id)}
      <Proposal trip={trip}/>
    {/each}
  </ol>
  <ol id='current'>
    {#each trips.filter(trip => { return trip.driver_id === parseInt(localStorage.id) }) as trip (trip.id)}
      <Trip trip={trip}/>
    {/each}
  </ol>
</section>
