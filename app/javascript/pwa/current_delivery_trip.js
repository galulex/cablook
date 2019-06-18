import { h, render, Component } from 'preact';

import i18n from './i18n.js';
import './css/current_delivery_trip.css'
import TaxiDriverLT from './images/taxi_driver_light_theme.svg'
import TaxiDriverDT from './images/taxi_driver_dark_theme.svg'
import Pin from './images/pin.svg'
import Pizza from './images/pizza.svg'
import TripTime from './images/trip_time.svg'

export default class CurrentDeliveryTrip extends Component {
  render() {
    const { delivery_trip } = this.props
    const dark_mode = JSON.parse(localStorage.getItem('dark'))
    const items = JSON.parse(localStorage.getItem('delivery_items')).items

    return(
      <section class='delivery-trip'>
        <header>
          Delivery Trip
        </header>
        { dark_mode ? <TaxiDriverDT class='driver_icon'/>  : <TaxiDriverLT class='driver_icon'/> }
        <br/>
        <h4>Ваше замовлення прийнято!</h4>
        <p class='info'>Заклад проінформовано про ваше замовлення. При необхідності, заклад зв'яжеться з вами для уточнення деталей.</p>
        <div class='info-container'>
          <div class='info-item'>
            <TripTime/>
            <b>Час доставки: </b>
            <b class='desc'>{delivery_trip.start_time}</b>
          </div>
          <div class='info-item'>
            <Pin/>
            <b>Адреса: </b>
            <b class='desc'>{delivery_trip.destination_address}</b>
          </div>
          <div class='info-item'>
            <Pizza/>
            <b>Замовлення: </b>
            { Object.keys(items).map((item) => {
              return(
                <span>
                  <b class='desc'>{item} - {items[item].quantity} шт.</b>
                  <br/>
                </span>
              )
            })}
          </div>
        </div>
      </section>
    )
  }
}
