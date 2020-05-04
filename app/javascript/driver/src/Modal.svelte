<script>
  import axios from 'axios';
  import { createEventDispatcher } from 'svelte';

  import Save from '../images/save_changes.svelte'

  import AddressInput from './trips/address-input.svelte'

  const dispatch = createEventDispatcher();
  const close = () => {
    updateTrip()
    trip.stops = trip.stops.filter(String)
    dispatch('close');
  }

  let modal;
  export let trip;

  let update = (e) => {
    e.preventDefault()
    axios.patch(`trips/${trip.id}/update`, { trip: trip }).then((res) => {
      close()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  let setAddress = (text, coords, index) => {
    trip.waypoints[index] = coords;
    trip.stops[index] = text;

    updateTrip()
  }

  let eraseAddress = (index) => {
    if (trip.stops[index] === '') return removeAddress(index)
    trip.stops[index] = '';
    trip.waypoints[index] = '';

    updateTrip()
  }

  let removeAddress = (index) => {
    trip.stops.splice(index, 1);
    trip.waypoints.splice(index, 1);

    updateTrip()
  }

  let addAddress = () => {
    trip.stops.push('')
    updateTrip()

    setTimeout(() => { document.querySelector('fieldset:last-of-type input').focus() }, 100)
  }

  let updateTrip = () => {
    trip.departure = trip.waypoints[0]
    trip.destination = trip.waypoints[trip.waypoints.length - 1]
    trip.departure_address = trip.stops[0]
    trip.destination_address = trip.stops[trip.stops.length - 1]
    return trip
  }
</script>

<style>
  .modal-background {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.3);
  }

  .modal {
    position: absolute;
    left: 50%;
    top: 50%;
    width: calc(100vw - 2em);
    max-width: 32em;
    max-height: calc(100vh - 4em);
    transform: translate(-50%,-50%);
    padding: 2.5em;
    border-radius: 10px;
    background: linear-gradient(to right, var(--bg_gradient_color_2), var(--bg_gradient_color_1), var(--bg_gradient_color_2));
    box-shadow: 5px 5px 5px var(--shadow_color);
  }

  button {
    padding: 5px;
    float: right;
    background: var(--main_green_color);
    width: 33%;
  }

  .add-address {
    padding: 0 20px;
    float: left;
    background: transparent;
    box-shadow: none;
    width: 20px;
    font-size: 40px;
    font-weight: 400;
    color: var(--main_green_color);
  }
</style>

<div class="modal-background" on:click={close}></div>
<div class="modal" role="dialog" aria-modal="true" bind:this={modal}>
  <form action='#' on:submit={update}>
    {#each trip.stops as stop, i}
      <AddressInput setAddress={setAddress}
                    eraseAddress={eraseAddress}
                    address={stop}
                    index={i}
                    fieldsCount={trip.stops.length}/>
    {/each}
    <button type='button' on:click={addAddress} class='add-address' title='Add Address'>+</button>
    <button type='submit'>
      <Save style={{fill: 'var(--white_color)', width: '25px', height: '25px'}}/>
    </button>
  </form>
</div>

