<script>
  import axios from 'axios'
  import i18n from '../../../pwa/i18n.js'
  import Points from '../../images/Hryvnia.svelte'
  import Card from '../../images/Card.svelte'
  import Star from '../../images/Star.svelte'
  import Leaf from '../../images/Leaf.svelte'
  import Cash from '../../images/Cash.svelte'
  import Sign_out from '../../images/Sign_out.svelte'
  import TripDetails from '../components/profile/TripDetails.svelte'
  import Payouts from '../components/profile/Payouts.svelte'
  import Statistics from '../components/profile/Statistics.svelte'
  import '../../css/profile.css'

  export let logout

  let showPayoutsModal = false

  let driver = {}
  let selectedDate = new Date().toDateString()
  let todayValue = new Date().toISOString().substr(0, 10)
  let trips = []
  let statsistics = {}
  let rate = 0

  let getStatistics = async (period = 'today') => {
    let { data } = await axios.get(`statistics?period=${period}`)
    statsistics = data.statistics
    driver = data.driver
    rate = data.rate

    return statsistics
  }

  let getTripsStats = async (date = selectedDate) => {
    let { data } = await axios.get(`trips_statistics/?date=${date}`)
    trips = data.trips || []
    selectedDate = new Date(date).toDateString()

    return trips
  }

  const updateDriver = (event) => {
    driver = event.detail
  }

  const cashAmount = (stats) => stats.reduce((sum, stat) => sum + Number(stat.cash_amount), 0)

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
        {#if rate}
          <div class="tab-content__container-item">
            <div class="statistics__container">
              <Star />
              {i18n.statistics.rate}
            </div>
            <span class="value">
              {rate || 0}
            </span>
          </div>
        {/if}
        <Statistics data={statsistics} />
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Card />
            {i18n.statistics.card_number}
          </div>
          <span class="value">
            {driver.card_number || i18n.statistics.loading}
          </span>
        </div>
        {#if statsistics.length > 0} 
          <div class="tab-content__container-item">
            <div class="statistics__container">
              <Cash />
              {i18n.trip.cash}
            </div>
            <span class="value">
              {cashAmount(statsistics) || 0}
              {i18n.statistics.uah}
            </span>
          </div>
        {/if}
        <div class="tab-content__container-item">
          <div class="statistics__container">
            <Points />
            {i18n.statistics.balance}
          </div>
          <span class="value">
            <button on:click={() => (showPayoutsModal = true)} disabled={Number(driver.balance) <= 0}>
                {Number(driver.balance) || 0} {i18n.statistics.uah}
            </button>
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
