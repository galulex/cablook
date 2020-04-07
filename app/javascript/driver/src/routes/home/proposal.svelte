<script>
  import { onMount } from 'svelte'
  import axios from 'axios'
  import Actions from './actions.svelte'

  import Pin from '../../../images/Pin.svelte'

  export let trip
  export let location
  export let updateTrip
  let proposal

  onMount(() => {
    proposal.scrollIntoView()
  })

  let start = location
  let finish

  //TODO catch very old app that does not have waypoints at all
  try {
    finish = trip.waypoints[0].split(',').reverse().join(',')
  } catch {
    finish = trip.departure.reverse().join(',')
  }

  let osrm =(async () => {
    let res = await fetch(`https://osrm.cablook.taxi/route/v1/driving/${start};${finish}?overview=false`)
    let json = await res.json()
    let result = json.routes[0]
    return { distance: Math.round(result.distance/1000), duration: Math.round(result.duration/60) }
  })

  let bgColor = () => {
    if (trip.vip) return 'var(--red_color)'
    if (trip.pre_order) return 'var(--blue_color)'

    return 'var(--yellow_color)'
  }

  let textColor = () => {
    if (trip.vip || trip.pre_order) return 'var(--white_color)'
    return 'var(--main_dark_color)'
  }

  let btnStyle = () => {
    return `background: ${bgColor()}; color: ${textColor()};`
  }
</script>

<style>
  ol > li {
    scroll-snap-align: start;
    padding: 20px 20px 60px 20px;
    margin: 20px 50px;
    position: relative;
    background: #eaefed;
    box-shadow: inset -2px -1px 8px #dbe2e1;
    border-radius: 10px;
  }

  address {
    font-style: normal;
  }
</style>

<li bind:this={proposal}>
  {#each trip.stops as stop, i}
    <address><Pin style={{fill: bgColor(), width: '15px' }}/> {stop}</address>
  {/each}
  {#await osrm()}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {:then result}
    <Actions trip={trip} duration={result.duration} distance={result.distance} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {:catch error}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {/await}
</li>
