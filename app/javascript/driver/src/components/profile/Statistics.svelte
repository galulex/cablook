<script>
  import i18n from '../../../../pwa/i18n.js'
  import Timer from '../../../images/Timer.svelte'
  import Taxi from '../../../images/Taxi.svelte'
  import Leaf from '../../../images/Leaf.svelte'
  import Tips from '../../../images/Tips.svelte'

  export let data = [];

  const icons = {
    faketaxi: Taxi,
    idle: Timer,
    tip: Tips,
    trip: Leaf
  }

  const type = (paymenType) => paymenType.split('::')[1].toLowerCase()
</script>

<div>
  {#each data as statistic}
    <div class="tab-content__container-item">
      <div class="statistics__container">
        <svelte:component this={icons[type(statistic.payments_type)]} style={{ fill: '#19a160' }}/>
        {i18n.statistics.types[type(statistic.payments_type)]}
        ({statistic.count || 0})
      </div>
      <span class="value">
        {statistic.amount || 0}
        {i18n.statistics.uah}
      </span>
    </div>
  {/each}
</div>
