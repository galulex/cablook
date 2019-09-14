import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

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
const TRANSITION = 10;

console.log(window.dark)

const MAPSTYLE = window.dark ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z';
const PATHCOLORS = window.dark ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']

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
    this.map = null;
    this.markers = []
    this.state = {
      lng: CHERKASY_LONG_LAT[0],
      lat: CHERKASY_LONG_LAT[1],
      zoom: 12,
      departure: null,
      destination: null,
      waypoints: [],
      subscription: null,
      cars: {},
      transition: TRANSITION
    }
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state

    this.getCarsLocations()
    this.subscribeToDriverChannel()

    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: MAPSTYLE,
      center: [lng, lat],
      minZoom: MAP_MIN_ZOOM,
      maxZoom: MAP_MAX_ZOOM,
      zoom
    })

    const language = new MapboxLanguage({
      defaultLanguage: this.setMapboxLanguage()
    })

    this.map.on('movestart', () => {
      if (!this.cars) return;
      this.setState({transition: 0})
    });

    this.map.on('moveend', () => {
      if (!this.cars) return;
      this.setState({transition: TRANSITION})
    });

    this.map.on('zoom', () => {
      document.documentElement.style.setProperty('--zoom-level', this.map.getZoom())
    });

    this.map.on('load', () => {
      this.map.addControl(language)
      this.map.addSource('line', { type: 'geojson', lineMetrics: true, data: GEOJSON })
      this.map.addLayer(PATHLAYER);
    });

    window.map = this.map
    document.addEventListener('visibilitychange', this.onVisibilityChange, false);
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack)
    document.removeEventListener('visibilitychange', this.onVisibilityChange)
    this.unsubscribe()
  }

  onVisibilityChange = () => {
    if (document.visibilityState === 'visible') {
      setTimeout(() => {
        this.setState({transition: TRANSITION})
      }, 10)
    } else {
      this.setState({transition: 0})
    }
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
          if (!data['location'] || !this.cars[data.car_id]) return;
          let car = this.cars[data.car_id]
          let deg = this.bearing(data.location.reverse(), [car.getLngLat().lng, car.getLngLat().lat])
          this.cars[data.car_id].carAngleDeg = deg
          this.cars[data.car_id].setLngLat(data.location)
          this.updateCarDirection(this.cars[data.car_id])
        }
      }
    )})
  }

  bearing = (start, end) => {
    let y = Math.sin(end[0] - start[0]) * Math.cos(end[1]);
    let x = Math.cos(start[1]) * Math.sin(end[1]) -
      Math.sin(start[1]) * Math.cos(end[1]) * Math.cos(end[0] - start[0]);
    return Math.atan2(y, x) * 180 / Math.PI
  }

  updateCarDirection = (l) => {
    let angle = l.carAngleDeg - this.map.getBearing();
    l._element.firstChild.style.transform = "rotate(" + angle + "deg)";
  }

  getCarsLocations = () => {
    axios.get('drivers_app/maps').then((res) => {
      let cars = {}
      res['data']['cars'].map((data) => {
        let marker = new mapboxgl.Marker(render(<div><NissanLeaf class='nissan' color={data['color']}car={`car_${data['id']}__`}/></div>))
        marker.setLngLat(data.location.reverse())
        if (!data.position) {
          marker.carAngleDeg = 180;
        }  else {
          marker.carAngleDeg = this.bearing(data.location, data.position.reverse())
        }
        marker.addTo(this.map)
        cars[data.id] = marker
        this.updateCarDirection(marker)
      })
      this.cars = cars

    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = (event) => {
    history.pushState(null, null, document.URL)
  }

  setMapboxLanguage = () => {
    return (this.props.language === 'uk') ? 'ru' : this.props.language
  }

  componentWillReceiveProps(props) {
    let trip = props.trip()
    this.markers.map(m => m.remove())
    if (trip.waypoints.length == 0) return;
    trip.waypoints.map((w, i) => {
      if (w === '') return;
      let klass = (i === trip.waypoints.length - 1) ? 'last' : ''
      if (i === 0) klass = 'first'
      let marker = new mapboxgl.Marker(render(<div><Pin class={`pin-${klass}`} width='25px'/></div>))

      var popup = new mapboxgl.Popup({closeOnClick: false, closeButton: false, className: `point-${klass}`, anchor: 'left', offset: 10}).setHTML(trip.stops[i]);
      marker.setLngLat(w.split(',').reverse()).setPopup(popup).addTo(this.map).togglePopup()
      this.markers.push(marker)
    })

    if (!this.props.isValid) return;

    var bounds = trip.waypoints.reduce((bounds, coord) => {
      console.log(bounds)
      console.log(coord)
      return bounds.extend(coord.split(',').reverse());
    }, new mapboxgl.LngLatBounds(trip.waypoints[0].split(',').reverse(), trip.waypoints[0].split(',').reverse()));
    this.map.fitBounds(bounds, {
      padding: 100
    });

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
    };
    this.map.getSource('line').setData(geojson)
  }

  render() {
    const { trip } = this.props
    let { cars_locations } = this.state

    return (
      <div class='main_map'>
        <Pin class='picker' width='30px'/>
        <style>{ `.mapboxgl-marker { transition: transform ${this.state.transition}s linear; } .mapboxgl-marker > svg { transition: transform 4s; }` }</style>
        <div class='map' ref={el => this.mapContainer = el}/>
      </div>
    )
  }
}

