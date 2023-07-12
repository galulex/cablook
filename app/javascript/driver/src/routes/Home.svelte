<script>
  import { onMount } from 'svelte'
  import Trip from './home/trip.svelte'
  import Proposal from './home/proposal.svelte'

  export let trips = []
  export let updateTrip
  export let location
  export let cable

  let component

  onMount(() => {
    component.scrollIntoView()
  })

  let isBusy = () => {
    return trips.some(trip => {
      return (trip.driver_id === parseInt(localStorage.id) && !trip.pre_order && [1,2,3].includes(trip.status))
    })
  }
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
    height: 90vh;
    overflow-y: auto;
    overflow-x: hidden;
    flex: 0 0 auto;
    width: 100%;
    scroll-snap-align: start;
    list-style: none;
    padding: 0 0 50px 0;
    margin: 0;
    scroll-snap-type: y mandatory;
    scroll-behavior: smooth;
  }

  @media (min-width: 80.0rem) {
    ol {
      width: 50%;
    }
  }

  .slider {
    position: absolute;
    bottom: 70px;
    right: 0;
    transform: translateX(48%);
    z-index: 100;
  }

  .slider button {
    font-size: 5rem;
    color: var(--text_grey_color);
    background: var(--bg_gradient_color_1);
  }
</style>

<section bind:this={component}>
  <div class='slider'>
    <button type='button' on:click={() => document.getElementById('current').scrollIntoView()}>‹</button>
    <button type='button' on:click={() => document.getElementById('proposals').scrollIntoView()}>›</button>
  </div>
  <ol id='proposals'>
    {#each trips.filter(trip => { return trip.status === 0 }) as trip (trip.id)}
      <Proposal trip={trip} updateTrip={updateTrip} location={location} isBusy={isBusy()} />
    {/each}
  </ol>
  <ol id='current'>
    {#each trips.filter(trip => { return trip.driver_id === parseInt(localStorage.id) && [1,2,3].includes(trip.status) }) as trip (trip.id)}
      <Trip trip={trip} updateTrip={updateTrip} cable={cable}/>
    {/each}
  </ol>
</section>
