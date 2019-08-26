import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';
import rhumbBearing from '@turf/rhumb-bearing';
import { point } from '@turf/helpers'

import { MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT, NUM_DELTAS, TELEPORT_DISTANCE } from '../lib/constants.js'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import i18n from '../i18n.js'
import '../css/map.css'
import Phone from '../images/green_phone.svg'
import Pin from '../images/pin.svg'

import NissanLeaf from '../../pwa/trips/nissan-leaf.js'
import FocusOnCarControl from '../../pwa/trips/custom-control.js'

const polyline = require('@mapbox/polyline')
const is_mapbox_supported = mapboxgl.supported()

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer('wss://app.cablook.taxi/cable')

export default class PreviewMap extends Component {
  constructor(props) {
    super(props)
    this.map = null;
    this.state = {
      lng: CHERKASY_LONG_LAT[0],
      lat: CHERKASY_LONG_LAT[1],
      zoom: 12,
      departure: null,
      destination: null,
      waypoints: [],
      carAngleDeg: 0,
      subscription: null,
      cars_locations: []
    }
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state

    this.getCarsLocations()
    this.subscribeToDriverChannel()

    let style = this.setMapStyle()
    let path_color = this.setPathColor()

    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: style,
      center: [lng, lat],
      minZoom: MAP_MIN_ZOOM,
      maxZoom: MAP_MAX_ZOOM,
      zoom
    })

    this.map.on('render', () => {
      this.state.cars_locations.map((l) => {
        if (this[`car_${l['car_id']}`].getLngLat()) {
          this.updateCarDirection(l)
        }
      })
    });

    const language = new MapboxLanguage({
      defaultLanguage: this.setMapboxLanguage()
    })

    this.numDeltas = 150;
    this.steps = 0;
    this.deltaLat = 0;
    this.deltaLng = 0;
    this.position = [0, 0];
    this.prevPosition = [0, 0];
    this.maxTeleportLng = 0;
    this.maxTeleportLat = 0;
    this.teleportDistance = 0.005;

    window.map = this.map
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack)
    this.unsubscribe()
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({subscription: null})
  }

  subscribeToDriverChannel = () => {
    if (this.state.subscription) return this.state.subscription
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'DriverMapChannel' },
      {
        received: data => {
          let cars_locations = this.state.cars_locations
          let found = false

          if (!data['location']) return;

          cars_locations = cars_locations.map((l) => {
            if (l.car_id == data['car_id']) {
              found = true
              if (JSON.stringify(data['location']) !== JSON.stringify(l.prevPosition)) {
                l.prevPosition = data['location']
                l.location = data['location'].reverse()
                l.steps = 0
                if (this[`car_${l['car_id']}`].getLngLat()) {
                  l.position = [this[`car_${l['car_id']}`].getLngLat().lng, this[`car_${l['car_id']}`].getLngLat().lat];
                  l.maxTeleportLng = data['location'][0] - this[`car_${l['car_id']}`].getLngLat().lng;
                  l.maxTeleportLat = data['location'][1] - this[`car_${l['car_id']}`].getLngLat().lat;
                  l.deltaLng = l.maxTeleportLng / NUM_DELTAS;
                  l.deltaLat = l.maxTeleportLat / NUM_DELTAS;

                  let bearing = rhumbBearing(point(data['location']), point([this[`car_${l['car_id']}`].getLngLat().lng, this[`car_${l['car_id']}`].getLngLat().lat]));

                  l.carAngleDeg = bearing
                }
                this.renderCar(l)
              }
            }
            return l
          })
          if (!found) { cars_locations = [...cars_locations, { car_id: data['car_id'], location: data['location'].reverse() }] }
          this.setState({ cars_locations })
        }
      }
    )})
  }

  renderCar = (l) => {
    if (l.location.length === 0) return

    if (this[`car_${l['car_id']}`].getLngLat() &&
        Math.abs(l.maxTeleportLng) < TELEPORT_DISTANCE ||
        Math.abs(l.maxTeleportLat) < TELEPORT_DISTANCE) {
      l.position[0] += l.deltaLng;
      l.position[1] += l.deltaLat;
      this[`car_${l['car_id']}`].setLngLat(l.position);
      this.updateCarDirection(l);
      if (l.steps != NUM_DELTAS) {
        l.steps++;
        setTimeout(() => this.renderCar(l), 200);
      }
    } else {
      this[`car_${l['car_id']}`].setLngLat(l.location)
    }
  }

  updateCarDirection = (l) => {
    let el = this[`car_${l['car_id']}`].getElement();
    let angle = l.carAngleDeg - this.map.getBearing();
    if (el.style.transform.includes("rotate")) {
      el.style.transform = el.style.transform.replace(/rotate(.*)/, "rotate(" + angle + "deg)");
    } else {
      el.style.transform = el.style.transform + "rotate(" + angle + "deg)";
    }
  }

  getCarsLocations = () => {
    if (this.state.cars_locations.length) return;
    axios.get('drivers_app/maps').then((res) => {
      let cars_locations = this.state.cars_locations
      cars_locations = res['data']['cars'].map((data) => {
        return { car_id: data['id'],
                 color: data['color'],
                 location: data['location'].reverse(),
                 steps: 0,
                 deltaLat: 0,
                 deltaLng: 0,
                 position: [0, 0],
                 prevPosition: [0, 0],
                 maxTeleportLng: 0,
                 maxTeleportLat: 0,
                 carAngleDeg: 0 }
      });
      this.setState({ cars_locations })
      this.setCarsMarkers()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  setCarsMarkers = () => {
    for (const el of this.state.cars_locations) {
      if (window[`car_${el['car_id']}`]) window[`car_${el['car_id']}`].remove()
      this[`car_${el['car_id']}`] = new mapboxgl.Marker(render(<div><NissanLeaf class='nissan' color={el['color']}car={`car_${el['car_id']}__`}/></div>))
      window[`car_${el['car_id']}`] = this[`car_${el['car_id']}`]
    }
    this.renderCars()
  }

  renderCars = () => {
    if (this.state.cars_locations.length === 0) return
    for (const el of this.state.cars_locations) {
      this[`car_${el['car_id']}`].setLngLat(el.location)
      this[`car_${el['car_id']}`].addTo(this.map)
    }
  }

  handleBack = (event) => {
    history.pushState(null, null, document.URL)
  }

  setMapStyle = () => {
    return window.dark ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/mapbox/streets-v10';
  }

  setPathColor = () => {
    return window.dark ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
  }

  setMapboxLanguage = () => {
    return (this.props.language === 'uk') ? 'ru' : this.props.language
  }

  render() {
    const { trip } = this.props
    let { cars_locations } = this.state

    return (
      <section class='main_map'>
        <div class='map' ref={el => this.mapContainer = el}/>
      </section>
    )
  }
}

