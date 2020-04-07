<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'

  import Leaf from '../../../images/Leaf_black.svelte'
  import Timer from '../../../images/Timer.svelte'
  import Clock from '../../../images/Clock.svelte'
  import Distance from '../../../images/Distance.svelte'

  export let trip
  export let distance
  export let duration
  export let updateTrip
  let interval

  let createTime = new Date(trip.created_at).getTime()
  let current
  let time
  let disabled = false
  let disabledButton = false

  onMount(() => {
    countdown()
    interval = setInterval(countdown, 1000)
  })

  onDestroy(() => {
    clearInterval(interval)
  })

  let countdown = () => {
    //TODO handle timer on trip retry. Require back-end updates
    let current = new Date().getTime()
    time = 70 - Math.floor((current - createTime)/1000)
    disabled = isDisabled(time)
    if (time < 0) {
      clearInterval(interval)
      time = 'WTF'
    }
  }

  let accept = () => {
    disabledButton = true
    axios.patch(`trips/${trip.id}/accept`).then(res => {
      updateTrip(res.data)
      window.play('accept')
    }).catch((error) => {
      disabledButton = false
      if (error.response) alert(error.response.data.errors)
    })
  }

  let isDisabled = (time) => {
    return !(
      (distance <= 2) ||
      (distance > 2 && distance <= 4 && time <= 60) ||
      (distance > 4 && time <= 55) ||
      (time <= 50)
    )
  }

  export let bgColor
  export let btnStyle
</script>

<style>
  p span, p time {
    display: inline-block;
    width: 48%;
    text-align: left;
  }

  p {
    margin: 5px 0;
    text-align: justify;
  }

  p time, p span:last-child {
    text-align: right;
  }

  button {
    box-shadow: inset 0px -6px 10px var(--shadow_color);
    width: 100%;
    position: absolute;
    left: 0;
    bottom: 0;
    border: none;
    height: 40px;
    font-weight: 400;
  }
</style>

<p>
  <span><Leaf style ={{width: '30px'}}/> {trip.trips_count}</span>
  <span><Distance style={{ fill: bgColor, width: '15px', height: '15px'}}/> {distance}KM</span>
</p>
<p>
  <span>
    <Clock style={{ fill: bgColor, width: '15px', height: '15px'}}/>
    {#if trip.pre_order }
      <time>{trip.start_time}</time>
    {:else}
      <select>
        <option value='' selected>{duration + 4}XB</option>
        <option value='2'>2XB</option>
        <option value='5'>5XB</option>
        <option value='10'>10XB</option>
        <option value='15'>15XB</option>
        <option value='20'>20XB</option>
        <option value='30'>30XB</option>
        <option value='45'>45XB</option>
        <option value='60'>60XB</option>
      </select>
    {/if}
  </span>
  <time><Timer style={{width: '15px', height: '15px'}}/>{time}</time>
</p>
<blockquote><b>💬</b> {trip.comment}</blockquote>
<button type='button' disabled={disabledButton || disabled} on:click={accept} style="{btnStyle}">GO</button>
