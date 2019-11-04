import { h, render, Component } from 'preact'

import i18n from '../i18n.js'
import Phone from '../images/white_phone.svg'
import TripTime from '../images/trip_time.svg'
import TripPrice from '../images/ukraine-hryvna.svg'
import Car from '../images/white_car.svg'
import Leaves from '../images/popup_leaves.svg'
import '../css/car_popup.css'

export default class CarPopup extends Component {
  render() {
    const car = this.props.car
    const trip = this.props.trip
    const driver = this.props.driver
    let driver_name = driver.name.split(' ')[1]
    return (
      <div>
        <div>
          <div class="mapboxgl-popup-content-line car"><Car/><span>{car.number}</span></div>
          <div class="mapboxgl-popup-content-line"><a href={`tel:${driver.phone_number}`}><Phone/>{driver_name}</a></div>
          <div class="mapboxgl-popup-content-line"><TripTime/>{trip.start_time}</div>
          <div><TripPrice/>{`${trip.cost}`}</div>
        </div>
        <div class="test_leaf"><Leaves/></div>
      </div>
    )
  }
}
