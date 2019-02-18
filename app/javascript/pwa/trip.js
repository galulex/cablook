import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import i18n from './i18n.js'
import './css/trips.css'
import TripPrice from './images/trip_price.svg'
import TripStatus from './images/trip_status.svg'
import TripTime from './images/trip_time.svg'
import Phone from './images/green_phone.svg'
import Car from './images/car.svg'
import Pin from './images/pin.svg'
import Nissan from './images/leaf.svg'

const polyline = require('@mapbox/polyline')

export default class Trip extends Component {
  constructor(props) {
    super(props)
    this.map = null;
    this.state = {
      lng: 32.059769,
      lat: 49.444431,
      zoom: 12,
    }
  }

  componentDidMount() {
    this.car = new mapboxgl.Marker(this.nissan)
    const { lng, lat, zoom } = this.state;
    let geoJSON = polyline.decode(this.props.trip.path)
    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      // style: 'mapbox://styles/okunieva/cjrlxcvzu2osh2spcikwl1zhl',
      style: 'mapbox://styles/mapbox/streets-v9',
      center: this.props.trip.departure.reverse(),
      zoom
    });

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: false
    });

    let point = {
      "type": "FeatureCollection",
      "features": [{
      "type": "Feature",
      "properties": {},
      "geometry": {
      "type": "Point",
      "coordinates": [-77.032, 38.913]
      }
      }]
    };

    this.map.addControl(geolocate);
    this.map.on('load', () => {
      // geolocate.trigger()
      this.map.addLayer({
        id: 'trip_path',
        type: 'line',
        source: {
          type: 'geojson',
          data: {
            type: 'Feature',
            properties: {},
            geometry: {
              type: 'LineString',
              coordinates: geoJSON.map(e => { return e.reverse() }),
            }
          }
        },
        layout: {
          'line-join': 'round',
          'line-cap': 'round',
        },
        paint: {
          'line-width': 4,
          'line-color': '#19a169',
          'line-opacity': 1
        }
      });
      this.map.addSource('point', {
        "type": "geojson",
        "data": point
        });
      this.map.addLayer({
        id: 'point',
        source: {
          type: 'geojson',
          data: {
            type: "FeatureCollection",
            features: [{
              type: "Feature",
              properties: {},
              geometry: {
                type: "Point",
                coordinates: [-77.032, 38.913]
              }
            }]
          }
        },
        "type": "symbol",
        "layout": {
        "icon-image": "airport-15",
        "icon-rotate": ["get", "bearing"],
        "icon-rotation-alignment": "map",
        "icon-allow-overlap": true,
        "icon-ignore-placement": true
        }
      });
    window.map = this.map
    });
    this.setMarker()
    history.pushState(null, null, document.URL)
    window.addEventListener('popstate', this.handleBack)
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack);
  }

  handleBack = (event) => {
    history.pushState(null, null, document.URL)
  }

  componentDidUpdate() {
    this.renderCar()
  }

  renderCar = () => {
    if (this.props.location.length === 0) return
    this.car.setLngLat(this.props.location)
    this.car.addTo(this.map)
  }

  render() {
    const { trip } = this.props;
    return (
      <section class='trips'>
        <header>{i18n.trip.header}</header>
        <div class='map' ref={el => this.mapContainer = el} />
        {this.renderButton()}
        <div class='trip-details-content'><Car/>{`${trip.driver_name} ${i18n.trip.on} ${trip.car_number}`}</div>
        <div class='trip-details-content'><TripTime/>{trip.start_time}</div>
        <div class='trip-details-content'><Phone/>{trip.car_phone_number}</div>
        <div class='trip-details-content'>
          <address class='details-address'>{trip.departure_address}</address>
          {this.renderStops()}
          <address class='details-address'>{trip.destination_address}</address>
        </div>
        <div class='trip-details-content'><TripPrice/>{`${trip.cost} ${i18n.trip.currency}`}</div>
        <div class='trip-details-content'><TripStatus/>{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
        {this.renderPin()}
      </section>
    );
  }

  renderButton = () => {
    if (this.props.trip.status == 1) return(<button class='button cancel' onClick={this.props.cancel}>{i18n.trip.cancel}</button>)
  }

  renderStops = () => {
    let stops = this.props.trip.stops
    return(stops.map(stop => (<address class='details-address'>{stop}</address>)))
  }

  renderPin = () => {
    return(
      <div class='pins'>
        <div ref={el => this.nissan = el}><Nissan class='nissan' fill={this.props.trip.car_color}/></div>
        <div ref={el => this.departurePin = el}><Pin class='departure'/></div>
        <div ref={el => this.destinationPin = el}><Pin class='destination'/></div>
        {this.props.trip.waypoints.map(() => (<div><Pin class='waypoint'/></div>))}
      </div>
    )
  }

  setMarker = () => {
    new mapboxgl.Marker(this.departurePin).setLngLat(this.props.trip.departure).addTo(this.map);
    new mapboxgl.Marker(this.destinationPin).setLngLat(this.props.trip.destination.reverse()).addTo(this.map);
    this.props.trip.waypoints.forEach((el, index) => {
      new mapboxgl.Marker(document.getElementsByClassName('waypoint')[index].parentNode).setLngLat(el.split(',').reverse()).addTo(this.map);
    })
  }
}
