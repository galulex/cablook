import { h, render, Component } from 'preact'
import axios from 'axios'
import { createConsumer } from '@rails/actioncable';

import i18n from './i18n.js'
import './css/map.css'
import PreviewMap from './map/preview_map.js'
import Buttons from './new_design/buttons.js'
import AddressInput from '../pwa/trips/address-input.js';
import Feedback from '../pwa/feedback.js';
import Add from './images/+.svg'
import Widget from './widget.js'
import Entrance from './images/entrance.svg'
import Clock from './images/trip_time.svg'
import Card from './images/credit-cards-payment.svg'
import Phone from './images/phone_crossed.svg'
import Comment from './images/contacts.svg'
import Arrows from './images/arrows.svg'
import SearchLogo from './images/search_logo.svg'
import './css/new_design.css'
import './css/range.css'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './lib/constants.js'

const cable = createConsumer()
const ENTRANCES = Array.from({length: 15}, (v, k) => (k+1))
const TRIP_FIELDS = ['departure', 'departure_address', 'destination', 'destination_address', 'path', 'status', 'id', 'stops', 'waypoints', 'cost', 'distance', 'duration', 'start_time']
const YANDEX_API_KEY = '9bbf546a-a5ca-44e1-abb2-8785a76fcbb4'
const YANDEX_LANG = {en: 'en-US', uk: 'uk_UA', ru: 'ru_RU'}

const Shake = require('shake.js')
let myShakeEvent = false
const initialTripState = { stops: ['', ''], waypoints: [], osrm: true }

export default class NewDesign extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: initialTripState,
      subscription: null,
      car: null,
      driver: null,
      picker: null,
      cards: this.props.cards(),
      card_id: null,
      showWidget: false,
      bonus: null,
      currentLocation: null,
      inputDisabled: false,
      paymentButtonDisabled: false,
      scroll: true
    }
  }

  getLocation = () => {
    let component = this
    if (navigator.geolocation) {
      // e.target.classList.add('running')
      navigator.geolocation.getCurrentPosition((result) => {
        let geocoder = new google.maps.Geocoder()
        let location = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)
        geocoder.geocode( { 'location': location}, function(res, status) {
          if (status == 'OK') {
            let place = res[0]
            // component.setState({ address: `${place.address_components[1].long_name}, ${place.address_components[0].long_name}`, predictions: [], isValid: true, geocoded: true });
            if (!component.props.trip || [FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER].includes(component.props.trip.status)) {
              component.setAddress(`${place.address_components[1].long_name}, ${place.address_components[0].long_name}`, `${place.geometry.location.lat()},${place.geometry.location.lng()}`, 0);
            }
            component.setState({currentLocation: {location: `${place.geometry.location.lat()},${place.geometry.location.lng()}`,
                      address: `${place.address_components[1].long_name}, ${place.address_components[0].long_name}`,
                      favorite_address: true,
                      structured_formatting: { main_text: `${place.address_components[1].long_name}, ${place.address_components[0].long_name}`, secondary_text: i18n.address_input.location }}})

            // component.input.setCustomValidity('')
          } else {
            alert(status)
          }
        })
        // e.target.classList.remove('running')
      },
        (error) => {
          // e.target.classList.remove('running')
          switch(error.code) {
            case error.PERMISSION_DENIED :
              console.log(i18n.location.permission_denied);
              break;
            case error.TIMEOUT:
              alert(i18n.location.timeout);
              break;
            case error.POSITION_UNAVAILABLE :
              alert(i18n.location.position_unavailable);
              break;
            default:
              alert(error.message)
              break;
          }
        }
      )
    }
  }

  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
      return state
    })
    this.updateTrip()
    this.build()
  }

  addAddress = () => {
    this.setState(state => {
      state.trip.stops.push('');
    })
    setTimeout(() => { document.querySelector('fieldset:last-of-type input').focus() }, 100)
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

  removeAddress = (index) => {
    this.setState(state => {
      state.trip.stops.splice(index, 1);
      state.trip.waypoints.splice(index, 1);
      return state
    })
    this.updateTrip()
    this.build()
  }

  eraseAddress = (index) => {
    if (this.state.trip.stops[index] === '') return this.removeAddress(index)
    this.setState(state => {
      state.trip.stops[index] = '';
      state.trip.waypoints[index] = '';
      delete state.trip.path
      return state
    })
    this.updateTrip()
    this.build()
  }

  get isValid() {
    return (!this.state.trip.stops.includes('') && this.state.trip.stops.length > 1 && !this.state.trip.waypoints.includes(''))
  }

  build = (e) => {
    let params = {...this.state.trip, osrm: true}
    if (!this.isValid) return;
    axios.post('trips/new', {trip: params}).then((res) => {
      this.setState(state => {
        state.trip.path = res.data.path
        state.trip.cost = res.data.cost
        return state
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  createTrip = (e) => {
    this.setState({bonus: e.target.value, paymentButtonDisabled: true}, () => {
      this.create()
    })
  }

  create = (e) => {
    const { trip, card_id, comment, entrance } = this.state;
    let params = { ...trip, status: PENDING, card_id: card_id }
    if (this.state.bonus === 'true') params.bonus = this.state.bonus
    this.sendRequest(params)
  }

  cancel = (e, callback = false) => {
    if (!confirm(i18n.find_driver.confirm_cancel)) {
      if (callback) callback()
      return;
    }
    axios.patch(`trips/${this.state.trip.id}/cancel`).then((res) => {
      this.setState({ trip: initialTripState, cost: null, car: null, driver: null, paymentButtonDisabled: false })
      this.previewMapRef.cleanup();

      // delete this.state.trip.start_time
      this.unsubscribe()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  cancelDeclined = (e, callback = () => {}) => {
    delete this.state.trip.status
    this.unsubscribe()
  }

  retry = (e, callback = () => {}) => {
    axios.patch(`trips/${this.state.trip.id}/retry`).then((res) => {
      this.setState({ trip: { ...this.state.trip, status: PENDING } })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      callback()
    })
  }

  sendRequest = (params) => {
    axios({
      method: params.id ? 'put' : 'post',
      url: params.id ? `trips/${params.id}` : 'trips',
      data: { trip: params }
    }).then((res) => {
      this.setState({trip: res.data})
      this.updateTrip()
      if (!params.id) { this.subscribe(res.data) }
    }).catch((error) => {
      if (!error.response) return
      switch(error.response.status) {
        case 418:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
            this.retryPendingPayment()
          } else {
            this.setState({paymentButtonDisabled: false})
          }
          break
        case 406:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.trip_payment}`)) {
            this.setState({bonus: false})
            this.state.trip.bonus = false
            this.create()
          } else {
            this.setState({paymentButtonDisabled: false})
          }
          break
        default:
          alert(error.response.data.errors)
          break
      }
    })
  }

  sendRequestForUnpaidTrips = () => {
    axios.get('trips/unpaid_trips').then((res) => {
      if (res.data.trips.length === 0) return;
      let result = confirm(i18n.retry_payment.unpaid_trips)
      if (result) this.retryPayment()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  pickAddress = (i) => {
    if (this.state.picker !== null) return this.setState({picker: null, klass: ''})
    this.setState({picker: i, klass: 'pick'})
  }

  componentDidMount() {
    window.geolocate = this.getLocation
    if (this.state.currentLocation === null) {
      this.getLocation()
    }
    this.getTripThroughProps(this.props.trip)

    this.addShakeListener()

    const yandex_api_lang = YANDEX_LANG[this.props.language]

    this.includeScript(`https://api-maps.yandex.ru/2.1/?apikey=${YANDEX_API_KEY}&lang=${yandex_api_lang}`)
    setTimeout(this.sendRequestForUnpaidTrips, 3000)
  }

  componentDidUpdate() {
    // window.geolocate = this.getLocation
    this.addShakeListener()
  }

  includeScript = (url) => {
    const script = document.createElement('script')

    script.src = url
    script.async = true

    document.body.appendChild(script)
  }

  addShakeListener = () => {
    let listenerEnable = !this.props.trip || ![ON_THE_WAY, WAITING_CLIENT, DRIVING].includes(this.props.trip.status)

    if (listenerEnable && !myShakeEvent) {
      myShakeEvent = new Shake({threshold: 20, timeout: 2000})
      myShakeEvent.start()
      window.addEventListener('shake', this.shakeEvent, {once: true})
    }
  }

  componentWillUnmount() {
    if (myShakeEvent) myShakeEvent.stop()
    window.removeEventListener('shake', this.shakeEvent)

    this.unsubscribe()
  }

  componentWillReceiveProps(props) {
    if (!props.trip && typeof google !== "undefined") {
      this.getLocation()
    }
    this.getTripThroughProps(props.trip)
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
      navigator.geolocation.getCurrentPosition((result) => {
        let geocoder = new google.maps.Geocoder()
        let location = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)

        geocoder.geocode( { 'location': location }, (res, status) => {
          if (status == 'OK') this.setTripParams(res)
        })
      },
        (error) => {
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

    this.trip = {
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
    axios.post('trips', {trip: this.state.trip}).then((res) => {
      this.setState({trip: res.data})
      this.subscribe(res.data)
    }).catch((error) => {
      if (!error.response) return
      if (error.response.status == 418) {
        if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
          this.retryPendingPayment(false)
        }
      } else alert(error.response.data.errors)
    })
  }

  retryPendingPayment = (unpaid_trip) => {
    const { cards } = this.props
    const { card_id } = this.state

    axios.post('payments/retry_pendings', {card_id: card_id ? card_id : cards()[0].id}).then((res) => {
      if (res.data.length === 0) {
        if (unpaid_trip) {
          this.setState({paymentButtonDisabled: false})
          return;
        }
        this.sendCreateRequest()
      } else {
        this.setState({paymentButtonDisabled: false})
        setTimeout(() => {alert(i18n.confirm_trip.payment_error)}, 500)
      }
    }).catch((error) => {
      this.setState({paymentButtonDisabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }

  retryPayment = () => {
    const { cards } = this.props
    const { card_id } = this.state

    axios.post('payments/retry_pendings', {card_id: card_id ? card_id : cards()[0].id}).then((res) => {
      if (res.data.length === 0) {
        alert(i18n.retry_payment.success)
      } else {
        alert(i18n.confirm_trip.payment_error)
      }
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  getTripThroughProps = (propsTrip) => {
    if (!propsTrip) return;
    let trip = {}
    TRIP_FIELDS.map(f => trip[f] = propsTrip[f] )
    const car = { location: propsTrip.car_location, color: propsTrip.car_color, number: propsTrip.car_number, position: propsTrip.car_position }
    const driver = { name: propsTrip.driver_name, phone_number: propsTrip.car_phone_number }
    if (propsTrip.car_location) {
      this.setState({ trip: trip, car: car, driver: driver })
    } else {
      this.setState({ trip: trip, car: null, driver: null })
    }
    this.updateTrip()
    this.subscribe()
  }

  scroll = val => {
    this.fields.scrollTo({left: this.fields.scrollWidth/val, behavior: 'smooth'})
  }

  confirmUpdate = (e) => {
    let params = { ...this.state.trip, osrm: true }
    this.sendRequest(params)
  }

  updateRoute = (e) => {
    this.setState({ trip: { ...this.state.trip, status: CONFIRM_UPDATE_TRIP }, inputDisabled: true })
    if (window.ios) return;
    history.pushState(null, null,'/')
    window.addEventListener('popstate', this.cancelConfirmUpdate, { once: true })
  }

  cancelConfirmUpdate = (e) => {
    window.removeEventListener('popstate', this.cancelConfirmUpdate, true);
    this.props.fetchUser();
  }

  handleBackEdit = (e) => {
    window.ios ? this.props.fetchUser() : window.history.back()
  }

  setField = (e) => {
    this.state.trip[e.target.id] = (e.target.id !== 'no_call') ? e.target.value : e.target.checked
    this.setState(this.state);
  }

  setTime = (e) => {
    if (e.target.value === '') return this.setField(e)
    let now = new Date
    let time = new Date(`${now.toDateString()} ${e.target.value}`)
    let range = (time.getTime() - now.getTime())/60000

    if (range <= -1) alert(i18n.current_trip.tomorrow)
    if (range <= 15 && range > -1) {
      e.target.value = ''
      e.target.blur()
      alert(i18n.current_trip.preorder)
    }
    this.setField(e)
  }

  subscribe = (trip = this.state.trip) => {
    if ([FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, undefined].includes(trip.status)) return;
    if (this.state.subscription) return this.state.subscription
    let component = this
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: trip.id },
      {
        received: data => {
          component[data['action'] || data['body']['action']](data)
        }
      }
    )})
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({ subscription: null })
  }

  TripAccepted = (data) => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: ON_THE_WAY, start_time: data.trip.start_time },
                    car: { location: data.trip.car_location ,color: data.trip.car_color, number: data.trip.car_number },
                    driver: { name: data.trip.driver_name, phone_number: data.trip.car_phone_number } })
  }

  TripDeclined = (data) => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: DECLINED } })
  }

  TripUnavailable = (data) => {
    this.unsubscribe()
    const status = data.by_driver ? CANCELED_BY_DRIVER : CANCELED
    this.setState({ trip: { ...this.state.trip, status } })
    if (data.by_driver) alert(i18n.trip.canceled)
  }

  TripUpdated = (data) => {
    this.setState({ trip: JSON.parse(data.data) })
  }

  DriverLocationUpdated = (data) => {
    this.setState({ car: { ...this.state.car, location: [data.body.location.longitude, data.body.location.latitude] } })
  }

  finish_trip = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: FINISHED }, car: null, driver: null, paymentButtonDisabled: false, inputDisabled: false })
    // this.props.fetchUser()
    this.unsubscribe()
  }

  waiting_client = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: WAITING_CLIENT }})
  }

  start_trip = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: DRIVING }})
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  createCard = (data) => {
    this.props.createCard(data)
    this.setState({showWidget: false})
  }

  showWidgetTrue = () => {
    this.setState({showWidget: true})
  }

  scrollChange = (value) => {
    this.setState({scroll: value})
  }

  renderFields(trip, isValid, cards) {

    return(
      <div id='fields' class='options' ref={fields => this.fields = fields}>
        <button class='trigger' onClick={ () => this.scroll(1) }>
          <Arrows width='50'/>
        </button>
        <button class='trigger back' onClick={ () => this.scroll(1000) }>
          <Arrows width='50'/>
        </button>
        <div class={this.state.scroll ? 'option scroll' : 'option'}>
          { trip.stops.map((e, i) => {
            return (
              <AddressInput setAddress={this.setAddress}
                            eraseAddress={this.eraseAddress}
                            favorite_addresses={this.props.favorite_addresses}
                            language={this.props.language}
                            coords={trip.waypoints[i]}
                            readonly={ ![CONFIRM_UPDATE_TRIP, CANCELED, CANCELED_BY_DRIVER, undefined].includes(trip.status) && i == 0 }
                            address={e}
                            index={i}
                            fieldsCount={trip.stops.length}
                            pickAddress={this.pickAddress}
                            currentLocation={this.state.currentLocation}
                            scrollChange={this.scrollChange}
                            inputDisabled={this.state.inputDisabled}/>
            )
          })}
          <div>
            <button type='button' onClick={this.addAddress} class='add-address' disabled={isValid} title={ i18n.current_trip.add_address }>
              <Add height='40'/>
            </button>
          </div>
        </div>
        <div class={this.state.scroll ? 'option scroll' : 'option'}>
          <div class='additions'>
            <label for='no_call' class='nocall'>
              <input id='no_call' type='checkbox' checked={trip.no_call} onChange={this.setField}/>
              <Phone width='24' class='cross'/>
              {i18n.current_trip.no_call}
            </label>
            <label for='entrance'>
              <Entrance height='27'/>
              <select id='entrance' value={trip.entrance} onChange={this.setField}>
                <option value=''>{i18n.current_trip.select_entrance}</option>
                {ENTRANCES.map((el) => {
                  return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
                })}
              </select>
            </label>
            <label for='time' data-placeholder={!trip.time}>
              <Clock width='24' fill='#312d50'/>
              <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]' value={trip.time} placeholder='Now' onBlur={this.setTime}/>
              <span class='time-placeholder'>{i18n.current_trip.now}</span>
            </label>{' '}
            <label class='select' for='card'>
              <Card width='24'/>
              <select id='card' onChange={(e) => this.selectCard(e)}>
                {cards.map(card => <option value={card.id}>{card.pan}</option>)}
              </select>
            </label>
          </div>
          <label for='comment'>
            <Comment width='24'/>
            <input id='comment' type='text' class='comment' value={trip.comment} placeholder={i18n.current_trip.comment} onChange={this.setField}/>
          </label>
        </div>
      </div>
    )
  }

  renderLoading() {
    return (
      <div>
        <div className="driverSearch">
          {`${i18n.trip.driver_search}`}
        </div>
        <div className="loaderWrapper">
          <SearchLogo className="search_logo" />
        </div>
      </div>
    )
  }

  resetTrip = () => {
    this.props.setActivateFeedback()
    this.setState({ trip: { stops: ['', ''], waypoints: [], osrm: true }, car: null, driver: null })
  }

  render() {
    const { activateFeedback, lastTripId } = this.props
    const showWidget = this.state.showWidget
    const trip = this.state.trip
    const cards = this.props.cards()
    let isValid = trip.stops.includes('')
    let cost = (trip.cost) ? `${trip.cost}` : ''

    return (
      <div>
        <header></header>
        <section class={`new_design ${this.state.klass}`}>
          { (activateFeedback || trip.status == FINISHED) && <Feedback trip={trip} updateTrip={this.resetTrip} handleBack={this.resetTrip} lastTripId={lastTripId} /> }
          <style>{`fieldset.address:nth-child(${this.state.picker + 1}) { opacity: 1;}`}</style>
          <PreviewMap trip={() => trip}
            car={this.state.car}
            driver={this.state.driver}
            isValid={this.isValid}
            language={this.props.language}
            picker={this.state.picker}
            setAddress={this.setAddress}
            zoom={this.state.zoom}
            ref={(el) => this.previewMapRef = el}/>
          <div class='wrapper'>
            { [CONFIRM_UPDATE_TRIP, CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) && this.renderFields(trip, isValid, cards) }
            { [PENDING].includes(trip.status) && this.renderLoading() }
          </div>
          <Buttons trip={trip}
            isValid={this.isValid}
            cost={cost}
            bonusTrips={this.props.bonus_trips()}
            createTrip={this.createTrip}
            updateRoute={this.updateRoute}
            confirmUpdate={this.confirmUpdate}
            handleBackEdit={this.handleBackEdit}
            cancel={this.cancel}
            retry={this.retry}
            cancelDeclined={this.cancelDeclined}
            picker={this.state.picker}
            pickAddress={this.pickAddress}
            showWidget={this.showWidget}
            showWidgetTrue={this.showWidgetTrue}
            cards={cards}
            paymentButtonDisabled={this.state.paymentButtonDisabled}/>
          { showWidget && <Widget createCard={this.createCard} showWidget={() => this.setState({showWidget: false}) }/> }
        </section>
      </div>
    )
  }
}
