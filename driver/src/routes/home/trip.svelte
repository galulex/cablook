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
    overflow-y: auto;
    position: relative;
  }

  li > div {
    margin: 0 30px;
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

  .buttons {
    display: flex;
    justify-content: space-between;
  }

  button, .button {
    padding: 10px;
    color: white;
    text-decoration: none;
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
    <div class='buttons'>
      <button type='button' title={actions[trip.status - 1].title} disabled={disabled} on:click={actions[trip.status - 1].action}>🏁</button>
      <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>☎️</a>
      <a class='button' href={`tel:${trip.user_number}`}>🧭</a>
      <button type='button' disabled={disabled} on:click={cancel}>❌</button>
    </div>
  </div>
</li>
