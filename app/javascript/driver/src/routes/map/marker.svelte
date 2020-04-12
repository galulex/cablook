<script>
  import { getContext } from 'svelte'
  import { contextKey } from '@beyonk/svelte-mapbox'
  import { onMount, afterUpdate } from 'svelte'

  const { getMap, getMapbox } = getContext(contextKey)
  const map = getMap()
  const mapbox = getMapbox()
  export let car

  let bearing = (start, end) => {
    let y = Math.sin(end[0] - start[0]) * Math.cos(end[1]);
    let x = Math.cos(start[1]) * Math.sin(end[1]) -
      Math.sin(start[1]) * Math.cos(end[1]) * Math.cos(end[0] - start[0]);
    return Math.atan2(y, x) * 180 / Math.PI
  }

  let location = car.location.slice().reverse()
  let position = car.position.slice().reverse()
  let deg = (bearing(location, position) || 180) - map.getBearing()
  let linearOffset = Math.round(Math.sqrt(0.3 * Math.pow(40, 2)));
  const popup = new mapbox.Popup({ offset: [linearOffset, -linearOffset], className: car.status, anchor: 'bottom-right' })

  let marker
  let pin

  onMount(() => {
    pin = new mapbox.Marker(marker)
    pin.setLngLat(location).setPopup(popup).addTo(map)
    updateCar()
  })

  afterUpdate(() => {
    updateCar()
  })

  let updatePopup = () => {
    popup.setHTML(`<a href='tel:${car.phone_number}'><label>${car.number}, ${car.speed || 0}km/h</label></br><label>${(car.driver || {}).name}</label> </a>`)
  }

  let updateCar = () => {
    location = car.location.slice().reverse()
    position = car.position.slice().reverse()
    deg = (bearing(location, position) || 180) - map.getBearing()
    pin.setLngLat(location)
    updatePopup()
    pin._element.firstChild.style.transform = `rotate(${deg}deg)`;
  }

</script>

<style>
  .marker {
    width: 40px;
    height: 140px;
  }
</style>

<div class='marker' bind:this={marker}>
  <img src={`//res.cloudinary.com/active-bridge/image/upload/leafs/leaf_lights_${car.color}.svg`} alt='car' />
</div>
