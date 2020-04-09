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
  span, time {
    padding-left: 5px;
    display: inline-block;
    width: 49%;
    text-align: left;
  }

  .car {
    padding: 0;
  }

  p {
    margin: 10px 0;
    text-align: justify;
  }

  time:last-child , span:last-child {
    width: 48%;
    text-align: right;
  }

  time:last-child label, span:last-child label {
    display: inline-block;
    text-align: left;
    width: 40px;
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

  label {
    padding: 0 0 0 5px;
  }
</style>

<p>
  <span class='car'><Leaf style ={{width: '25px'}}/><label>{trip.trips_count}</label></span>
  <span><Distance style={{ fill: bgColor, width: '15px', height: '15px'}}/><label>{distance}км</label></span>
</p>
<p>
  <time>
    <Clock style={{ fill: bgColor, width: '15px', height: '15px'}}/>
    {#if trip.pre_order }
      <label>{trip.start_time}</label>
    {:else}
      <label>{duration}хв</label>
    {/if}
  </time>
  <time><Timer style={{fill: 'var(--red_color)', width: '15px', height: '15px'}}/><label>{time}</label></time>
</p>
<blockquote>{trip.comment}</blockquote>
<button type='button' disabled={disabledButton || disabled} on:click={accept} style="{btnStyle}">GO</button>
