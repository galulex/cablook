import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import './css/vendor_preview.css'
import TripTime from './images/trip_time.svg'
import Pin from './images/pin_vendor.svg'

export default class VendorPreview extends Component {
  render() {
    const { vendor } = this.props
    const latlong = (vendor.location ? vendor.location.split(',') : '')

    return (
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
                      Меню
                    </Link>
                  </div>
                }
                <div class='col-5'>
                  <Link href='#' class='link-button go-to'>
                    Поїхали сюди
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
          Замовлення приймаються з {vendor.open_time} по {vendor.close_time}
        </div>
      </li>
    )
  }
}

