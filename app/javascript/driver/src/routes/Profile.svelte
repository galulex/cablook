<script>
  import { onMount } from 'svelte'
  import i18n from '../../../pwa/i18n.js'
  import Star from '../../images/Star.svelte'
  import Tips from '../../images/Tips.svelte'
  import Points from '../../images/Trip_price.svelte'
  import Leaf from '../../images/Leaf.svelte'
  import Sign_out from '../../images/Sign_out.svelte'

  import '../../css/profile.css'

  export let getStatistics
  export let statistics
  export let logout

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
  </div>
  <div>
    <button class='log-out' type='button' on:click={logout}>
      <Sign_out/>
      {i18n.drawer.logout}
    </button>
  </div>
</section>
