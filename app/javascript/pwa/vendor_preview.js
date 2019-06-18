import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import './css/vendor_preview.css'
import TripTime from './images/trip_time.svg'
import Pin from './images/pin_vendor.svg'

export default class VendorPreview extends Component {
  render() {
    const { vendor, cart_with_items } = this.props
    const latlong = (vendor.location ? vendor.location.split(',') : '')

    return (
      <ul>
        <li class={ 'vendor ' + this.props.active }>
          <div class='row'>
            <div class='col-7'>
              <div class='container'>
                <b class='name'>{vendor.name}</b>
                <br/>
                <span class='address'>{vendor.address}</span>
                <a href={'https://www.google.com/maps/@' + latlong[0] + ',' + latlong[1] + ',20z'} target='_blank'>
                  <Pin class={this.props.active}/>
                </a>
              </div>
              <div class='container buttons-container'>
                <div class='row'>
                  {!this.props.hide_content &&
                    <div class='col-5'>
                      <Link href={'/delivery/' + vendor.id} class='link-button'>
                        {i18n.vendor_preview.menu}
                      </Link>
                    </div>
                  }
                  <div class='col-5'>
                    <Link href='#' class='link-button go-to'>
                      {i18n.vendor_preview.go_to}
                    </Link>
                  </div>
                </div>
              </div>
            </div>
            <div class='col-3'>
              <img src={vendor.logo_url} class='vendor-logo' />
            </div>
          </div>
          <div class='time-container'>
            {i18n.vendor_preview.accepts_orders} {vendor.open_time} {i18n.vendor_preview.to} {vendor.close_time}
          </div>
        </li>
        { cart_with_items &&
          <Link href={'/delivery/cart'}>
            <li class='create-order'>
              Оформить заказ
            </li>
          </Link>
        }
      </ul>
    )
  }
}
