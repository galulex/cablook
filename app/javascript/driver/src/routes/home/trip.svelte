<script>
  import { onMount, onDestroy } from 'svelte'
  import axios from 'axios'
  import Leaf from '../../../images/Leaf_black.svelte'
  import Timer from '../../../images/Timer.svelte'
  import Clock from '../../../images/Clock.svelte'
  import Distance from '../../../images/Distance.svelte'
  import Pin from '../../../images/Pin.svelte'
  import Phone from '../../../images/Phone.svelte'
  import PhoneCrossed from '../../../images/Phone_crossed.svelte'
  import Plane from '../../../images/Plane.svelte'
  import Clapper from '../../../images/Clapper.svelte'
  import Flag from '../../../images/Flag.svelte'
  import CrossX from '../../../images/Cross_X.svelte'
  import Back from '../../../images/Back.svelte'
  import Hryvnia from '../../../images/Hryvnia.svelte'
  import Exclamation from '../../../images/Exclamation.svelte'
  import Check from '../../../images/Check.svelte'
  import Pencil from '../../../images/Pencil.svelte'
  import Modal from '../../Modal.svelte'

  export let trip
  export let updateTrip
  export let cable

  const TRIP_STATUS_WAITING_CLIENT = 2
  const TRIP_STATUS_DRIVING = 3

  let showModal = false
  let distance = (trip.distance/1000).toFixed(1)
  let disabled = false
  let paymentVerifyDisabled = trip.status < TRIP_STATUS_DRIVING
  let item
  let subscription
  let timer = parseInt(localStorage[`timer_${trip.id}`]) || 0
  let interval
  let paymentCheck = false
  let paymentIcon = trip.payment_status == 2 ? Check : Hryvnia
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
    const fakeTaxi = trip.status >= TRIP_STATUS_WAITING_CLIENT
    const message = 'Відміняти поїздки не бажано.\nМожна перекинути іншому водієві.\nТочно відмінити?'
    const fakeTaxiMessage = '❗️З клієнта буде знята оплата за подачу авто.\nТочно відмінити?'
    const params = fakeTaxi? { fake: true } : {}

    if (!confirm(fakeTaxi ? fakeTaxiMessage : message)) return
    disabled = true
    axios.patch(`trips/${trip.id}/cancel`, params).then(res => {
      update(res)
      clearInterval(interval)
      localStorage.removeItem(`timer_${trip.id}`)
    })
  }

  let paymentVerify = () => {
    if (trip.vip) return alert('Це постійний клієнт. Кошти знімуться по закінченні поїздки')
    paymentIcon = Hryvnia
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

  let isAbleToStart = () => {
    const minutesToPreorder = Math.round((new Date(trip.start_at).getTime() - new Date().getTime()) / 1000 / 60)
    return trip.pre_order ? (minutesToPreorder < 20) : true
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
        if (!isAbleToStart()) return alert('Заплановані замовлення можна почати тільки за 20 хвилин до часу початку')
        disabled = true
        axios.patch(`trips/${trip.id}/waiting_client`).then(update)
      },
      title: 'Arrived',
      icon: Plane
    },
    {
      action: () => {
        disabled = true
        paymentVerifyDisabled = false
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
    font-size: 1.3rem;
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

  span {
    display: contents;
    display: inline-block;
  }

  span:last-child {
    text-align: right;
  }

  span:first-child {
    text-align: left;
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

  .info {
    margin-left: 5px;
    margin-right: 5px;
    margin-top: 5px;
    text-align: left;
    display: flex;
    justify-content: space-between;
    flex-flow: row wrap;
  }

  .info-line {
    display: contents;
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
    <div class='info'>
      <div class='info-line'>
        <span><Leaf style={{width: '30px'}}/><label>{trip.trips_count}</label></span>
        <span datatime={trip.start_at}><Clock style={{ fill: bgColor(), width: '20px', height: '20px'}}/><label>{trip.start_time}</label></span>
      </div>
      <div class='info-line'>
        <span><Distance style={{ fill: bgColor(), width: '20px', height: '20px'}}/><label>{distance}км</label></span>
        <span><Hryvnia style={{width: '20px', height: '20px', fill: 'green'}}/><label>{trip.cost}</label></span>
      </div>
    </div>
    <blockquote>{trip.comment}</blockquote>
    <div class='buttons'>
      <button type='button'
              title={actions[trip.status - 1].title}
              disabled={disabled}
              on:click={actions[trip.status - 1].action}
              style="background: #89d5d4;">
        <svelte:component this={actions[trip.status - 1].icon} style={{fill: 'var(--white)', width: '25px', height: '25px' }}/>
      </button>
      <button on:click="{() => showModal = true}"><Pencil style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/></button>
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
      <button type='button' on:click={cancel}><CrossX style={{fill: 'var(--red_color)', width: '20px', height: '25px'}}/></button>
    </div>
    <div class='buttons'>
      <button type='button' disabled={disabled} on:click={count}><Timer style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/><label>{timer}</label></button>
      <button type='button' disabled={trip.payment_status == 2 || paymentCheck || paymentVerifyDisabled} on:click={paymentVerify} class={paymentClass}><svelte:component this={paymentIcon} style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px' }}/></button>
      <button type='button' on:click={unrelease} disabled={disabled}><Back style={{fill: 'var(--main_dark_color)', width: '25px', height: '25px'}}/></button>
    </div>
  </div>

  {#if showModal}
    <Modal on:close="{() => showModal = false}" trip={trip} subscribe={subscribe()}></Modal>
  {/if}
</li>
