<script>
  import axios from 'axios'
  import i18n from '../../../pwa/i18n.js'
  import Star from '../../images/Star.svelte'
  import Tips from '../../images/Tips.svelte'
  import Points from '../../images/Hryvnia.svelte'
  import Timer from '../../images/Timer.svelte'
  import Taxi from '../../images/Taxi.svelte'
  import Card from '../../images/Card.svelte'
  import Leaf from '../../images/Leaf.svelte'
  import Sign_out from '../../images/Sign_out.svelte'
  import TripDetails from '../components/TripDetails.svelte'
  import Payouts from '../components/Payouts.svelte'
  import '../../css/profile.css'

  export let logout

  let showPayoutsModal = false
  let statistics = { 
    trip: { payments_type: 'Payments::Trip' }, 
    tip: { payments_type: 'Payments::Tip' }, 
    idle: { payments_type: 'Payments::Idle' }, 
    fake: { payments_type: 'Payments::FakeTaxi' }
  }
  let driver = {}
  let selectedDate = new Date().toDateString()
  let todayValue = new Date().toISOString().substr(0, 10)
  let trips = []

  let getStatistics = async (period = 'today') => {
    let { data } = await axios.get(`statistics?period=${period}`)
    data.statistics.map((stat) => {
      switch (stat.payments_type) {
        case statistics.trip.payments_type:
          statistics.trip = stat
          break
        case statistics.tip.payments_type:
          statistics.tip = stat
          break
        case statistics.idle.payments_type:
          statistics.idle = stat
          break
        case statistics.fake.payments_type:
          statistics.fake = stat
          break
      }
    })
    driver = data.driver || {}

    return statistics
  }

  let getTripsStats = async (date = selectedDate) => {
    let { data } = await axios.get(`trips_statistics/?date=${date}`)
    trips = data.trips || []
    selectedDate = new Date(date).toDateString()

    return trips
  }

  const updateDriver = (event) => { driver = event.detail }

  getStatistics()
  getTripsStats()
</script>

<section class="driver-profile">
  <div class="tab-content__holder">
    <div class="tab-content__container">
      <div class="tab-content__header">{i18n.statistics.period}</div>
      <span class="divider" />
      <label for="period" class="select">
        <select id="period" on:change={(e) => getStatistics(e.target.value)}>
          {#each Object.keys(i18n.statistics.periods) as period}
            <option value={period} key={period}>
              {i18n.statistics.periods[period]}
            </option>
          {/each}
        </select>
      </label>
    </div>
    <div class="tab-content__container">
      <div class="tab-content__header">{i18n.statistics.your_data}</div>
      <div class="tab-content__container-items">
        {#if statistics.rate}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Star />
            {i18n.statistics.rate}
          </div>
          <span class="value">
            {statistics.rate || 0}
          </span>
        </div>
        {/if}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Leaf />
            {i18n.statistics.trips_count} ({statistics.trip.count || 0})
          </div>
          <span class="value">
            {statistics.trip.amount || 0}
            {i18n.statistics.uah}
          </span>
        </div>
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Tips />
            {i18n.statistics.tips} ({statistics.tip.count || 0})
          </div>
          <span class="value">
            {statistics.tip.amount || 0}
            {i18n.statistics.uah}
          </span>
        </div>
        {#if statistics.fake.count > 0}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Taxi />
            {i18n.statistics.fake_trips} ({statistics.fake.count})
          </div>
          <span class="value">
            {statistics.fake.amount || 0}
            {i18n.statistics.uah}
          </span>
        </div>
        {/if}
        {#if statistics.idle.count > 0}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Timer style={{ fill: '#19a160' }} />
            {i18n.statistics.idle_trips} ({statistics.idle.count})
          </div>
          <span class="value">
            {statistics.idle.amount || 0}
            {i18n.statistics.uah}
          </span>
        </div>
        {/if}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Card />
            {i18n.statistics.card_number}
          </div>
          <span class="value">
            {driver.card_number || i18n.statistics.loading}
          </span>
        </div>
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Points />
            {i18n.statistics.balance}
          </div>
          <span class="value">
            <button
              on:click={() => (showPayoutsModal = true)}
              disabled={parseInt(driver.balance) <= 0}
              >{parseInt(driver.balance)} {i18n.statistics.uah}</button
            >
          </span>
        </div>
      </div>
    </div>
    <div class="tab-content__container">
      <div class="tab-content__header">{i18n.statistics.your_trips}</div>
      <div class="tab-content__container-item">
        <div class="statistics__container">
          <Leaf />
          {trips.length || 0}
        </div>
        <div class="statistics__container-date-select">
          <input
            type="date"
            id="trips-date"
            value={todayValue}
            name="trips"
            on:change={(e) => getTripsStats(e.target.value)}
          />
        </div>
      </div>
      {#if trips.length > 0}
        <div class="tab-content__container-trips">
          {#each trips as trip, index}
            <TripDetails {trip} />
          {/each}
        </div>
      {/if}
    </div>
    {#if showPayoutsModal}
      <Payouts
        on:close={() => (showPayoutsModal = false)}
        on:update={updateDriver}
        driverBalance={driver.balance}
      />
    {/if}
    <div>
      <button class="log-out" type="button" on:click={logout}>
        <Sign_out />
        {i18n.drawer.logout}
      </button>
    </div>
  </div>
</section>
