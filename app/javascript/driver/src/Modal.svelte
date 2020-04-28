<script>
  import axios from 'axios';
  import { createEventDispatcher } from 'svelte';

  import Save from '../images/save_changes.svelte'

  const dispatch = createEventDispatcher();
  const close = () => dispatch('close');

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
    padding: 1em;
    border-radius: 10px;
    background: white;
  }

  button {
    padding: 5px;
    float: right;
    background: var(--main_green_color);
    width: 33%;
  }

  input {
    padding: 10px;
    width: 100%;
    margin: 0 0 15px 0;
  }
</style>

<div class="modal-background" on:click={close}></div>
<div class="modal" role="dialog" aria-modal="true" bind:this={modal}>
  <form action='#' on:submit={update}>
    {#each trip.stops as stop, i}
      <input name={`stops[${i}]`} bind:value={trip.stops[i]} required/>
    {/each}
    <button type='submit'>
      <Save style={{fill: 'var(--white_color)', width: '25px', height: '25px'}}/>
    </button>
  </form>
</div>

