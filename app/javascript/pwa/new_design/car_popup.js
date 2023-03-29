import { h } from 'preact'

import i18n from '../i18n.js'
import Phone from '../images/white_phone.js'
import TripTime from '../images/clock.svg'
import TripPrice from '../images/ukraine-hryvna.js'
import Car from '../images/white_car.js'
import Leaves from '../images/popup_leaves.svg'
import Cross from '../images/cross.js'
import '../css/car_popup.css'

export default function CarPopup(props) {
  let { car, trip, driver } = props
  let driver_name = driver.name.split(' ').length == 1 ? driver.name : driver.name.split(' ')[1]
  const car_brand = `${car.brand} ${car.model}`

  return(
    <div class='car-popup'>
      <Cross class="close-button"/>
      { car_brand && <div className='car-popup-line' title={car_brand}><Car/><span>{car_brand}</span></div> }
      <div className='car-popup-line'><Car/><span>{car.number}</span></div>
      <div className='car-popup-line'><a href={`tel:${driver.phone_number}`}><Phone/>{driver_name}</a></div>
      <div className='car-popup-line'><TripTime/>{trip.start_time}</div>
      <div className='car-popup-line'><TripPrice/>{`${trip.cost}`}</div>
      <Leaves class='popup_leaf'/>
    </div>
  )
}
