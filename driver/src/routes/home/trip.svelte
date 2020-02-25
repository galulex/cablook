<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'
  import Map from './map.svelte'

  export let trip
  export let updateTrip
  export let cable

  let duration = (trip.duration/60).toFixed(1)
  let distance = (trip.distance/1000).toFixed(1)
  let disabled = false
  let item
  let subscription

  onMount(() => {
    item.scrollIntoView()
    subscribe()
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let update = (res) => {
    updateTrip(res.data)
    disabled = false
    window.play('update')
  }

  let cancel = () => {
    if (!confirm('Are you sure?')) return
    disabled = true
    axios.patch(`trips/${trip.id}/cancel`).then(update)
  }

  const actions = [
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/waiting_client`).then(update)
      },
      title: 'Arrived',
      icon: '🛬'
    },
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/start`).then(update)
      },
      title: 'Start',
      icon: '🎬'
    },
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/finish`, {idle: 0}).then(update)
      },
      title: 'Finish',
      icon: '🏁'
    }
  ]

  let klass = () => {
    if (trip.vip) return 'vip'
    if (trip.pre_order) return 'preorder'
  }

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'TripChannel', trip_id: trip.id }, {
      received: data => { if (data.action === 'TripUpdated') TripUpdated(JSON.parse(data.data)) }
    })
  }

  let TripUpdated = (attrs) => {
    updateTrip(attrs)
    item.scrollIntoView()
    window.play('update')
  }
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
    width: 32%;
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
    width: 20%;
    text-align: center;
    border: none;
  }

  .arrived {
    background: aqua;
  }

  .start {
    background: orange;
  }

  .preorder {
    background: #06a092;
  }

  .vip {
    background: #ff8484;
  }
</style>

<li bind:this={item} class={klass()}>
  <Map trip={trip}/>
  <div>
    {#each trip.stops as stop, i}
      <address><i>📍</i> {stop}</address>
    {/each}
    <p>
      <span><i>🚕</i> {trip.trips_count}</span>
      <span><i>🚖</i> {distance} KM</span>
      <time datatime={trip.start_at}><i>⏰</i> {trip.start_time}</time>
    </p>
    <blockquote><i>💬</i> {trip.comment}</blockquote>
    <div class='buttons'>
      <button type='button'
              title={actions[trip.status - 1].title}
              disabled={disabled}
              class={actions[trip.status - 1].title.toLowerCase()}
              on:click={actions[trip.status - 1].action}>
        <i>{actions[trip.status - 1].icon}</i>
      </button>
      <a class='button' href={`tel:${trip.user_number}`}>
        {#if trip.no_call}
          <i>📵</i>
        {:else}
          <i>📱</i>
        {/if}
      </a>
      <a class='button'>🧭</a>
      <button type='button' disabled={disabled} on:click={cancel}>❌</button>
    </div>
  </div>
</li>
