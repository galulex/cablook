<script>
  import { onMount } from 'svelte'
  import axios from 'axios'
  import Actions from './actions.svelte'

  export let trip
  export let location
  export let updateTrip
  let proposal

  onMount(() => {
    proposal.scrollIntoView()
  })

  let klass = () => {
    if (trip.vip) return 'vip'
    if (trip.pre_order) return 'preorder'
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
  ol > li {
    scroll-snap-align: start;
    padding: 20px 20px 40px 20px;
    margin: 20px;
    border: 1px solid gray;
    position: relative;
    background: wheat;
  }

  .preorder {
    background: #06a092;
  }

  .vip {
    background: #ff8484;
  }
</style>

<li bind:this={proposal} class={klass()}>
  {#each trip.stops as stop, i}
    <address><b>📍</b> {stop}</address>
  {/each}
  {#await osrm()}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'}, updateTrip={updateTrip}/>
  {:then result}
    <Actions trip={trip} duration={result.duration} distance={result.distance} updateTrip={updateTrip}/>
  {:catch error}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'} updateTrip={updateTrip}/>
  {/await}
</li>
