import { h, render, Component } from 'preact'
import { Link } from 'preact-router/match'
import axios from 'axios'
import { route } from 'preact-router'

import i18n from './i18n.js'
import './css/vendor_preview.css'
import TripTime from './images/trip_time.svg'
import Pin from './images/pin_vendor.svg'

export default class VendorPreview extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: JSON.parse(localStorage.getItem('trip')),
    }
  }

  buildTrip = () => {
    const { trip } = this.state

    if (navigator.geolocation) {
      this.props.updateLoaderState(true)
      navigator.geolocation.getCurrentPosition((result) => {
        let geocoder = new google.maps.Geocoder()
        let location = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)

        geocoder.geocode( { 'location': location }, (res, status) => {
          if (status == 'OK') this.setTripParams(res)
        })
      },
        (error) => {
          this.props.updateLoaderState(false)
          switch(error.code) {
            case error.PERMISSION_DENIED:
              alert(i18n.location.permission_denied)
              break
            case error.TIMEOUT:
              alert(i18n.location.timeout)
              break
            case error.POSITION_UNAVAILABLE:
              alert(i18n.location.position_unavailable)
              break
            default:
              alert(error.message)
              break
          }
        }
      )
    } else alert(i18n.location.not_supported)
  }

  setTripParams = (res) => {
    let place = res[0]
    let address = `${place.address_components[1].long_name}, ${place.address_components[0].long_name}`
    let coords = `${place.geometry.location.lat()},${place.geometry.location.lng()}`
    const { vendor } = this.props

    const params = {
      departure: coords,
      destination: vendor.location,
      departure_address: address,
      destination_address: vendor.address,
      osrm: true,
      bonus: false,
      waypoints: [],
      stops: [],
      no_call: false
    }

    axios.post('trips/new', {trip: params}).then((res) => {
      let trip = res.data
      localStorage.setItem('trip', JSON.stringify(trip))
      this.props.updateLoaderState(false)
      route('/', true)
    }).catch((error) => {
      this.props.updateLoaderState(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  goToMenu = () => {
    const { vendor } = this.props

    history.pushState(null, null, document.URL)
    route(`/delivery/${vendor.id}`, true)
  }

  render() {
    const { vendor, cart_with_items } = this.props
    const latlong = (vendor.location ? vendor.location.split(',') : '')

    return (
      <ul>
        <li class={ 'vendor ' + this.props.active } id={vendor.name_slug}>
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
                      <button onClick={this.goToMenu} class='button link-button'>
                        {i18n.vendor_preview.menu}
                      </button>
                    </div>
                  }
                  <div class='col-5'>
                    <button onClick={this.buildTrip} class='button go-to'>
                      {i18n.vendor_preview.go_to}
                    </button>
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
              {i18n.vendor_preview.create_order}
            </li>
          </Link>
        }
      </ul>
    )
  }
}
