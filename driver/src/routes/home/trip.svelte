<script>
  import axios from 'axios'
  import Map from './map.svelte'

  export let trip
  export let updateTrip

  let duration = (trip.duration/60).toFixed(1)
  let distance = (trip.distance/1000).toFixed(1)

  let cancel = () => {
    /* if (!confirm('Are you sure?')) return */
    axios.patch(`trips/${trip.id}/cancel`)
  }

  const actions = [
    {
      action: () => {
        axios.patch(`trips/${trip.id}/waiting_client`).then(res => {
          updateTrip(res.data)
        })
      },
      title: 'Arrived'
    },
    {
      action: () => {
        axios.patch(`trips/${trip.id}/start`).then(res => {
          updateTrip(res.data)
        })
      },
      title: 'Start'
    },
    {
      action: () => {
        axios.patch(`trips/${trip.id}/finish`, {idle: 0}).then(res => {
          updateTrip(res.data)
        })
      },
      title: 'Finish'
    }
  ]

  const button = actions[trip.status - 1]
</script>

<style>
  li {
    scroll-snap-align: start;
    height: inherit;
  }
</style>

<li>
  <Map trip={trip}/>
  <div>
    {#each trip.stops as stop, i}
      <address>{stop}</address>
    {/each}
    <time datatime={trip.start_at}>⏰ {trip.start_time}</time>
    <br/>
    <span>{distance} KM</span>
    <blockquote>{trip.comment}</blockquote>
    <button type='button' on:click={button.action}>{button.title}</button>
    <br/>
    <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>✆</a>
    <br/>
    <a class='button' href={`tel:${trip.user_number}`}>NAVIGATOR</a>
    <br/>
    <button type='button' on:click={cancel}>Cancel</button>
  </div>
</li>
