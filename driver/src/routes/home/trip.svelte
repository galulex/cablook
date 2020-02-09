<script>
  import axios from 'axios'
  import Map from './map.svelte'

  export let trip
  export let updateTrip

  let duration = (trip.duration/60).toFixed(1)
  let distance = (trip.distance/1000).toFixed(1)
  let disabled = false

  let cancel = () => {
    if (!confirm('Are you sure?')) return
    axios.patch(`trips/${trip.id}/cancel`).then(res => {
      updateTrip(res.data)
    })
  }

  const actions = [
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/waiting_client`).then(res => {
          updateTrip(res.data)
          disabled = false
        })
      },
      title: 'Arrived'
    },
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/start`).then(res => {
          updateTrip(res.data)
          disabled = false
        })
      },
      title: 'Start'
    },
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/finish`, {idle: 0}).then(res => {
          updateTrip(res.data)
          disabled = false
        })
      },
      title: 'Finish'
    }
  ]

</script>

<style>
  li {
    scroll-snap-align: start;
    height: inherit;
    margin: 0;
  }

  div {
    padding: 0 20px;
  }

  p {
    text-align: justify;
  }

  p time, p span {
    width: 48%;
    display: inline-block;
  }

  p time {
    text-align: right;
  }

  button, .button {
    width: 100%;
  }
</style>

<li>
  <Map trip={trip}/>
  <div>
    {#each trip.stops as stop, i}
      <address>📍 {stop}</address>
    {/each}
    <p>
      <span>{distance} KM</span>
      <time datatime={trip.start_at}>⏰ {trip.start_time}</time>
    </p>
    <blockquote>{trip.comment}</blockquote>
    <button type='button' disabled={disabled} on:click={actions[trip.status - 1].action}>{actions[trip.status - 1].title}</button>
    <br/>
    <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>✆</a>
    <br/>
    <a class='button' href={`tel:${trip.user_number}`}>NAVIGATOR</a>
    <br/>
    <button type='button' disabled={disabled} on:click={cancel}>Cancel</button>
  </div>
</li>
