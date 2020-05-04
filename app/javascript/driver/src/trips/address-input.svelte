<script>
  import { streets } from '../../../pwa/streets.js'

  export let setAddress;
  export let eraseAddress;
  export let coords;
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
      predictions = ['No Result']
      address = e.target.value
      return
    }

    let autocomplete = new google.maps.places.AutocompleteService()
    predictions = ['Loading']
    address = e.target.value

    autocomplete.getPlacePredictions({input: e.target.value + ' Cherkasy', componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 100000, strictbounds: true, offset: 2}, data => {
      console.log(data)
      if (!data) {
        predictions = ['No Result']
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

<fieldset class='address'>
        <input required class='address' type='text' disabled={index === 0}
          on:keydown={keydown} on:input={autocomplete}
          value={address} />

        <ul class='predictions'>
          {#each predictions as prediction}
            <li on:click={() => setLocation(prediction)}>
              <b>{(prediction.structured_formatting) ? prediction.structured_formatting.main_text : prediction}</b>
              <br/>
              <sub>{(prediction.structured_formatting) ? prediction.structured_formatting.secondary_text : 'Cherkasy'}</sub>
            </li>
          {/each}
        </ul>
      </fieldset>
