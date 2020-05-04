<script>
  import { streets } from '../../../pwa/streets.js'

  export let setAddress;
  export let eraseAddress;
  export let address;
  export let index;
  export let fieldsCount;

  let predictions = [];

  let setLocation = (place) => {
    if (!place.place_id) {
      address = `${place}, `
      predictions = []
      return
    }

    let placeService = new google.maps.places.PlacesService(document.createElement('div'))
    placeService.getDetails({placeId: place.place_id, fields: ['geometry']}, result => {
      address = place.structured_formatting.main_text
      predictions = []

      setAddress(address, `${result.geometry.location.lat()},${result.geometry.location.lng()}`, index)
    })
  }

  let autocomplete = (e) => {
    if (e.target.value === '') {
      predictions = []
      address = e.target.value
      return false
    }

    let hits = streets.filter(function(s) { return s.toLowerCase().indexOf(e.target.value.toLowerCase()) != -1 }).slice(0, 5)

    if (hits.length > 0) {
      predictions = hits
      address = e.target.value
      return false
    }

    if (!window.google) {
      predictions = ['Адрес не знайдено']
      address = e.target.value
      return
    }

    let autocomplete = new google.maps.places.AutocompleteService()
    predictions = ['Пошук...']
    address = e.target.value

    autocomplete.getPlacePredictions({input: e.target.value + ' Cherkasy', componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 100000, strictbounds: true, offset: 2}, data => {
      if (!data) {
        predictions = ['Адрес не знайдено']
        address = e.target.value
        return
      }
      predictions = data
      address = e.target.value
    })
  }

  let keydown = (e) => {
    let prediction = predictions[0]
    if (![13, 9].includes(e.which) || !prediction) return
    setLocation(prediction)
    if (!prediction.place_id) e.preventDefault()
  }

</script>

<style>
  input {
    padding: 10px;
    width: 100%;
  }

  button.remove-address {
    position: absolute;
    right: 10%;
    font-size: 2rem;
    font-weight: 400;
    background: none;
    border: none;
    box-shadow: none;
    color: var(--red_color);
    cursor: pointer;
  }

  fieldset {
    border: none;
    margin: 0 0 15px 0;
    padding: 0;
  }
  ul {
    margin: 0 2.5em;
    padding: 0;
    background: white;
    list-style: none;
    width: 84%;
    position: absolute;
    z-index: 100;
    left: 0;
    transition: opacity .3s, visibility 0s .5s;
    max-height: 60vh;
    overflow-y: auto;
    box-shadow: 0 3px 6px var(--shadow_color);
    border-bottom: none;
    border-radius: 10px;
  }
  li {
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    color: black;
    border-bottom: 1px solid var(--shadow_color);
    line-height: 1;
    padding: 10px 15px;
    transition: background .2s;
    cursor: pointer;
    position: relative;
    font-size: 16px;
  }

  li b {
    font-size: 16px;
  }
</style>

<fieldset class='address'>
  {#if fieldsCount > 2 || address !== ''}
    <button disabled={index === 0} class='remove-address' type='button' on:click={() => eraseAddress(index)}>×</button>
  {/if}
  <input required class='address' type='text' disabled={index === 0}
    on:keydown={keydown} on:input={autocomplete}
    value={address} />

  <ul>
    {#each predictions as prediction}
      <li on:click={() => setLocation(prediction)}>
        <b>{(prediction.structured_formatting) ? prediction.structured_formatting.main_text : prediction}</b>
        <br/>
        <sub>{(prediction.structured_formatting) ? prediction.structured_formatting.secondary_text : 'Cherkasy'}</sub>
      </li>
    {/each}
  </ul>
</fieldset>
