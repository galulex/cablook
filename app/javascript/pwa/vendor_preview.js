import { h, render, Component } from 'preact'
import axios from 'axios'
import { route } from 'preact-router'

import i18n from './i18n.js'
import './css/vendor_preview.css'
import Pin from './images/pin_vendor.svg'

export default class VendorPreview extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: JSON.parse(localStorage.getItem('trip')),
    }
  }

  goToMenu = () => {
    const { vendor } = this.props

    this.props.showBurger(false)
    route(`/delivery/${vendor.id}`, true)
  }

  render() {
    const { vendor, cart_with_items } = this.props
    const latlong = (vendor.location ? vendor.location.split(',') : '')

    return (
      <li class={ 'tab-content__container vendor ' + this.props.active } onClick={this.goToMenu} id={vendor.name_slug}>
        <div class='row'>
          <div class='col-7'>
            <div class='container item-header'>
              <div class='item-header__content'>
                <b class='name'>{vendor.name}</b>
                <br/>
                <span class='address'>{vendor.address}</span>
              </div>
            </div>
            <div class='container buttons-container'>
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
    )
  }
}
