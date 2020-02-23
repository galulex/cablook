<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'
  import sounds from '../../sounds'

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
      sounds.accept.play()
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
</script>

<style>
  p span, p time {
    display: inline-block;
    width: 32%;
    text-align: center;
  }

  p {
    text-align: justify;
  }

  p time {
    text-align: right;
  }

  button {
    width: 100%;
    position: absolute;
    left: 0;
    bottom: 0;
    border: none;
    height: 40px;
    color: white;
  }
</style>

<p>
  <span>
    <i>⏰</i>
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
  <span><i>🚖</i>{distance}KM</span>
  <time><i>⏰</i>{time}</time>
</p>
<blockquote><i>💬</i> {trip.comment}</blockquote>
<button type='button' disabled={disabledButton || disabled} on:click={accept}><i>✔️</i> GO</button>
