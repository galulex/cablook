<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'

  import Leaf from '../../../images/Leaf_black.svelte'
  import Timer from '../../../images/Timer.svelte'
  import Clock from '../../../images/Clock.svelte'
  import Distance from '../../../images/Distance.svelte'
  import Pin from '../../../images/Pin.svelte'
  import Location from '../../../images/Location_view.svelte'
  import Phone from '../../../images/Phone.svelte'
  import PhoneCrossed from '../../../images/Phone_crossed.svelte'
  import Plane from '../../../images/Plane.svelte'
  import Clapper from '../../../images/Clapper.svelte'
  import Flag from '../../../images/Flag.svelte'
  import CrossX from '../../../images/Cross_X.svelte'
  import Back from '../../../images/Back.svelte'
  import Dollar from '../../../images/Dollar.svelte'
  import Exclamation from '../../../images/Exclamation.svelte'
  import Check from '../../../images/Check.svelte'

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
  let paymentIcon = trip.payment_status == 2 ? Check : Dollar
  let paymentClass = trip.payment_status == 2 ? 'success' : ''

  onMount(() => {
    item.scrollIntoView()
    subscribe()
  })

  onDestroy(() => {
    if (subscription) subscription.unsubscribe()
  })

  let unrelease = () => {
    if (!confirm('Викинути замовлення в ефір?')) return
    disabled = true
    axios.patch(`trips/${trip.id}/unrelease`).then(res => {
      updateTrip(res.data)
    }).catch((error) => {
      disabled = false
      if (error.response) alert(error.response.data.errors)
    })
  }

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
    paymentIcon = Dollar
    paymentCheck = true
    axios.patch(`trips/${trip.id}/payments_verify`).then(res => {
      if (res.data.payment_status == 2) {
        paymentIcon = Check
        paymentClass = 'success'
      } else {
        paymentVerifyError('Не вдалося здійснити оплату')
      }
    }).catch(error => {
      paymentVerifyError(error.message)
    })
  }

  const paymentVerifyError = (message) => {
    paymentCheck = false
    paymentIcon = Exclamation
    paymentClass = 'failed'
    alert(message)
  }

  const actions = [
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/waiting_client`).then(update)
      },
      title: 'Arrived',
      icon: Plane
    },
    {
      action: () => {
        disabled = true
        axios.patch(`trips/${trip.id}/start`).then(update)
      },
      title: 'Start',
      icon: Clapper
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
      icon: Flag
    }
  ]

  let subscribe = () => {
    if (subscription) return subscription
    subscription = cable.subscriptions.create({ channel: 'TripChannel', trip_id: trip.id }, {
      received: data => { if (['TripUpdated', 'NotifyDriver'].includes(data.action)) cableActions[data.action](JSON.parse(data.data)) }
    })
  }

  let cableActions = {
    TripUpdated: (attrs) => {
      updateTrip(attrs)
      item.scrollIntoView()
      window.play('update')
    },

    NotifyDriver: (data) => {
      alert(`${data.phone_number}: ${data.message}`)
    }
  }

  let bgColor = () => {
    if (trip.vip) return 'var(--red_color)'
    if (trip.pre_order) return 'var(--blue_color)'

    return 'var(--yellow_color)'
  }
</script>

<style>
  li {
    scroll-snap-align: start;
    height: inherit;
    overflow-y: auto;
    position: relative;
    padding: 60px 20px 60px 20px;
    color: var(--text_grey_color);
  }

  li > div {
    margin: 0 30px;
  }

  p {
    text-align: justify;
  }

  time, span {
    width: 32%;
    display: inline-block;
  }

  time {
    text-align: center;
  }

  span:last-child {
    text-align: right;
  }

  .buttons {
    display: flex;
    justify-content: space-between;
    margin: 0 0 25px 0;
  }

  button, .button {
    padding: 15px 15px;
    height: 55px;
    background: var(--bg_gradient_color_1);
    text-decoration: none;
    width: 31%;
    text-align: center;
    border: none;
    border-radius: 5px;
    box-shadow: 3px 3px 6px var(--shadow_color), inset -1px -1px 2px var(--shadow_color);
  }

  button:hover, .button:hover {
    box-shadow: 2px 2px 2px var(--shadow_color), -1px 0px 2px var(--white);
  }

  button:active, .button:active {
    box-shadow: inset 1px 1px 2px var(--shadow_color), inset -1px -1px 2px var(--white);
    -webkit-tap-highlight-color: transparent;
  }

  .buttons label {
    font-weight: 400;
    color: var(--main_dark_color);
    font-size: 25px;
  }

  address {
    font-style: normal;
    margin-bottom: 10px;
  }

  address label {
    padding-left: 10px;
  }

  label {
    padding: 0 0 0 5px;
  }

  blockquote {
    margin-bottom: 60px;
  }

  .success {
    background: green;
  }

  .failed {
    background: var(--red_color);
  }
</style>

<li bind:this={item}>
  <div>
    {#each trip.stops as stop, i}
      {#if i == 0}
        <address><Pin style={{fill: bgColor(), width: '15px', height: '15px' }}/><label>{stop}</label></address>
      {:else}
        <address><Pin style={{fill: 'var(--main_dark_color)', width: '15px', height: '15px' }}/><label>{stop}</label></address>
      {/if}
    {/each}
    <p>
      <span><Leaf style ={{width: '30px'}}/><label>{trip.trips_count}</label></span>
      <time datatime={trip.start_at}><Clock style={{ fill: bgColor(), width: '15px', height: '15px'}}/><label>{trip.start_time}</label></time>
      <span><Distance style={{ fill: bgColor(), width: '15px', height: '15px'}}/><label>{distance}км</label></span>
    </p>
    <blockquote>{trip.comment}</blockquote>
    <div class='buttons'>
      <button type='button'
              title={actions[trip.status - 1].title}
              disabled={disabled}
              on:click={actions[trip.status - 1].action}
              style="background: #89d5d4;">
        <svelte:component this={actions[trip.status - 1].icon} style={{fill: 'var(--white)', width: '25px', height: '25px' }}/>
      </button>
    </div>
    <div class='buttons'>
      <a class='button' href={`tel:${trip.user_number}`}>
        {#if trip.no_call}
          <PhoneCrossed style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/>
        {:else}
          <Phone style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/>
        {/if}
      </a>
      <a class='button'
         target='_blank'
         href={`https://www.google.com/maps/dir/?api=1&waypoints=${trip.waypoints.join('|')}&destination=${trip.waypoints[trip.waypoints.length - 1]}&travelmode=driving&dir_action=navigate`} >
        <Pin style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px' }}/>
      </a>
      <button type='button' disabled={disabled} on:click={cancel}><CrossX style={{fill: 'var(--red_color)', width: '20px', height: '25px'}}/></button>
    </div>
    <div class='buttons'>
      <button type='button' disabled={disabled} on:click={count}><Timer style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/><label>{timer}</label></button>
      <button type='button' disabled={trip.payment_status == 2 || paymentCheck} on:click={paymentVerify} class={paymentClass}><svelte:component this={paymentIcon} style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px' }}/></button>
      <button type='button' on:click={unrelease} disabled={disabled}><Back style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/></button>
    </div>
  </div>
</li>
