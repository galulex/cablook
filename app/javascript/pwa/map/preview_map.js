import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language'

import { MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT, NUM_DELTAS, TELEPORT_DISTANCE } from '../lib/constants.js'
import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP } from '../constants.js'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import i18n from '../i18n.js'
import '../css/map.css'
import Pin from '../images/pin.js'

import CarPopup from '../new_design/car_popup.js'
import FocusOnCarControl from '../../pwa/trips/custom-control.js'

const polyline = require('@mapbox/polyline')

const LANGUAGES = {en: 'en', uk: 'ru', ru: 'ru'}
const MAPSTYLE = (localStorage.getItem('dark') === 'true') ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z'
const PATHCOLORS = (localStorage.getItem('dark') === 'true') ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
let timeout

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
      }
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
      zoom
    })

    const language = new MapboxLanguage({
      defaultLanguage: LANGUAGES[this.props.language]
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
    })

    this.map.on('moveend', () => {
      this.move = false
    })

    this.map.on('rotatestart', () => {
      this.rotate = true
      document.documentElement.style.setProperty('--car-transition', '0s')
      if (this.state.car !== null) {
        this.state.car._element.firstChild.style.transition = 'none'
      }
    })

    this.map.on('rotate', () => {
      if (this.state.car !== null) {
        this.updateCarDirection(this.state.car)
        this.state.car._element.firstChild.style.transition = 'none'
      }
    })

    this.map.on('rotateend', () => {
      this.rotate = false
      if (this.state.car !== null) {
        this.state.car._element.firstChild.style.transition = 'transform 1s'
      }
    })

    this.map.on('zoom', () => {
      document.documentElement.style.setProperty('--zoom-level', this.map.getZoom())
    })

    this.map.on('zoomend', (event) => {
      this.setState({zoom: this.map.getZoom()})
    })
    // controls + -
    this.map.addControl(new mapboxgl.NavigationControl({showCompass: false}), 'bottom-right')

    this.map.addControl(geolocate, 'bottom-right')
    this.map.addControl(language)

    this.map.on('load', () => {
      this.map.addSource('line', { type: 'geojson', lineMetrics: true, data: this.state.geojson || GEOJSON })
      this.map.addLayer(PATHLAYER)
    })
  }

  componentWillUnmount() {
  }

  updatePoint = (latlng) => {
    this.setState({point: {
      lat: latlng[0],
      lng: latlng[1]
    }})
  }

  updateCarDirection = (l) => {
    let short = Math.abs(l.prevAngleDeg) + Math.abs(l.carAngleDeg) > 180
    if (l.prevAngleDeg > 0 && l.carAngleDeg < 0 && short || l.prevAngleDeg < 0 && l.carAngleDeg > 0 && short ) {
      l._element.firstChild.style.transition = 'none'
      let reversCarAngle
      if (l.carAngleDeg > 0) {
        reversCarAngle = ((180 - l.carAngleDeg) * -1) - 180
      } else if (l.carAngleDeg < 0) {
        reversCarAngle = (180 + l.carAngleDeg) + 180
      } else {
        reversCarAngle = 0
      }
      l.prevAngleDeg = reversCarAngle
      l._element.firstChild.style.transform = "rotate(" + (reversCarAngle - this.map.getBearing()) + "deg)"
    } else  {
      l.prevAngleDeg = l.carAngleDeg
      l._element.firstChild.style.transform = "rotate(" + (l.carAngleDeg - this.map.getBearing()) + "deg)"
    }
    if (document.visibilityState == 'visible') {
      l._element.firstChild.style.transition = 'transform 4s'
    }
  }

  renderCar(car, trip, driver) {
    let div = document.createElement('div')
    let img = document.createElement('img')
    img.src = `https://res.cloudinary.com/active-bridge/image/upload/leafs/leaf${(window.dark) ? '_lights' : '' }_${car.color}.svg`
    div.appendChild(img)
    let marker = new mapboxgl.Marker(div)
    marker.setLngLat(car.location)
    marker._element.className += ' leaf'
    marker._element.addEventListener('transitionend', (event) => {
      document.documentElement.style.setProperty('--car-transition', '0s')
    })
    marker.carAngleDeg = car.deg
    var popupContent = render(<CarPopup car={car} trip={trip} driver={driver}/>)
    var popup = new mapboxgl.Popup({closeOnClick: false, closeButton: true, className: 'car-popup', anchor: 'bottom', offset: 10}).setHTML(popupContent.outerHTML)
    marker.setPopup(popup).addTo(this.map).togglePopup()

    this.carFocus = new FocusOnCarControl({eventHandler: this.focusOnCar})
    this.map.addControl(this.carFocus, 'bottom-right')

    this.updateCarDirection(marker)

    this.setState({ car: marker})
    if (this.state.car && this.state.car._popup.isOpen()) this.map.flyTo({ center: this.state.car.getLngLat(), speed: 1 })
  }

  focusOnCar = () => {
    if (this.state.car.getLngLat().lat == 0 || this.state.car.getLngLat().lat == 0) return
    if (this.map.getZoom() == this.map.getMinZoom()) {
      this.map.panTo(this.state.car.getLngLat())
    } else {
      this.map.flyTo({center: this.state.car.getLngLat()})
    }
  }

  pick = (index) => {
    this.setState({index: index})
    if (this.map.getSource('line')) this.map.getSource('line').setData(this.state.geojson || GEOJSON)
    this.markers.map(m => m.remove())
    this.map.on('movestart', this.movestart)
    this.map.on('moveend', this.moveend)
    this.geocode()
  }

  moveend = () => {
    timeout = setTimeout(this.geocode, 500)
  }

  movestart = () => {
    this.props.setGeocoding(true)
    clearTimeout(timeout)
    timeout = null
  }

  geocode = () => {
    const { lng, lat } = this.map.getCenter()

    if ((this.state.point.lat === lat && this.state.point.lng === lng) || this.move || ![CONFIRM_UPDATE_TRIP, undefined, null].includes(this.props.trip().status)) return

    this.updatePoint([lat, lng])

    this.props.geocode(`${lng},${lat}`, (address) => {
      if (this.move) return
      this.props.setAddress(address, `${lat},${lng}`, this.state.index)
      this.props.setGeocoding(false)
    })
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
  }

  pathFocus = (trip) => {
    try {
      var bounds = trip.waypoints.reduce((bounds, coord) => {
        return bounds.extend(coord.split(',').reverse())
      }, new mapboxgl.LngLatBounds(trip.waypoints[0].split(',').reverse(), trip.waypoints[0].split(',').reverse()))
      this.map.fitBounds(bounds, {
        padding: 100
      })
    } catch(error) {
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
      let marker = new mapboxgl.Marker(render(<div><Pin class={`pin-${klass}`} width='25px'/></div>))

      var popup = new mapboxgl.Popup({closeOnClick: false, closeButton: false, className: `point-${klass}`, anchor: 'left', offset: 10, opened: true}).setHTML(trip.stops[i])
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
    let trip = props.trip()

    this.drawMarkers(trip)
    this.drawPath(trip)
    if (![CONFIRM_UPDATE_TRIP, undefined, null].includes(trip.status) && this.map.getSource('line')) return
    if (![CONFIRM_UPDATE_TRIP].includes(props.trip().status)) this.pathFocus(trip)
  }

  updateCarPosition(data) {
    let car = this.state.car
    let position = [car.getLngLat().lng, car.getLngLat().lat]
    let distance
    if (position) {
      distance = data.distance < 0.3
    }
    let deg = data.deg
    if (!this.move && distance && !this.rotate && document.visibilityState == 'visible') document.documentElement.style.setProperty('--car-transition', '3s')
    car.carAngleDeg = deg
    car.setLngLat(data.location)
    if (deg !== 0) {
      if (document.visibilityState !== 'visible') {
        car._element.firstChild.style.transition = 'none'
      }
      this.updateCarDirection(car)
    }
  }

  setZoom = (event) => {
    this.map.flyTo({zoom: event.target.value, speed: 3})
    this.setState({zoom: event.target.value})
  }

  render() {
    const { trip } = this.props
    let { cars_locations } = this.state

    return (
      <div class='main_map'>
        <Pin class='picker' width='30px' ref={pin => this.pin = pin}/>
        <div class='map' ref={el => this.mapContainer = el}/>
      </div>
    )
  }
}
