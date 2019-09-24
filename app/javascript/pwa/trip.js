import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';
import rhumbBearing from '@turf/rhumb-bearing';
import { point } from '@turf/helpers'

import { MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './constants.js'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import i18n from './i18n.js'
import './css/trips.css'
import TripPrice from './images/trip_price.svg'
import TripStatus from './images/trip_status.svg'
import TripTime from './images/trip_time.svg'
import Phone from './images/green_phone.svg'
import Car from './images/leaf_icon.svg'
import Pin from './images/pin.svg'

import NissanLeaf from '../pwa/trips/nissan-leaf.js'
import FocusOnCarControl from '../pwa/trips/custom-control.js'

const polyline = require('@mapbox/polyline')
const is_mapbox_supported = mapboxgl.supported()

export default class Trip extends Component {
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
      carAngleDeg: 0
    }
  }

  componentDidMount() {
    if (is_mapbox_supported) {
      this.car = new mapboxgl.Marker(this.nissan)
      window.car = this.car
      this.setWaypoints()
      const { lng, lat, zoom } = this.state;
      let geoJSON = polyline.decode(this.props.trip.path)
      let style = window.dark ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/mapbox/streets-v10';
      let path_color = window.dark ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']

      this.map = new mapboxgl.Map({
        container: this.mapContainer,
        style: style,
        center: this.state.departure,
        minZoom: MAP_MIN_ZOOM,
        maxZoom: MAP_MAX_ZOOM,
        zoom
      });

      const geolocate = new mapboxgl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        trackUserLocation: false
      });

      const language = new MapboxLanguage({
        defaultLanguage: this.setMapboxLangauge()
      });

      this.numDeltas = 150;
      this.steps = 0;
      this.deltaLat = 0;
      this.deltaLng = 0;
      this.position = [0, 0];
      this.prevPosition = [0, 0];
      this.maxTeleportLng = 0;
      this.maxTeleportLat = 0;
      this.teleportDistance = 0.005;
      this.map.addControl(language);
      this.map.addControl(geolocate);
      this.map.addControl(new FocusOnCarControl({eventHandler: this.focusOnCar}));
      this.map.addControl(new mapboxgl.NavigationControl({showCompass: false}));

      if (window.dark) {
        let mapboxCtrlRight = document.getElementsByClassName('mapboxgl-ctrl-top-right');
        mapboxCtrlRight[0].classList.add('dark');
      }

      var geojson = {
        "type": "FeatureCollection",
        "features": [{
          "type": "Feature",
          "properties": {},
          "geometry": {
            "coordinates": geoJSON.map(e => { return e.reverse() }),
            "type": "LineString"
          }
        }]
      };

      this.map.on('load', () => {
        // 'line-gradient' can only be used with GeoJSON sources
        // and the source must have the 'lineMetrics' option set to true
        this.map.addSource('line', {
          type: 'geojson',
          lineMetrics: true,
          data: geojson
        });

        // the layer must be of type 'line'
        this.map.addLayer({
          type: 'line',
          source: 'line',
          id: 'line',
          paint: {
            'line-color': 'red',
            'line-width': 4,
            // 'line-gradient' must be specified using an expression
            // with the special 'line-progress' property
            'line-gradient': [
              'interpolate',
                ['linear'],
                ['line-progress'],
                0, path_color[0],
                1, path_color[1]
              ]
            },
            layout: {
            'line-cap': 'round',
            'line-join': 'round'
          }
        });

      this.map.on('render', () => {
        if (this.car.getLngLat()) {
          this.updateCarDirection()
        }
      });

      this.map.on('zoom', () => {
        document.documentElement.style.setProperty('--zoom-level', this.map.getZoom())
      });

      window.map = this.map
      });
      this.setMarker()
      this.car.setLngLat(this.props.trip.car_location);
      this.car.addTo(this.map);

      let coords = this.state.waypoints.map(waypoint => {return waypoint})
      coords.splice(0, 0, this.state.departure)
      coords.splice(coords.length - 1, 0, this.state.destination)

      var bounds = coords.reduce(function(bounds, coord) {
        return bounds.extend(coord);
      }, new mapboxgl.LngLatBounds(this.state.departure, this.state.departure));

      this.map.fitBounds(bounds, {
        padding: 150
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack);
  }

  handleBack = (event) => {
    history.pushState(null, null, document.URL)
  }

  componentDidUpdate() {
    if (JSON.stringify(this.props.location) !== JSON.stringify(this.prevPosition)) {
      this.prevPosition = this.props.location;
      this.steps = 0;
      if (this.car.getLngLat()) {
        this.position = [this.car.getLngLat().lng, this.car.getLngLat().lat];
        this.maxTeleportLng = this.props.location[0] - this.car.getLngLat().lng;
        this.maxTeleportLat = this.props.location[1] - this.car.getLngLat().lat;
        this.deltaLng = this.maxTeleportLng / this.numDeltas;
        this.deltaLat = this.maxTeleportLat / this.numDeltas;

        let bearing = rhumbBearing(point(this.props.location), point([this.car.getLngLat().lng, this.car.getLngLat().lat]));
        this.setState({carAngleDeg: bearing })
      }
      this.renderCar();
    }
  }

  renderCar = () => {
    if (this.props.location.length === 0) return

    if (this.car.getLngLat() &&
        Math.abs(this.maxTeleportLng) < this.teleportDistance ||
        Math.abs(this.maxTeleportLat) < this.teleportDistance) {
      this.position[0] += this.deltaLng;
      this.position[1] += this.deltaLat;
      this.car.setLngLat(this.position);
      this.car.addTo(this.map);
      this.updateCarDirection();
      if (this.steps != this.numDeltas) {
        this.steps++;
        setTimeout(this.renderCar, 200);
      }
    } else {
      this.car.setLngLat(this.props.location)
      this.car.addTo(this.map)
    }
  }

  setMapboxLangauge = () => {
    return (this.props.language === 'uk') ? 'ru' : this.props.language
  }

  renderMap = () => {
    if (is_mapbox_supported) return(<div class='map' ref={el => this.mapContainer = el} />);
  }

  render() {
    const { trip } = this.props;
    return (
      <section class='trips'>
        <header>{i18n.trip.header}</header>
        {this.renderMap()}
        {is_mapbox_supported && this.renderButton()}
        <div class='trip-details-content'><Car/>{`${trip.driver_name} ${i18n.trip.on} ${trip.car_number}`}</div>
        <div class='trip-details-content'><TripTime/>{trip.start_time}</div>
        <div class='trip-details-content'><a href={`tel:${trip.car_phone_number}`}><Phone/>{trip.car_phone_number}</a></div>
        <div class='trip-details-content'>
          <address class='details-address'>{trip.departure_address}</address>
          {this.renderStops()}
          <address class='details-address'>{trip.destination_address}</address>
        </div>
        <div class='trip-details-content'><TripPrice/>{`${trip.cost} ${i18n.trip.currency}`}</div>
        <div class='trip-details-content'><TripStatus/>{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
        {this.renderPin()}
        {!is_mapbox_supported && this.renderButton()}
      </section>
    );
  }

  renderButton = () => {
    switch(this.props.trip.status) {
      case 1:
        return(<button class='button cancel' onClick={this.props.cancel}>{i18n.trip.cancel}</button>)
      case 2:
      case 3:
        return(<button class='button edit' id='edit_trip' onClick={this.props.edit}>{i18n.trip.edit}</button>)
    }
  }

  renderStops = () => {
    let stops = this.props.trip.stops
    return(stops.map(stop => (<address class='details-address'>{stop}</address>)))
  }

  renderPin = () => {
    if (is_mapbox_supported) {
      return(
        <div class='pins'>
          <div ref={el => this.nissan = el}><NissanLeaf class='nissan' color={this.props.trip.car_color} car={'car__'}/></div>
          <div ref={el => this.departure = el}><Pin class='departure'/></div>
          <div ref={el => this.destination = el}><Pin class='destination'/></div>
          {this.props.trip.waypoints.map(() => (<div><Pin class='waypoint'/></div>))}
        </div>
      )
    }
  }

  setWaypoints = () => {
    this.setState({departure: this.props.trip.departure.reverse(), destination: this.props.trip.destination.reverse()})
    this.setState(state => {
      this.props.trip.waypoints.map(waypoint => {state.waypoints.push(waypoint.split(',').reverse())})
    })
  }

  setMarker = () => {
    new mapboxgl.Marker(this.departure).setLngLat(this.state.departure).addTo(this.map);
    new mapboxgl.Marker(this.destination).setLngLat(this.state.destination).addTo(this.map);
    this.state.waypoints.forEach((el, index) => {
      new mapboxgl.Marker(document.getElementsByClassName('waypoint')[index].parentNode).setLngLat(el).addTo(this.map);
    })
  }

  updateCarDirection = () => {
    let el = this.car.getElement();
    let angle = this.state.carAngleDeg - this.map.getBearing();
    if (el.style.transform.includes("rotate")) {
      el.style.transform = el.style.transform.replace(/rotate(.*)/, "rotate(" + angle + "deg)");
    } else {
      el.style.transform = el.style.transform + "rotate(" + angle + "deg)";
    }
  }

  focusOnCar = () => {
    if (this.car.getLngLat().lat == 0 || this.car.getLngLat().lat == 0) return
    if (this.map.getZoom() == this.map.getMinZoom()) {
      this.map.panTo(this.car.getLngLat());
    } else {
      this.map.flyTo({center: this.car.getLngLat()});
    }
  }
}
