<script>
  import { onMount } from 'svelte'
  import i18n from '../../../pwa/i18n.js'
  // import Star from '../../../pwa/images/star.svg'
  // import Tips from '../../../pwa/images/tips.js'
  // import Amount from '../../../pwa/images/trip_price.js'
  // import Leaf from '../../../pwa/images/leaf_icon.js'

  import '../../css/statistics.css'

  export let getStatistics
  export let statistics

  let Periods = [
    {name: i18n.statistics.periods.today, value: 'today'},
    {name: i18n.statistics.periods.last_two_days, value: 'last_two_days'},
    {name: i18n.statistics.periods.this_week, value: 'last_week'},
    {name: i18n.statistics.periods.this_month, value: 'this_month'},
    {name: i18n.statistics.periods.last_month, value: 'last_month'},
    {name: i18n.statistics.periods.this_year, value: 'this_year'},
    {name: i18n.statistics.periods.all_time, value: 'all'}
  ]
</script>

<section>
  <div class='tab-content__holder'>
    <div class='tab-content__container'>
      <div class='tab-content__header'>{i18n.statistics.period}</div>
      <span class='divider'></span>
      <label for='period' class='select'>
        <select id='period' on:change={ (e) => getStatistics(e.target.value) }>
          {#each Periods as period}
            <option value={period.value} key={period.value}>{period.name}</option>
          {/each}
        </select>
      </label>
    </div>
    <div class='tab-content__container'>
      <div class='tab-content__header'>{i18n.statistics.your_data}</div>
      <div class='tab-content__container-items'>
        <div class='tab-content__container-item statistics__item'>
          <div class='statistics__container'>
            <!-- <Leaf class='statistics-icon'/> -->
            {i18n.statistics.trips_count}
          </div>
          <span class='value'>
            {(statistics.trips_count) || 0}
          </span>
        </div>
        <div class='tab-content__container-item statistics__item'>
          <div class='statistics__container'>
            <!-- <Amount class='statistics-icon'/> -->
            {i18n.statistics.points}
          </div>
          <span class='value'>
            {(statistics.amount) || 0}
            {i18n.statistics.points}
          </span>
        </div>


        <div class='tab-content__container-item statistics__item'>
          <div class='statistics__container'>
            <!-- <Star class='statistics-icon'/> -->
            {i18n.statistics.rate}
          </div>
          <span class='value'>
            {(statistics.rate) || 0}
          </span>
        </div>
        <div class='tab-content__container-item statistics__item'>
          <div class='statistics__container'>
            <!-- <Tips class='statistics-icon'/> -->
            {i18n.statistics.tips}
          </div>
          <span class='value'>
            {(statistics.tips) || 0}
            {i18n.statistics.uah}
          </span>
        </div>
      </div>
    </div>
  </div>
</section>
