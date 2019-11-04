import { h, render, Component } from 'preact'
import axios from 'axios'
import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA'

import '../pwa/css/trips.css'
import Car from '../pwa/images/car.svg'
import Nissan from '../pwa/images/leaf.svg'

const polyline = require('@mapbox/polyline')

export default class Map extends Component {
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
    const { lng, lat, zoom } = this.state;
    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: 'mapbox://styles/mapbox/streets-v10',
      center: [lng, lat],
      zoom
    });
  }

  componentDidUpdate(prevProps) {
    for (const el of this.props.cars_locations) {
      if (window[`car_${el['car_id']}`]) { window[`car_${el['car_id']}`].remove() }
      this[`car_${el['car_id']}`] = new mapboxgl.Marker(this[`nissan_${el['car_id']}`])
      window[`car_${el['car_id']}`] = this[`car_${el['car_id']}`]
    }
    this.renderCars()
  }

  renderCars = () => {
    if (this.props.cars_locations.length === 0) return
    for (const el of this.props.cars_locations) {
      this[`car_${el['car_id']}`].setLngLat(el.location)
      this[`car_${el['car_id']}`].addTo(this.map)
    }
  }

  render() {
    return (
      <section class='trips'>
        <div class='map' ref={el => this.mapContainer = el} />
        <div class='pins'>
          {this.props.cars_locations.map((l) => {
            return(<div ref={el => this[`nissan_${l['car_id']}`] = el}><Nissan class='nissan' fill={l['color']}/></div>)
          })}
        </div>
      </section>
    )
  }
}
