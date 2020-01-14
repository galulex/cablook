import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

import { MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './constants.js'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import i18n from './i18n.js'
import './css/trips.css'
import Pin from './images/pin.svg'

const polyline = require('@mapbox/polyline')
const is_mapbox_supported = mapboxgl.supported()

export default class PreviewMap extends Component {
  constructor(props) {
    super(props)
    this.map = null;
    this.state = {
      trip: this.props.trip(),
      lng: CHERKASY_LONG_LAT[0],
      lat: CHERKASY_LONG_LAT[1],
      zoom: 12,
      departure: null,
      destination: null,
      waypoints: []
    }
  }

  componentDidMount() {
    if (is_mapbox_supported) {
      this.setWaypoints()
      const { zoom } = this.state;
      let geoJSON = polyline.decode(this.state.trip.path)
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

      this.map.addControl(language);
      this.map.addControl(geolocate);
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
            "coordinates": geoJSON.map(e => { return e.slice().reverse() }),
            "type": "LineString"
          }
        }]
      };

      this.map.on('load', () => {
        this.map.addSource('line', {
          type: 'geojson',
          lineMetrics: true,
          data: geojson
        });

        this.map.addLayer({
          type: 'line',
          source: 'line',
          id: 'line',
          paint: {
            'line-color': 'red',
            'line-width': 4,
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

        this.map.on('zoom', () => {
          document.documentElement.style.setProperty('--zoom-level', this.map.getZoom())
        });

        window.map = this.map
      });
      this.setMarker()

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

  componentWillReceiveProps() {
    this.setState({trip: this.props.trip()})
  }

  setMapboxLangauge = () => {
    return (this.props.language === 'uk') ? 'ru' : this.props.language
  }

  renderMap = () => {
    if (is_mapbox_supported) return(<div class='map' ref={el => this.mapContainer = el} />);
  }

  render() {
    const { trip } = this.state;

    return (
      <div class='trips'>
        {this.renderMap()}
        {this.renderPin()}
      </div>
    );
  }

  renderPin = () => {
    if (is_mapbox_supported) {
      return(
        <div class='pins'>
          <div ref={el => this.departure = el}><Pin class='departure'/></div>
          <div ref={el => this.destination = el}><Pin class='destination'/></div>
          {this.state.trip.waypoints.map(() => (<div><Pin class='waypoint'/></div>))}
        </div>
      )
    }
  }

  setWaypoints = () => {
    this.setState({departure: this.state.trip.departure.slice().reverse(), destination: this.state.trip.destination.slice().reverse()})
    this.setState(state => {
      this.state.trip.waypoints.map(waypoint => {state.waypoints.push(waypoint.slice().split(',').reverse())})
    })
  }

  setMarker = () => {
    new mapboxgl.Marker(this.departure).setLngLat(this.state.departure).addTo(this.map);
    new mapboxgl.Marker(this.destination).setLngLat(this.state.destination).addTo(this.map);
    this.state.waypoints.forEach((el, index) => {
      new mapboxgl.Marker(document.getElementsByClassName('waypoint')[index].parentNode).setLngLat(el).addTo(this.map);
    })
  }
}
