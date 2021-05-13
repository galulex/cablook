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
  export let isBusy
  let interval

  let createTime = new Date(trip.created_at).getTime()
  let current
  let time = 0
  let name = 'disabled'
  let disabledButton = false
  let tripDuration = ''
  let timeDurationRange = [duration, 5, 10, 15, 20, 25]

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
    if (!isDisabled()) name = ''
    if (time < 0) {
      name = ''
      clearInterval(interval)
      time = 0
    }
  }

  let accept = () => {
    if (isDisabled()) {
      alert('Ах ти хрущ. Навіщо клацаєш?')
      return
    }
    disabledButton = true
    axios.patch(`trips/${trip.id}/accept`, {tripDuration}).then(res => {
      updateTrip(res.data)
      window.play('accept')
    }).catch((error) => {
      disabledButton = false
      if (error.response) alert(error.response.data.errors)
    })
  }

  let isDisabled = () => {
    return !(
      (distance <= 2 && !isBusy) ||
      (distance > 2 && distance <= 4 && time <= 60 && !isBusy) ||
      (distance > 4 && time <= 55 && !isBusy) ||
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
    box-shadow: 2px 2px 8px var(--shadow_color), inset 0px -1px 6px var(--shadow_color);
    width: 100%;
    position: absolute;
    left: 0;
    bottom: 0;
    border: none;
    height: 40px;
    font-weight: 400;
  }

  button:hover {
    box-shadow: 2px 1px 4px var(--shadow_color);
  }

  button:active {
    box-shadow: inset 2px 2px 4px var(--shadow_color);
  }

  label {
    padding: 0 0 0 5px;
  }

  button[name='disabled'] {
    opacity: 0.5;
  }

  select {
    width: 30%;
    text-align-last: center;
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
      <select on:change="{e => tripDuration = e.target.value}">
        {#each timeDurationRange as timeDuration}
          <option value={timeDuration}>{timeDuration}</option>
        {/each}
      </select>
    {/if}
  </time>
  <time><Timer style={{fill: 'var(--red_color)', width: '15px', height: '15px'}}/><label>{time}</label></time>
</p>
<blockquote>{trip.comment}</blockquote>
<button type='button' name={name}  disabled={disabledButton} on:click={accept} style="{btnStyle}">GO {time}</button>
