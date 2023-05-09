<script>
  import axios from 'axios'

  import i18n from '../../../pwa/i18n.js'
  import Star from '../../images/Star.svelte'
  import Tips from '../../images/Tips.svelte'
  import Points from '../../images/Trip_price.svelte'
  import Leaf from '../../images/Leaf.svelte'
  import Sign_out from '../../images/Sign_out.svelte'
  import TripDetails from "../components/TripDetails.svelte";

  import '../../css/profile.css'

  export let logout

  let statistics = {}

  let getStatistics = (async (period = 'today') => {
    let res = await axios.get(`statistics?period=${period}`)
    statistics = res.data.statistics || {}
    return statistics
  })

  let todayDate = new Date().toDateString()
  let selectedDate = todayDate
  let todayValue = new Date().toISOString().substr(0, 10)

  let trips = []

  let getTripsStats = (async (date = todayDate) => {
    let res = await axios.get(`trips_statistics/?date=${date}`)
    trips = res.data.trips || []
    selectedDate = new Date(date).toDateString()

    return trips
  })

  getTripsStats()

</script>

<section class='driver-profile'>
  <div class='tab-content__holder'>
    <div class='tab-content__container'>
      <div class='tab-content__header'>{i18n.statistics.period}</div>
      <span class='divider'></span>
      <label for='period' class='select'>
        <select id='period' on:change={ (e) => getStatistics(e.target.value) }>
          {#each Object.keys(i18n.statistics.periods) as period}
            <option value={period} key={period}>{i18n.statistics.periods[period]}</option>
          {/each}
        </select>
      </label>
    </div>
    <div class='tab-content__container'>
      <div class='tab-content__header'>{i18n.statistics.your_data}</div>
      <div class='tab-content__container-items'>
        <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Leaf/>
            {i18n.statistics.trips_count}
          </div>
          <span class='value'>
            {(statistics.trips_count) || 0}
          </span>
        </div>
        <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Points/>
            {i18n.statistics.points_2}
          </div>
          <span class='value'>
            {(statistics.amount) || 0}
            {i18n.statistics.points_1}
          </span>
        </div>
        <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Star/>
            {i18n.statistics.rate}
          </div>
          <span class='value'>
            {(statistics.rate) || 0}
          </span>
        </div>
        <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Tips/>
            {i18n.statistics.tips}
          </div>
          <span class='value'>
            {(statistics.tips) || 0}
            {i18n.statistics.uah}
          </span>
        </div>
        <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Tips/>
            {i18n.statistics.tips_count}
          </div>
          <span class='value'>
            {(statistics.tips_count) || 0}
          </span>
        </div>
      </div>
    </div>
    <div class='tab-content__container'>
      <div class='tab-content__header'>{i18n.statistics.your_trips}</div>
      <div class='tab-content__container-item'>
          <div class='statistics__container'>
            <Leaf/> {trips.length || 0}
          </div>
          <div class='statistics__container-date-select'>
            <input type="date" id="trips-date" value={todayValue} name="trips" on:change={ (e) => getTripsStats(e.target.value)}>
          </div>
        </div>

        {#if trips.length > 0}
          <div class='tab-content__container-trips'>
            {#each trips as trip, index}
              <TripDetails trip={trip}/>
            {/each}
          </div>
        {/if}
    </div>

  <div>
    <button class='log-out' type='button' on:click={logout}>
      <Sign_out/>
      {i18n.drawer.logout}
    </button>
  </div>
</section>
