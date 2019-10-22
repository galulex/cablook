import { h, render, Component } from 'preact'

import i18n from '../i18n.js'
import Phone from '../images/green_phone.svg'
import TripTime from '../images/trip_time.svg'
import TripPrice from '../images/ukraine-hryvna.svg'
import Car from '../images/leaf_icon.svg'
import '../css/car_popup.css'

export default class CarPopup extends Component {
  render() {
    const car = this.props.car
    const trip = this.props.trip
    const driver = this.props.driver
    return (
      <div>
        <div class="mapboxgl-popup-content-line"><Car/>{car.number}</div>
        <div class="mapboxgl-popup-content-line"><a href={`tel:${driver.phone_number}`}><Phone/>{driver.name}</a></div>
        <div class="mapboxgl-popup-content-line"><TripTime/>{trip.start_time}</div>
        <div><TripPrice/>{`${trip.cost}`}</div>
      </div>
    )
  }
}
