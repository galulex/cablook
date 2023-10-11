import render from 'preact-render-to-string'
import { h, Component } from 'preact'
import axios from 'axios'
import { geocode } from '../../pwa/geolocation.js'
import mapboxgl from 'mapbox-gl'
import { MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT, NUM_DELTAS, TELEPORT_DISTANCE } from '../lib/constants.js'
import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP } from '../constants.js'

mapboxgl.accessToken = 'pk.eyJ1IjoiYWxleHN0IiwiYSI6ImNsajVra2ZqNDBhdzQzZHF6N3gwZ2lzbXYifQ.t207B3n10JqQEekacf1Xhg'

import i18n from '../i18n.js'
import '../css/map.css'
import Pin from '../images/pin.svg'
import Back from '../images/arrow-left.svg'

import CarPopup from '../new_design/car_popup.js'
import FocusOnCarControl from '../../pwa/trips/custom-control.js'

const polyline = require('@mapbox/polyline')
const MAPSTYLE = (localStorage.getItem('dark') === 'true') ? 'mapbox://styles/alexst/clm68anew00x801pj3q718ltj' : 'mapbox://styles/alexst/clm60hwvh00yh01pf34d3cxbf'
const PATHCOLORS = (localStorage.getItem('dark') === 'true') ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
let timeout, driveTimeout

const GEOJSON = {
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "coordinates": [],
      "type": "LineString"
    }
  }]
}

const PATHLAYER = {
  type: 'line',
  source: 'line',
  id: 'line',
  paint: {
    'line-color': '#19a160',
    'line-width': 4,
    'line-gradient': [
      'interpolate',
      ['linear'],
      ['line-progress'],
      0, PATHCOLORS[0],
      1, PATHCOLORS[1]
    ]
  },
  layout: {
    'line-cap': 'round',
    'line-join': 'round'
  }
}


export default class PreviewMap extends Component {
  constructor(props) {
    super(props)
    this.map = null
    this.markers = []
    this.state = {
      lng: CHERKASY_LONG_LAT[0],
      lat: CHERKASY_LONG_LAT[1],
      zoom: 12,
      waypoints: [],
      car: null,
      point: {
        lat: null,
        lng: null
      },
      isGeocoding: false
    }
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state

    this.car = new mapboxgl.Marker(this.nissan)
    window.car = this.car

    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: MAPSTYLE,
      center: [lng, lat],
      minZoom: MAP_MIN_ZOOM,
      maxZoom: MAP_MAX_ZOOM,
      pitch: 39,
      maxPitch: 69,
      zoom,
    })

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: false
    })

    this.map.on('movestart', () => {
      this.move = true
      document.documentElement.style.setProperty('--car-transition', '0s')
      this.setState({ isGeocoding: true })
    })

    this.map.on('moveend', () => {
      this.move = false
    })

    this.map.on('rotatestart', () => {
      this.rotate = true
      if (this.state.car !== null) {
        this.state.car._element.firstChild.style.setProperty('--steps', 1)
      }
    })

    this.map.on('rotate', () => {
      if (this.state.car !== null) {
        this.state.car._element.firstChild.style.setProperty('--steps', 1)
        this.updateCarDirection(this.state.car)
      }
    })

    this.map.on('rotateend', () => {
      this.rotate = false
    })

    this.map.on('zoom', () => {
      document.documentElement.style.setProperty('--zoom-level', this.map.getZoom())
    })

    this.map.on('zoomend', (event) => {
      this.setState({ zoom: this.map.getZoom() })
    })

    this.map.on('pitch', () => {
      const y = (Math.round(this.map.getPitch() / 19) + 1)
      document.documentElement.style.setProperty('--y', y)
    });
    // controls + -
    this.map.addControl(new mapboxgl.NavigationControl({ visualizePitch: true }), 'bottom-right')

    this.map.addControl(geolocate, 'bottom-right')

    this.map.on('load', () => {
      this.map.addSource('line', { type: 'geojson', lineMetrics: true, data: this.state.geojson || GEOJSON })
      this.map.addLayer(PATHLAYER)
    })
  }

  updatePoint = (latlng) => {
    this.setState({
      point: {
        lat: latlng[0],
        lng: latlng[1]
      }
    })
  }

  updateCarDirection = (l) => {
    let x = 120 + Math.trunc((l.carAngleDeg - this.map.getBearing()) / 3)
    let steps = Math.abs((l.x || 120) - x)

    let diff = Math.abs(Math.abs(l.x) - Math.abs(x))
    if (diff > 69) {
      l.x = (l.x > x) ? l.x - 120 : l.x + 120
      l._element.firstChild.style.setProperty('--steps', 1)
      l._element.firstChild.style.setProperty('--x', l.x + 180)
    }

    setTimeout(() => {
      steps = Math.abs(l.x - x)
      if (this.rotate) steps = 1
      l._element.firstChild.style.setProperty('--steps', steps)
      l._element.firstChild.style.setProperty('--x', x + 180)
      l.x = x
    }, 10)
  }

  navigateTo = (newLocation) => {
    let steps = 0
    let numDeltas = 100
    const { car } = this.state
    clearTimeout(driveTimeout)

    let position = [this.state.car.getLngLat().lng, this.state.car.getLngLat().lat]
    const lng = newLocation[0] - car.getLngLat().lng
    const lat = newLocation[1] - car.getLngLat().lat
    const deltaLng = lng / numDeltas
    const deltaLat = lat / numDeltas
    const drive = () => {
      position[0] += deltaLng
      position[1] += deltaLat
      if (!this.state.car) return

      this.state.car.setLngLat(position)
      if (steps < numDeltas) {
        steps++
        driveTimeout = setTimeout(drive, 30);
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

  popupContent(car, trip, driver) {
    return render(<CarPopup car={car} trip={trip} driver={driver} />)
  }

  updatePopup(car, trip, driver) {
    if (!this.popup) return
    this.popup.setHTML(this.popupContent(car, trip, driver))
  }

  renderCar(car, trip, driver) {
    let div = document.createElement('div')
    let img = document.createElement('figure')
    // img.src = `https://res.cloudinary.com/active-bridge/image/upload/leafs/leaf${(window.dark) ? '_lights' : '' }_${car.color}.svg`
    div.appendChild(img)
    let marker = new mapboxgl.Marker(div)
    marker.setLngLat(car.location)
    marker._element.className += ` leaf ${car.color}`
    marker.carAngleDeg = car.deg
    let popupContent = this.popupContent(car, trip, driver)
    this.popup = new mapboxgl.Popup({ closeOnClick: false, closeButton: true, className: 'car-popup', anchor: 'bottom' }).setHTML(popupContent)

    marker.setPopup(this.popup).addTo(this.map).togglePopup()
    this.carFocus = new FocusOnCarControl({ eventHandler: this.focusOnCar })
    this.map.addControl(this.carFocus, 'bottom-right')

    this.updateCarDirection(marker)

    this.setState({ car: marker }, () => {
      this.map.flyTo({ center: this.state.car.getLngLat(), speed: 1 })
    })
  }

  focusOnCar = () => {
    if (this.state.car.getLngLat().lat == 0 || this.state.car.getLngLat().lat == 0) return
    if (this.map.getZoom() == this.map.getMinZoom()) {
      this.map.panTo(this.state.car.getLngLat())
    } else {
      this.map.flyTo({ center: this.state.car.getLngLat() })
    }
  }

  pick = (index) => {
    this.setState({ index: index })
    if (this.map.getSource('line')) this.map.getSource('line').setData(this.state.geojson || GEOJSON)
    this.markers.map(m => m.remove())
    this.map.on('movestart', this.movestart)
    this.map.on('moveend', this.moveend)
    this.geocode
  }

  moveend = () => {
    timeout = setTimeout(this.geocode, 500)
  }

  movestart = () => {
    clearTimeout(timeout)
    timeout = null
  }

  geocode = async () => {
    const { lng, lat } = this.map.getCenter()

    if ((this.state.point.lat === lat && this.state.point.lng === lng) || this.move || ![CONFIRM_UPDATE_TRIP, undefined, null].includes(this.props.trip().status)) return

    this.updatePoint([lat, lng])

    let address = await geocode(lng, lat)

    if (!address) {
      this.props.clearPicker()
      let address_inputs = document.querySelectorAll('input.address')
      address_inputs[this.state.index].focus()

      return alert(i18n.location.picked_address_unavailable)
    }

    if (this.move) return
    this.props.setAddress(address, `${lat},${lng}`, this.state.index)
    this.setState({ isGeocoding: false })
  }

  cleanup = () => {
    if (this.state.car) {
      this.state.car.remove()
      this.map.removeControl(this.carFocus)
    }
    this.setState({ car: null })
    this.markers.map(m => m.remove())
    if (this.map.getSource('line')) this.map.getSource('line').setData(GEOJSON)
  }

  addCar = (props) => {
    if (!this.state.car) this.renderCar(props.car, props.trip(), props.driver)
    this.updateCarPosition(props.car)
    this.popupContent(props.car, props.trip(), props.driver)
  }

  pathFocus = (trip) => {
    try {
      var bounds = trip.waypoints.reduce((bounds, coord) => {
        return bounds.extend(coord.split(',').reverse())
      }, new mapboxgl.LngLatBounds(trip.waypoints[0].split(',').reverse(), trip.waypoints[0].split(',').reverse()))
      this.map.fitBounds(bounds, {
        padding: 100,
        pitch: this.map.getPitch(),
      })
    } catch (error) {
    }
  }

  drawPath = (trip) => {
    let path = (trip.path) ? polyline.decode(trip.path).map(e => { return e.reverse() }) : []
    var geojson = {
      "type": "FeatureCollection",
      "features": [{
        "type": "Feature",
        "properties": {},
        "geometry": {
          "coordinates": path,
          "type": "LineString"
        }
      }]
    }
    this.setState({ geojson: geojson })
    if (this.map.getSource('line')) this.map.getSource('line').setData(geojson)
  }

  drawMarkers = (trip) => {
    this.markers.map(m => m.remove())
    if (trip.waypoints.length == 0) return
    trip.waypoints.map((w, i) => {
      if (w === '') return
      let klass = (i === trip.waypoints.length - 1) ? 'last' : ''
      if (i === 0) klass = 'first'
      let div = document.createElement('div')
      div.innerHTML = render(<Pin class={`pin pin-${klass}`} width='25px' />)
      let marker = new mapboxgl.Marker(div)

      let popup = new mapboxgl.Popup({ closeOnClick: false, closeButton: false, className: `point-${klass}`, anchor: 'left', offset: 10, opened: true }).setHTML(trip.stops[i])
      if (trip && [PENDING].includes(trip.status)) {
        marker.setLngLat(w.split(',').reverse()).setPopup(popup).addTo(this.map).togglePopup()
      } else {
        marker.setLngLat(w.split(',').reverse()).setPopup(popup).addTo(this.map)
      }
      this.markers.push(marker)
    })
  }

  componentWillReceiveProps(props) {
    if ([FINISHED].includes(props.trip().status)) return this.cleanup()
    if (props.car) this.addCar(props)
    if (props.picker !== null) return this.pick(props.picker)
    this.map.off('movestart', this.movestart)
    this.map.off('moveend', this.moveend)
    let { driver, car } = props
    let trip = props.trip()
    this.drawMarkers(trip)
    this.drawPath(trip)
    if (![CONFIRM_UPDATE_TRIP, undefined, null].includes(trip.status) && this.map.getSource('line')) return
    if (![CONFIRM_UPDATE_TRIP].includes(trip.status)) this.pathFocus(trip)
    if (driver) this.updatePopup(car, trip, driver)
  }

  updateCarPosition(data) {
    let car = this.state.car
    if (!car) return

    let position = [car.getLngLat().lng, car.getLngLat().lat]
    if (position[0] === data.location[0] && position[1] === data.location[1]) return

    let deg = Math.round(((this.bearing(data.location, position) || 360)) + 360)
    if (!this.move && document.visibilityState == 'visible') document.documentElement.style.setProperty('--car-transition', '0.1s')
    car.carAngleDeg = deg
    this.navigateTo(data.location)
    this.updateCarDirection(car)
  }

  bearing = (start, end) => {
    let y = Math.sin(end[0] - start[0]) * Math.cos(end[1]);
    let x = Math.cos(start[1]) * Math.sin(end[1]) -
      Math.sin(start[1]) * Math.cos(end[1]) * Math.cos(end[0] - start[0]);
    return Math.atan2(y, x) * 180 / Math.PI
  }

  setZoom = (event) => {
    this.map.flyTo({ zoom: event.target.value, speed: 3 })
    this.setState({ zoom: event.target.value })
  }

  handleBackEdit = async e => {
    this.props.mainBurger.classList.remove('hidden')
    let { driver, car, fetchUser, clearPicker, picker } = this.props

    if (picker !== null) clearPicker()
    window.ios ? fetchUser() : window.history.back()

    const rest = await this.props.fetchUser()
    this.updatePopup(car, this.props.trip(), driver)
  }

  render() {
    const { picker, pickAddress, trip } = this.props
    return (
      <div class='main_map'>
        {[CONFIRM_UPDATE_TRIP].includes(trip().status) && <button type='button' class='burger button white-opacity back' onClick={this.handleBackEdit}><Back /></button>}
        <Pin class='pin picker' width='30px' ref={pin => this.pin = pin} />
        <div class='map' ref={el => this.mapContainer = el} />
        {(picker !== null) &&
          <button
            class='button green pick_address absolute'
            type='button'
            disabled={this.state.isGeocoding}
            onClick={pickAddress}>
            OK
          </button>
        }
      </div>
    )
  }
}
