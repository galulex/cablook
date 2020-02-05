<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'

  export let trip
  export let location
  export let updateTrip
  let interval

  let createTime = new Date(trip.created_at).getTime()
  let current = new Date().getTime()
  let time = 70 - Math.floor((current - createTime)/1000)

  onMount(() => {
    interval = setInterval(countdown, 1000)
  })

  onDestroy(() => {
    clearInterval(interval)
  })

  let countdown = () => {
    //TODO handle timer on trip retry. Require back-end updates
    let current = new Date().getTime()
    time = 70 - Math.floor((current - createTime)/1000)
    if (time < 0) {
      clearInterval(interval)
      time = 'WTF'
    }
  }

  let accept = () => {
    axios.patch(`trips/${trip.id}/accept`).then(res => {
      updateTrip(res.data)
    })
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
    padding: 20px;
    margin: 20px;
    border: 1px solid gray;
  }
</style>

<li>
  {#each trip.stops as stop, i}
    <address>{stop}</address>
  {/each}
  {#await osrm()}
    <p>⌛</p>
  {:then result}
    <p>📍{result.distance}KM - ⏰{result.duration}XB</p>
  {/await}
  <time>⏰ {time}</time>
  <blockquote>{trip.comment}</blockquote>
  <br/>
  <button type='button' on:click={accept}>GO</button>
</li>
