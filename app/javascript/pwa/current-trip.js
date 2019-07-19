import { h, render, Component } from 'preact';
import { route } from 'preact-router';
import axios from 'axios';

import i18n from './i18n.js'
import Loader from './loader.js'
import AddressInput from '../pwa/trips/address-input.js';
import Add  from './images/add.svg'
import Back from './images/arrow-left.svg'
import './css/current_trip.css'
import { CANCELED } from './constants.js'

const Shake = require('shake.js')
let myShakeEvent = null

export default class CurrentTrip extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: this.getTrip(),
      submitDisabled: false,
      showLoader: false,
      entrance: Array.from({length: 15}, (v, k) => (k+1))
    },
    this.shake_trip_params = null
  }

  componentDidMount() {
    const { trip } = this.state
    if (!window.ios && trip.id) history.pushState(null, null, '/')

    myShakeEvent = new Shake({threshold: 20, timeout: 2000})
    myShakeEvent.start()

    window.addEventListener('shake', this.shakeEvent, false)
    window.addEventListener('popstate', this.props.getTripRequest, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.props.getTripRequest)
    }
  }

  componentWillUnmount() {
    myShakeEvent.stop()
    window.removeEventListener('shake', this.shakeEvent)
    window.removeEventListener('popstate', this.props.getTripRequest);
  }

  getTrip = () => {
    const { trip } = this.props
    const empty_trip = {
      waypoints: [],
      stops: ['',''],
      departure: '',
      destination: '',
      departure_address: '',
      destination_address: '',
      no_call: false,
      entrance: null,
      time: null,
      osrm: true,
      comment: ''
    }
    if (trip && trip.id && [CANCELED].includes(trip.status)) {
      this.props.updateTrip(null)
      return empty_trip
    }
    if (trip !== null && trip.status !== 7) {
      let current_trip = {...trip}
      current_trip.stops.unshift(current_trip.departure_address)
      current_trip.stops.push(current_trip.destination_address)
      current_trip.departure = current_trip.departure.join()
      current_trip.destination = current_trip.destination.join()
      current_trip.waypoints.unshift(current_trip.departure)
      current_trip.waypoints.push(current_trip.destination)
      current_trip.osrm = true
      return current_trip
    } else {
      return empty_trip
    }
  }

  shakeEvent = () => {
    const { trip } = this.state
    const { cards } = this.props

    if (trip && trip.id) {
      return (alert(i18n.trips.pending_trip_exists))
    } else if (cards().length < 1 ) {
      if (confirm(`${i18n.cards.no_cards}. ${i18n.cards.please_add}`)) return (route('/cards', true))
    } else { this.createShakeTrip() }
  }

  createShakeTrip = () => {
    if (navigator.geolocation) {
      this.showLoader(true)
      navigator.geolocation.getCurrentPosition((result) => {
        let geocoder = new google.maps.Geocoder()
        let location = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)

        geocoder.geocode( { 'location': location }, (res, status) => {
          if (status == 'OK') this.setTripParams(res)
        })
      },
        (error) => {
          this.showLoader(false)
          switch(error.code) {
            case error.PERMISSION_DENIED :
              alert(i18n.location.permission_denied)
              break
            case error.TIMEOUT:
              alert(i18n.location.timeout)
              break
            case error.POSITION_UNAVAILABLE :
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

    this.shake_trip_params = {
      departure: coords,
      destination: coords,
      departure_address: address,
      destination_address: address,
      osrm: true,
      bonus: false,
      comment: 'Швидка поїдка. Я зміню кінцеву точку після посадки.'
    }
    this.sendCreateRequest()
  }

  sendCreateRequest = () => {
    axios.post('trips', {trip: this.shake_trip_params}).then((res) => {
      this.props.updateTrip(res.data)
    }).catch((error) => {
      this.showLoader(false)
      if (!error.response) return
      if (error.response.status == 418) {
        if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
          this.retryPendingPayment()
        }
      } else alert(error.response.data.errors)
    })
  }

  retryPendingPayment = () => {
    const { cards } = this.props
    this.showLoader(true)

    axios.post('payments/retry_pendings', {card_id: cards()[0].id}).then((res) => {
      if (res.data.length === 0) {
        this.sendCreateRequest()
      } else {
        this.showLoader(false)
        setTimeout(() => {alert(i18n.confirm_trip.payment_error)}, 500)
      }
    }).catch((error) => {
      this.showLoader(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
      return state
    })
    this.updateTrip()
  }

  updateTrip = () => {
    this.setState(state => {
      state.trip.departure = state.trip.waypoints[0]
      state.trip.destination = state.trip.waypoints[state.trip.waypoints.length - 1]
      state.trip.departure_address = state.trip.stops[0]
      state.trip.destination_address = state.trip.stops[state.trip.stops.length - 1]
      return state
    })
  }

  addAddress = () => {
    this.setState(state => {
      state.trip.stops.push('');
    })
  }

  removeAddress = (index) => {
    this.setState(state => {
      state.trip.stops.splice(index, 1);
      state.trip.waypoints.splice(index, 1);
      return state
    })
    this.updateTrip()
  }

  eraseAddress = (index) => {
    if (this.state.trip.stops[index] === '') {
      this.removeAddress(index)
    } else {
      this.setState(state => {
        state.trip.stops[index] = '';
        state.trip.waypoints[index] = '';
        return state
      })
      this.updateTrip()
    }
  }

  setComment = (e) => {
    let state = this.state
    state.trip.comment = e.target.value
    this.setState(state);
  }

  setNoCall = (e) => {
    (e.target.checked == true) ? this.state.trip.no_call = true : this.state.trip.no_call = false
    this.setState(this.state);
  }

  setEntrance = (e) => {
    this.state.trip.entrance = e.target.value
    this.setState(this.state);
  }

  setOrderTime = (e) => {
    this.state.trip.time = (e.target.value == '' ? null : e.target.value)
    this.setState(this.state);
  }

  build = (e) => {
    let params = {...this.state.trip}
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    this.submitDisabled(true)
    params.waypoints = params.waypoints.slice(1, -1)
    params.stops = params.stops.slice(1, -1)
    axios.post('trips/new', {trip: params}).then((res) => {
      if (res.data.id) res.data.status = 10
      this.props.updateTrip(res.data)
      window.removeEventListener('popstate', this.props.getTripRequest);
    }).catch((error) => {
      this.submitDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  submitDisabled = val => {
    this.setState({ submitDisabled: val })
  }

  renderTripData = () => {
    const { trip } = this.state
    if (trip.id) return;
    return [
      <div class='nocall'>
        <input id='nocall' type='checkbox' checked={trip.no_call} onChange={this.setNoCall}/>
        <label for='nocall'>
          {i18n.current_trip.no_call}
        </label>
      </div>,
      <label for='entrance'>
        <span>{i18n.current_trip.where_to_pick}</span>
        <select id='entrance' value={trip.entrance} onChange={(e) => this.setEntrance(e)}>
          <option value=''>{i18n.current_trip.select_entrance}</option>
          {this.state.entrance.map((el) => {
            return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
          })}
        </select>
      </label>,
      <label for='time'>
        <span>{i18n.current_trip.when}</span>
        <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]' value={trip.time} placeholder='Now' onChange={this.setOrderTime}/>
      </label>,
      <input type='text' class='comment' value={trip.comment} placeholder={i18n.current_trip.comment} onChange={this.setComment}/>
    ]
  }

  renderBackButton = () => {
    return (<button type='button' id='arrow' class='burger' onClick={() => window.ios ? this.props.getTripRequest() : window.history.back()}><Back/></button>)
  }

  showLoader = (val) => {
    this.setState({showLoader: val})
  }

  render() {
    const { showLoader, trip, trip: { stops } } = this.state
    let isValid = (stops.includes(''))

    return (
      <div class='current-trip'>
        {showLoader && <Loader/>}
        <section class="home">
          {!!trip.id && this.renderBackButton()}
          <header>{i18n.current_trip.header}</header>
          <form action='#' onSubmit={(e) => e.preventDefault()}>
            <div class='addresses'>
              { trip.stops.map((e, i) => {
                return (
                  <AddressInput
                    setAddress={this.setAddress}
                    eraseAddress={this.eraseAddress}
                    favorite_addresses={() => this.props.favorite_addresses}
                    language={this.props.language}
                    coords={trip.waypoints[i]}
                    readonly={!!trip.id && i == 0}
                    address={e}
                    index={i}
                    fieldsCount={stops.length}
                  />
                )
              })}
              <div>
                <Add width='32px' class='add-address' onClick={this.addAddress} disabled={isValid}/>
                <button type='button' onClick={this.addAddress} class='add-address' disabled={isValid}>{ i18n.current_trip.add_address }</button>
              </div>
            </div>
            {this.renderTripData()}
            <input type='submit' disabled={this.state.submitDisabled} class='button' onClick={this.build} value='OK'/>
          </form>
        </section>
      </div>
    )
  }
}
