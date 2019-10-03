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
const LANGUAGES = {en: 'en', uk: 'ru', ru: 'ru'}
const MAPSTYLE = (localStorage.getItem('dark') === 'true') ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z';
const PATHCOLORS = (localStorage.getItem('dark') === 'true') ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
var timeout

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
      defaultLanguage: LANGUAGES[this.props.language]
    })

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: false
    });

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

    this.map.on('zoomend', (event) => {
      this.setState({zoom: this.map.getZoom()})
    });

    // this.map.addControl(geolocate, 'bottom-right')
    this.map.addControl(language)
    // this.map.addControl(new mapboxgl.NavigationControl({showCompass: false}), 'bottom-right')

    this.map.on('load', () => {
      this.map.addSource('line', { type: 'geojson', lineMetrics: true, data: GEOJSON })
      this.map.addLayer(PATHLAYER);
      // geolocate.trigger()
    });

    window.map = this.map
    document.addEventListener('visibilitychange', this.onVisibilityChange, false);
  }

  componentWillUnmount() {
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
          car._element.className += ' smooth'
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
        marker._element.className += ' leaf'
        marker._element.addEventListener('transitionend', (event) => {
          event.target.classList.remove('smooth')
        })
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

  pick = (index) => {
    this.setState({index: index})
    this.map.getSource('line').setData(GEOJSON)
    this.markers.map(m => m.remove())
    this.map.on('movestart', this.movestart);
    this.map.on('moveend', this.moveend);
    this.geocode()
  }

  moveend = () => {
    timeout = setTimeout(this.geocode, 500)
  }

  movestart = () => {
    clearTimeout(timeout)
    timeout = null
  }

  geocode = () => {
    const { lng, lat } = this.map.getCenter();
    const latlng = {lat, lng};
    const waypoint = Object.values(this.map.getCenter()).reverse().toString()
    const geocoder = new google.maps.Geocoder();

    geocoder.geocode({'location': latlng}, (results, status) => {
      if (status === 'OK') {
        if (results[0]) {
          this.props.setAddress(`${results[0].address_components[1].long_name}, ${results[0].address_components[0].long_name}`, waypoint, this.state.index)
        } else {
          this.props.setAddress('No results found', waypoint, this.state.index)
        }
      } else {
        console.log('Geocoder failed due to: ' + status);
      }
    });
  }

  componentWillReceiveProps(props) {
    if (props.picker !== null) return this.pick(props.picker)
    this.map.off('movestart', this.movestart);
    this.map.off('moveend', this.moveend);
    let trip = props.trip()
    this.markers.map(m => m.remove())
    if (trip.waypoints.length == 0) return;
    trip.waypoints.map((w, i) => {
      if (w === '') return;
      let klass = (i === trip.waypoints.length - 1) ? 'last' : ''
      if (i === 0) klass = 'first'
      let marker = new mapboxgl.Marker(render(<div><Pin class={`pin-${klass}`} width='25px'/></div>))

      var popup = new mapboxgl.Popup({closeOnClick: false, closeButton: false, className: `point-${klass}`, anchor: 'left', offset: 10}).setHTML(trip.stops[i]);
      marker.setLngLat(w.split(',').reverse()).setPopup(popup).addTo(this.map)//.togglePopup()
      this.markers.push(marker)
    })

    try {
      var bounds = trip.waypoints.reduce((bounds, coord) => {
        return bounds.extend(coord.split(',').reverse());
      }, new mapboxgl.LngLatBounds(trip.waypoints[0].split(',').reverse(), trip.waypoints[0].split(',').reverse()));
      this.map.fitBounds(bounds, {
        padding: 100
      });
    } catch(error) {
    }

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
    if (this.map.getSource('line')) this.map.getSource('line').setData(geojson)
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
        <style>{ `.mapboxgl-marker.leaf.smooth { transition: transform ${this.state.transition}s linear; } .mapboxgl-marker.leaf > svg { transition: transform 4s; }` }</style>
        <div class='map' ref={el => this.mapContainer = el}/>
        <input type='range' min='8' max='17' onInput={this.setZoom} value={this.state.zoom}/>
      </div>
    )
  }
}

