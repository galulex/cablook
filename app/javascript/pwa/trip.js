import { h, render, Component } from 'preact'
import axios from 'axios'
import mapboxgl from 'mapbox-gl'

mapboxgl.accessToken = 'pk.eyJ1Ijoib2t1bmlldmEiLCJhIjoiY2pybHc3dDY2MGJ4aTN6bWZjMGxlOWhrMiJ9.bk9lWZM6sHClogdqthjHSA'

import i18n from './i18n.js'
import './css/trips.css'
import TripPrice from './images/trip_price.svg'
import TripStatus from './images/trip_status.svg'
import TripTime from './images/trip_time.svg'
import Phone from './images/green_phone.svg'
import Cards from './images/credit-cards-payment.svg'
import Car from './images/car.svg'

const polyline = require('@mapbox/polyline')

export default class Trip extends Component {
  constructor(props) {
    super(props)
    this.map = null;
    this.state = {
      lng: 32.059769,
      lat: 49.444431,
      zoom: 12
    }
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state;
    let geoJSON = polyline.decode(this.props.trip.path)
    console.log(geoJSON)
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
              coordinates: geoJSON.map(e => { return e.reverse() })
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
    window.map = this.map
    });
  }

  render() {
    const { trip } = this.props;
    console.log(this.props)
    return (
      <section class='trips'>
        <header>{i18n.trip.header}</header>
        <div class='map' ref={el => this.mapContainer = el} />
        { this.renderButton() }
        <div class='trip-details-content'><Car/>{`${trip.driver_name} ${i18n.trip.on} ${trip.car_number}`}</div>
        <div class='trip-details-content'><TripTime/>{trip.start_time}</div>
        <div class='trip-details-content'><Phone/>{trip.car_phone_number}</div>
        <div class='trip-details-content'>
          <address>{trip.departure_address}</address>
          <address>{trip.destination_address}</address>
        </div>
        <div class='trip-details-content'><TripPrice/>{`${trip.cost} ${i18n.trip.currency}`}</div>
        <div class='trip-details-content'><TripStatus/>{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
        <div class='trip-details-content'><Cards/>{`${i18n.trip.status} - ${i18n.trip.payment_statuses[trip.payment_status]}`}</div>
      </section>
    );
  }

  renderButton = () => {
    if (this.props.trip.status == 1) return(<button class='button cancel' onClick={this.props.cancel}>{i18n.trip.cancel}</button>)
  }
}
