<script>
  import { getContext } from 'svelte'
  import { contextKey } from '@beyonk/svelte-mapbox'
  import { onMount, afterUpdate } from 'svelte'

  const { getMap, getMapbox } = getContext(contextKey)
  const map = getMap()
  const mapbox = getMapbox()
  export let car
  export let sos

  let popupBackground = () => {
    if (sos && sos === car.id) return 'background-red'
  }

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
  const popup = new mapbox.Popup({ offset: [linearOffset, -linearOffset], className: `${car.status} ${popupBackground()}`, anchor: 'bottom-right' })

  let marker
  let pin
  let timeout

  onMount(() => {
    pin = new mapbox.Marker(marker)
    pin.setLngLat(location).setPopup(popup).addTo(map)
    updateCar()
  })

  afterUpdate(() => {
    if (sos && sos === car.id) openSosPopup()
    updateCar()
  })

  let openSosPopup = () => {
    map.flyTo({center: pin.getLngLat(), speed: 1})
    if (!popup.options.className.includes('background-red')) popup.options.className += ' background-red'
    pin.togglePopup()
  }

  let updatePopup = () => {
    popup.setHTML(`<a href='tel:${car.phone_number}'><label>${car.number}, ${car.speed || 0}km/h</label></br><label>${(car.driver || {}).name}</label> </a>`)
  }

  let updateCar = () => {
    location = car.location.slice().reverse()
    position = car.position.slice().reverse()

    if (position[0] === location[0] && position[1] === location[1]) return

    deg = (bearing(location, position) || 180)
    navigateTo(location, position, deg)
    updateCarDirection(deg)
    /* map.flyTo({ center: location, speed: 0.1, maxDuration: 3000 }) */
    updatePopup()
  }

  let updateCarDirection = (deg) => {
    let x = 180 + Math.trunc(deg / 3)
    let steps = Math.abs((car.x || 240) - x)
    if (steps === 0) return

    let diff = Math.abs(Math.abs(car.x) - Math.abs(x))
    if (diff > 69) {
      car.x = (car.x > x) ? car.x - 120 : car.x + 120
      marker.firstChild.style.setProperty('--steps', 1)
      marker.firstChild.style.setProperty('--x', car.x + 180)
    }

    setTimeout(() => {
      steps = Math.abs(car.x - x)
      marker.firstChild.style.setProperty('--steps', steps)
      marker.firstChild.style.setProperty('--x', x + 180)
      car.x = x
    }, 10)
  }

  let navigateTo = (location, position, deg) => {
    let steps = 0
    let numDeltas = 80
    let newLocation = location
    const car = pin
    clearTimeout(timeout)

    /* let position = [this.state.car.getLngLat().lng, this.state.car.getLngLat().lat] */
    const lng = newLocation[0] - car.getLngLat().lng
    const lat = newLocation[1] - car.getLngLat().lat
    const deltaLng = lng / numDeltas
    const deltaLat = lat / numDeltas
    const drive = () => {
      position[0] += deltaLng
      position[1] += deltaLat
      pin.setLngLat(position)
      if (steps < numDeltas) {
        steps++
        timeout = setTimeout(drive, 30);
      } else {
        steps = 0
      }
    }

    if (document.visibilityState == 'visible') {
      drive()
    } else {
      this.state.car.setLngLat(newLocation)
    }
  }

</script>

<style>
  figure {
    --x: 240;
    --steps: 1;
    /* --deg: 120; */
    scale: calc(((1 - var(--zoom-level) * (10/15)) * 0.1) * -1);
    background-image: url(https://i.imgur.com/LQbcdFl.png);
    width: 137px;
    height: 137px;
    background-position: calc((var(--x) - var(--bearing)) * 137px) calc(var(--y) * 137px);
    z-index: 100;
    margin: 0;
    transition: background-position-x steps(var(--steps), start) 1s, margin-bottom .1s;
    margin-bottom: calc(var(--y) * 7px);
  }

  figure.black {
    background-image: url(https://i.imgur.com/2I27NDX.png);
  }

  figure.red {
    background-image: url(https://i.imgur.com/K0gyniG.png);
  }

  figure.blue {
    background-image: url(https://i.imgur.com/wAE6bCm.png);
  }

  figure.silver {
    background-image: url('https://i.imgur.com/hgHsphP.png');
  }
</style>

<div class='marker' bind:this={marker}>
  <figure class={car.color}></figure>
</div>
