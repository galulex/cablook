<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'
  import Unrelease from './unrelease.svelte'

  export let trip
  export let updateTrip
  export let cable

  let duration = (trip.duration/60).toFixed(1)
  let distance = (trip.distance/1000).toFixed(1)
  let disabled = false
  let item
  let subscription
  let timer = parseInt(localStorage[`timer_${trip.id}`]) || 0
  let interval
  let paymentCheck = false
  let paymentIcon = trip.payment_status == 2 ? '✅' : ''

  onMount(() => {
    item.scrollIntoView()
    subscribe()
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let count = () => {
    if (interval) {
      clearInterval(interval)
      interval = null
      return
    }
    if (!confirm('Запустити таймер?')) return
    interval = setInterval(() => {
      timer += 1
      localStorage[`timer_${trip.id}`] = timer
    }, 1000)
  }

  let update = (res) => {
    updateTrip(res.data)
    disabled = false
    window.play('update')
  }

  let cancel = () => {
    if (!confirm('Відміняти поїздки не бажано. Можна перекинути іншому водієві. Точно відмінити?')) return
    disabled = true
    axios.patch(`trips/${trip.id}/cancel`).then(res => {
      update(res)
      clearInterval(interval)
      localStorage.removeItem(`timer_${trip.id}`)
    })
  }

  let paymentVerify = () => {
    paymentIcon = ''
    paymentCheck = true
    axios.patch(`trips/${trip.id}/payments_verify`).then(res => {
      if (res.data.payment_status == 2) {
        paymentIcon = '✅'
      } else {
        paymentVerifyError('Не вдалося здійснити оплату')
      }
    }).catch(error => {
      paymentVerifyError(error.message)
    })
  }

  const paymentVerifyError = (message) => {
    paymentCheck = false
    paymentIcon = '❌'
    alert(message)
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
        axios.patch(`trips/${trip.id}/finish`, {idle: timer}).then(res => {
          update(res)
          clearInterval(interval)
          localStorage.removeItem(`timer_${trip.id}`)
        })
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
    padding: 40px 0 60px 0;
    box-shadow: inset 0px 0px 20px 0px #312d50;
  }

  li:nth-child(even) {
    box-shadow: inset 0px 0px 20px 0px #19a160;
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
  <div>
    {#each trip.stops as stop, i}
      <address><b>📍</b> {stop}</address>
    {/each}
    <p>
      <span><b>🚕</b> {trip.trips_count}</span>
      <span><b>🚖</b> {distance}KM</span>
      <time datatime={trip.start_at}><b>⏰</b> {trip.start_time}</time>
    </p>
    <blockquote><b>💬</b> {trip.comment}</blockquote>
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
      <a class='button'
         target='_blank'
         href={`https://www.google.com/maps/dir/?api=1&waypoints=${trip.waypoints.join('|')}&destination=${trip.waypoints[trip.waypoints.length - 1]}&travelmode=driving&dir_action=navigate`} >
         <i>🌐</i>
      </a>
      <button type='button' disabled={disabled} on:click={cancel}><i>❌</i></button>
    </div>
    <br/>
    <div class='buttons'>
      <button type='button' disabled={disabled} on:click={count}><i>⏰</i> {timer}</button>
      <button type='button' disabled={trip.payment_status == 2 || paymentCheck} on:click={paymentVerify}>💵{paymentIcon}</button>
      <Unrelease trip={trip} updateTrip={updateTrip} />
    </div>
  </div>
</li>
