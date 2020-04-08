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
    padding: 25px 20px 60px 15px;
    margin: 20px 50px;
    position: relative;
    background: var(--input_bg_color);
    box-shadow: inset -2px -1px 8px var(--trip_shadow_color);
    border-radius: 10px;
    font-size: 16px;
    color: var(--text_grey_color);
  }

  address {
    font-style: normal;
    margin-bottom: 10px;
    padding-left: 5px;
  }

  address label {
    padding-left: 10px;
    width: 85%;
    display: inline-flex;
  }

  vip {
    position: absolute;
    right: 20px;
    top: 25px;
    font-weight: 400;
    color: var(--red_color);
  }
</style>

<li bind:this={proposal}>
  {#if trip.vip}<vip>VIP</vip>{/if}
  {#each trip.stops as stop, i}
    {#if i == 0}
      <address><Pin style={{fill: bgColor(), width: '15px', height: '15px' }}/><label>{stop}</label></address>
    {:else}
      <address><Pin style={{fill: 'black', width: '15px', height: '15px' }}/><label>{stop}</label></address>
    {/if}
  {/each}
  {#await osrm()}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {:then result}
    <Actions trip={trip} duration={result.duration} distance={result.distance} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {:catch error}
    <Actions trip={trip} duration={'⌛'} distance={'⌛'} bgColor={bgColor()} btnStyle={btnStyle()} updateTrip={updateTrip}/>
  {/await}
</li>
