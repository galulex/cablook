<script>

  import Clock from '../../images/Clock.svelte'
  import Distance from '../../images/Distance.svelte'
  import Dollar from '../../images/Dollar.svelte'
  import Pin from '../../images/Pin.svelte'

  export let trip

  let formatDistance = (distance) => (distance/1000).toFixed(1)

</script>

<style>

  .container {
    width: 100%;
    padding: 2% 2%;
    margin: 2% 0;
    background: linear-gradient(to right, var(--bg_gradient_color_2), var(--bg_gradient_color_1), var(--bg_gradient_color_2));
    border-radius: 15px;
    box-shadow: 0px 0px 5px var(--shadow_color);
    color: #233038;
    color: var(--font_color_2);
  }

  .info {
    margin-top: 20px;
    text-align: left;
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
  }

  .distance {
    flex-grow: 1;
  }

  .cost {
    flex-grow: 1;
    text-align: end;
  }

  .vip {
    position: absolute;
    right: 20px;
    top: 25px;
    font-weight: 400;
    color: var(--red_color);
  }

  .address {
    display: flex;
    font-style: normal;
    margin-bottom: 10px;
  }

  .address label {
    width: 95%;
    display: inline-flex;
  }

</style>

<div class='container'>

  {#each trip.stops as stop, i}
    {#if i == 0}
      <div class='address'><Pin style={{fill: 'var(--main_green_color)', width: '15px', height: '15px' }}/><label>{stop}</label></div>
    {:else}
      <div class='address'><Pin style={{fill: 'var(--main_dark_color)', width: '15px', height: '15px' }}/><label>{stop}</label></div>
    {/if}
  {/each}

  <div class='info'>
    <div class='distance'><Distance style={{fill: 'var(--yellow_color)', width: '15px', height: '15px'}}/><label>{formatDistance(trip.distance)}км</label></div>
    <div><Clock style={{fill: 'var(--yellow_color)', width: '15px', height: '15px'}}/><label>{trip.start_time}-{trip.finish_time}</label></div>
    <div class='cost'><Dollar style={{fill: 'var(--main_green_color)', width: '15px', height: '15px'}}/><label>{trip.cost}грн</label></div>
  </div>
</div>
