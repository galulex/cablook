import { h, render, Component } from 'preact'
import axios from 'axios'
import { createConsumer } from '@rails/actioncable'

import i18n from './i18n.js'
import './css/map.css'
import PreviewMap from './map/preview_map.js'
import Buttons from './new_design/buttons.js'
import AddressInput from '../pwa/trips/address-input.js'
import Feedback from '../pwa/feedback.js'
import Add from './images/plus.js'
import Widget from './widget.js'
import Entrance from './images/entrance.svg'
import Clock from './images/clock.svg'
import Card from './images/credit-cards-payment.js'
import Hrivna from './images/ukraine-hryvna.js'
import { geocode } from '../pwa/geolocation.js'
import Phone from './images/phone_crossed.js'
import Comment from './images/contacts.svg'
import Chevron from './images/chevron.js'
import SearchLogo from './images/search_logo.svg'
import './css/new_design.css'
import './lib/dndpoly.js'
import { isAllowedFeature } from './lib/featureFlag.js'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, PAY_TYPE } from './lib/constants.js'

const cable = createConsumer()
const ENTRANCES = Array.from({ length: 15 }, (v, k) => (k + 1))
const TRIP_FIELDS = ['departure', 'departure_address', 'destination', 'destination_address', 'path', 'status', 'id', 'stops', 'waypoints', 'cost', 'distance', 'duration', 'start_time', 'card_id', 'bonus', 'osrm', 'accepted_at', 'with_cashback']

const Shake = require('shake.js')
let myShakeEvent = false
let fetchTripTimeout
let interval

export default class NewDesign extends Component {
  constructor(props) {
    super(props)

    this.state = {
      trip: this.initialTripState,
      subscription: null,
      car: null,
      driver: null,
      picker: null,
      cards: this.props.cards(),
      showWidget: false,
      bonus: null,
      cashback: null,
      currentLocation: null,
      inputDisabled: false,
      activateFeedback: false,
      lastTripId: null,
      buttonDisabled: false,
      cancelTimer: null,
      klass: '',
      settings: {},
      showLoading: false
    }
    this.draggedPrevValue = null
    this.draggedValue = null
    this.draggedInput = null
  }

  get initialTripState() {
    return {
      stops: ['', ''], waypoints: [], osrm: true
    }
  }

  componentDidMount() {
    this.fetchSettings()
    this.props.fetchUser().then(() => { this.startCountdown() })

    this.loadTrips()

    this.addShakeListener()

    setTimeout(this.sendRequestForUnpaidPayments, 3000)
    if (this.props.showFeedback()) { this.props.showBurger(false) }
  }

  componentDidUpdate() {
    if (!this.state.currentLocation && this.props.currentLocation && this.state.trip.stops[0] === '') {
      this.setAddress(this.props.currentLocation.address, this.props.currentLocation.location, 0)
      this.setState({
        currentLocation: {
          location: this.props.currentLocation.location,
          address: this.props.currentLocation.address,
          favorite_address: true,
          structured_formatting: {
            main_text: this.props.currentLocation.address,
            secondary_text: i18n.address_input.location
          }
        }
      })
    }
    this.addShakeListener()
  }

  fetchSettings = () => {
    axios.get('settings').then(({ data }) => this.setState({ settings: data }))
  }

  loadTrips = () => {
    axios.get(`trips?page=0&per=1`).then((res) => {
      const { trips } = res.data
      this.setState({ lastTripId: trips[0].id })
      this.props.setActivateFeedback(trips[0].feedbacks[0] == undefined && [FINISHED].includes(trips[0].status))
    }).catch((error) => {
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
    this.build()
  }

  addAddress = () => {
    this.setState(state => {
      state.trip.stops.push('')
      return state
    }, () => {
      const draggables = document.querySelectorAll('div.draggable')
      const lastDraggable = document.querySelectorAll('div.draggable')[draggables.length - 1]
      lastDraggable.querySelector('input.address').focus()
    })
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
    let params = { ...this.state.trip, osrm: true }
    if (!this.isValid) return
    axios.post('trips/new', { trip: params }).then((res) => {
      this.setState(state => {
        state.trip.path = res.data.path
        state.trip.cost = res.data.cost
        return state
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  createTrip = (e, cashback = false) => {
    const message = this.state.settings.before_create_trip_message

    if (message) { if (confirm(message) === false) return }

    this.setState({ bonus: e.target.value, buttonDisabled: true, cashback: cashback }, () => {
      this.create()
    })
  }

  setFetchTripTimeout = () => {
    fetchTripTimeout = setTimeout(this.props.fetchUser, 76000)
  }

  clearFetchTripTimeout = () => {
    this.setState({ buttonDisabled: false })
    clearTimeout(fetchTripTimeout)
  }

  create = (e) => {
    const { trip, comment, entrance, settings } = this.state
    let params = { ...trip, status: PENDING, cash: settings.cash && !localStorage.getItem(PAY_TYPE) }
    if (this.state.bonus === 'true') params.bonus = bonus
    if (this.state.cashback) params.cashback = this.state.cashback
    this.sendRequest(params)
  }

  cancel = (e, callback = false) => {
    if (!confirm(i18n.find_driver.confirm_cancel)) {
      if (callback) callback()
      return
    }
    this.setState({ buttonDisabled: true })
    axios.patch(`trips/${this.state.trip.id}/cancel`).then((res) => {
      this.clearTrip()
      this.clearCountdown()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      this.setState({ buttonDisabled: false })
    })
  }

  clearTrip = () => {
    this.setState({ trip: this.initialTripState, cost: null, car: null, driver: null, buttonDisabled: false, showLoading: false })
    this.previewMapRef.cleanup()
    this.unsubscribe()
    this.clearFetchTripTimeout()
  }

  cancelDeclined = (e, callback = () => { }) => {
    this.setState({ buttonDisabled: true })
    axios.patch(`trips/${this.state.trip.id}/cancel`).then((res) => {
      this.clearTrip()
      this.setState({ buttonDisabled: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      this.setState({ buttonDisabled: false })
    })
  }

  retry = (e, callback = () => { }) => {
    this.setState({ buttonDisabled: true })

    axios.patch(`trips/${this.state.trip.id}/retry`).then((res) => {
      this.setState({ trip: { ...this.state.trip, status: PENDING } })
      this.setFetchTripTimeout()
      this.setState({ buttonDisabled: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      this.setState({ buttonDisabled: false })
      callback()
    })
  }

  sendRequest = (params) => {
    this.setState({ showLoading: true })
    this.setState({ buttonDisabled: true })
    axios({
      method: params.id ? 'put' : 'post',
      url: params.id ? `trips/${params.id}` : 'trips',
      data: { trip: params }
    }).then((res) => {
      this.setState({ trip: res.data })
      this.updateTrip()
      if (!params.id) { this.subscribe(res.data) }
      this.setFetchTripTimeout()
      this.setState({ buttonDisabled: false })
    }).catch((error) => {
      this.setState({ buttonDisabled: false })
      this.setState({ showLoading: false })
      if (!error.response) return
      switch (error.response.status) {
        case 418:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
            this.retryPendingPayment()
          }
          break
        case 406:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.trip_payment}`)) {
            this.setState({ bonus: false })
            this.state.trip.bonus = false
            this.create()
          }
          break
        case 402:
          alert(error.response.data.errors)
          break
        case 422:
        default:
          alert(error.response.data.errors)
          break
      }
    })
  }

  sendRequestForUnpaidPayments = () => {
    if (this.state.settings.validate_unpaid_trips === false) return

    axios.get('payments/pending').then((res) => {
      if (res.data.length === 0) return
      let result = confirm(i18n.retry_payment.unpaid_payments)
      if (result) this.retryPayment()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  pickAddress = (i) => {
    if (this.state.picker !== null) return this.setState({ picker: null, klass: '' })
    this.setState({ picker: i, klass: 'pick' })
  }

  addShakeListener = () => {
    let listenerEnable = !this.props.trip || ![ON_THE_WAY, WAITING_CLIENT, DRIVING].includes(this.props.trip.status)

    if (listenerEnable && !myShakeEvent) {
      myShakeEvent = new Shake({ threshold: 20, timeout: 2000 })
      myShakeEvent.start()
    }
    window.addEventListener('shake', this.shakeEvent, { once: true })
  }

  componentWillUnmount() {
    if (myShakeEvent) myShakeEvent.stop()
    window.removeEventListener('shake', this.shakeEvent)

    this.unsubscribe()
  }

  componentWillReceiveProps(props) {
    this.getTripThroughProps(props.trip)
  }

  shakeEvent = () => {
    const { trip } = this.state
    const { cards } = this.props

    if (trip && trip.id) {
      return (alert(i18n.trips.pending_trip_exists))
    } else if (cards().length < 1) {
      if (confirm(`${i18n.cards.no_cards}. ${i18n.cards.please_add}`)) return (route('/cards', true))
    } else { this.createShakeTrip() }
  }

  createShakeTrip = async () => {
    if (navigator.geolocation) {
      try {
        const res = await new Promise(function (resolve, reject) {
          navigator.geolocation.getCurrentPosition(resolve, reject);
        });

        let lat = res.coords.latitude;
        let lng = res.coords.longitude;
        let address = await geocode(`${lng},${lat}`)
        this.setTripParams(`${lat},${lng}`, address)
      } catch (error) {
        switch (error.code) {
          case error.PERMISSION_DENIED:
            console.log(i18n.location.permission_denied);
            break;
          case error.TIMEOUT:
            alert(i18n.location.timeout);
            break;
          case error.POSITION_UNAVAILABLE:
            console.log(i18n.location.position_unavailable);
            break;
          default:
            alert(error.message);
            break;
        }
      }
    } else alert(i18n.location.not_supported)
  }

  setTripParams = (coords, address) => {
    this.setAddress(address, coords, 0)
    this.setState({
      trip: {
        ...this.state.trip,
        departure: coords,
        destination: coords,
        departure_address: address,
        destination_address: address,
        waypoints: [coords, coords],
        stops: [address, address],
        osrm: true,
        bonus: false,
        comment: 'Швидка поїздка. Я зміню кінцеву точку після посадки.'
      }
    })
    this.sendCreateRequest()
  }

  sendCreateRequest = () => {
    axios.post('trips', { trip: this.state.trip }).then((res) => {
      this.setState({ trip: res.data })
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
    const { card_id } = this.state.trip

    axios.post('payments/retry_pendings', { card_id: card_id ? card_id : cards()[0].id }).then((res) => {
      if (res.data.length === 0) {
        if (unpaid_trip) {
          this.setState({ buttonDisabled: false })
          return
        }
        this.sendCreateRequest()
      } else {
        this.setState({ buttonDisabled: false })
        setTimeout(() => { alert(i18n.confirm_trip.payment_error) }, 500)
      }
    }).catch((error) => {
      this.setState({ buttonDisabled: false })
      if (error.response) alert(error.response.data.errors)
    })
  }

  retryPayment = () => {
    const { cards } = this.props
    const { card_id } = this.state.trip

    axios.post('payments/retry_pendings', { card_id: card_id ? card_id : cards()[0].id }).then((res) => {
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
    let trip = {}
    if (!propsTrip) {
      trip = this.state.trip
      if (trip.status !== PENDING) return
      this.setState({ trip: { ...trip, status: DECLINED } })
      return
    }
    TRIP_FIELDS.map(f => trip[f] = propsTrip[f])
    if (propsTrip.car_location && trip.status !== PENDING) {
      const car = { location: propsTrip.car_location, color: propsTrip.car_color, number: propsTrip.car_number, position: propsTrip.car_position, deg: propsTrip.car.deg, brand: propsTrip.car.brand, model: propsTrip.car.model }
      const driver = { name: propsTrip.driver_name, phone_number: propsTrip.car_phone_number }

      this.setState({ trip: trip, car: car, driver: driver })
    } else {
      this.setState({ trip: trip, car: null, driver: null })
    }
    this.updateTrip()
    this.subscribe()
  }

  fetchBonusTrips = () => {
    axios.get('/referrals').then((res) => {
      let data = res.data
      data.availableBonusTrips = this.props.getAvailableBonusTrips(data.bonus_trips)
      this.props.setBonusTrips(data)
    })
  }

  scroll = val => {
    this.fields.scrollTo({ left: this.fields.scrollWidth / val, behavior: 'smooth' })
  }

  confirmUpdate = (e) => {
    const { trip } = this.state
    let params = { ...trip, osrm: true }
    if (trip.bonus && trip.with_cashback && (trip.cost > this.props.cashbackAmount)) {
      if (!confirm(i18n.confirm_trip.insufficient_cashback)) return
      delete params.bonus
    }
    this.props.mainBurger.classList.remove('hidden')
    this.setState({ buttonDisabled: false })
    this.sendRequest(params)
  }

  updateRoute = (e) => {
    this.props.mainBurger.classList.add('hidden')
    this.setState({ trip: { ...this.state.trip, status: CONFIRM_UPDATE_TRIP }, inputDisabled: true })
    if (window.ios) return
    history.pushState(null, null, '/')
    window.addEventListener('popstate', this.cancelConfirmUpdate, { once: true, passive: true })
  }

  cancelConfirmUpdate = (e) => {
    this.props.mainBurger.classList.remove('hidden')
    window.removeEventListener('popstate', this.cancelConfirmUpdate, { passive: true })
    this.props.fetchUser()
  }


  setField = (e) => {
    this.state.trip[e.target.id] = (e.target.id !== 'no_call') ? e.target.value : e.target.checked
    this.setState(this.state)
  }

  clearCountdown = () => {
    clearInterval(interval)
    this.setState({ cancelTimer: null })
  }

  checkAcceptionTime = (cancelTimer) => {
    return cancelTimer < 120
  }

  startCountdown = () => {
    if (this.state.trip.status !== ON_THE_WAY) return
    this.countdown()
    interval = setInterval(this.countdown, 1000)
  }

  countdown = () => {
    const { trip } = this.state
    if (!trip.accepted_at) return
    let current = new Date().getTime()
    let accepted_at = new Date(trip.accepted_at).getTime()
    let cancelTimer = 120 - Math.floor((current - accepted_at) / 1000)
    if (!this.checkAcceptionTime(cancelTimer)) return
    this.setState({ cancelTimer }, () => {
      if (cancelTimer < 1) this.clearCountdown()
    })
  }

  setTime = (e) => {
    if (e.target.value === '') return this.setField(e)
    let now = new Date
    let time = new Date(`${now.toDateString()} ${e.target.value}`)
    let range = (time.getTime() - now.getTime()) / 60000

    if (range <= -1) alert(i18n.current_trip.tomorrow)
    if (range <= 30 && range > -1) {
      e.target.value = ''
      e.target.blur()
      alert(i18n.current_trip.preorder)
    }
    this.setField(e)
  }

  subscribe = (trip = this.state.trip) => {
    if ([FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, undefined].includes(trip.status)) return
    if (this.state.subscription) return this.state.subscription
    let component = this
    this.setState({
      subscription: cable.subscriptions.create(
        { channel: 'TripChannel', trip_id: trip.id },
        {
          received: data => {
            component[data['action'] || data['body']['action']](data)
          }
        }
      )
    })
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({ subscription: null })
  }

  NotifyDriver = (data) => { }

  NotificationRetry = (data) => { this.retry() }

  NotificationCancel = (data) => { this.clearTrip() }

  TripUnrelease = (data) => {
    this.vibrate()
    this.previewMapRef.cleanup()
    this.setState({ trip: { ...this.state.trip, status: PENDING }, showLoading: true, car: null })
    this.clearFetchTripTimeout()
  }

  TripAccepted = (data) => {
    this.previewMapRef.cleanup()
    this.vibrate()
    this.setState({
      trip: { ...this.state.trip, status: ON_THE_WAY, start_time: data.trip.start_time, accepted_at: data.trip.accepted_at, with_cashback: data.trip.with_cashback },
      car: { location: data.trip.car_location, color: data.trip.car_color, number: data.trip.car_number, deg: data.trip.car.deg, brand: data.trip.car.brand, model: data.trip.car.model },
      driver: { name: data.trip.driver_name, phone_number: data.trip.car_phone_number },
      showLoading: false
    }, () => this.startCountdown())
    this.clearFetchTripTimeout()
  }

  TripDeclined = (data) => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: DECLINED }, showLoading: false })
    this.clearFetchTripTimeout()
  }

  TripUnavailable = (data) => {
    const status = data.by_driver ? CANCELED_BY_DRIVER : CANCELED
    this.setState({ trip: { ...this.initialTripState, status }, car: null, driver: null, buttonDisabled: false, inputDisabled: false, showLoading: false })
    this.previewMapRef.cleanup()
    this.unsubscribe()
    this.clearFetchTripTimeout()
    this.clearCountdown()
    if (data.by_driver) alert(i18n.trip.canceled)
  }

  TripUpdated = (data) => {
    this.setState({ trip: JSON.parse(data.data), showLoading: false })
  }

  DriverLocationUpdated = (data) => {
    if ([CONFIRM_UPDATE_TRIP].includes(this.state.trip.status)) return
    const position = [data.body.location.longitude, data.body.location.latitude]
    this.setState({ car: { ...this.state.car, location: position, position: position } })
  }

  finish_trip = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: FINISHED }, car: null, driver: null, buttonDisabled: false, inputDisabled: false })
    // this.props.fetchUser()
    this.props.resetCurrentTrip()
    this.props.setActivateFeedback(true)
    this.unsubscribe()
    if (this.state.trip.bonus) this.fetchBonusTrips()
    this.props.fetchUser()
  }

  waiting_client = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: WAITING_CLIENT } })
    this.clearCountdown()
  }

  start_trip = () => {
    this.vibrate()
    this.setState({ trip: { ...this.state.trip, status: DRIVING } })
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  showWidgetTrue = () => {
    this.setState({ showWidget: true })
  }

  dragStart = (e) => {
    this.draggedInput = e.target.getElementsByTagName('input')[0]
    if (this.draggedInput) this.draggedPrevValue = this.draggedInput.value
    if (!this.draggedPrevValue || this.state.trip.stops.indexOf(this.draggedPrevValue) < 0) return e.preventDefault()
  }

  dragOver = (e) => {
    e.preventDefault()
    if (e.target.tagName !== 'INPUT' || !e.target.value) return

    if (e.target.value && this.draggedInput) {
      this.draggedInput.value = e.target.value
      const item = e.target.parentNode.parentNode
      item.style.padding = '0.5vh 0'
      item.style.opacity = '0.1'
      setTimeout(() => item.style = '', 500)
      this.draggedValue = e.target.value
    }
  }

  dragLeave = (e) => {
    e.preventDefault()
    e.target.parentNode.parentNode.style = ''
    if (this.draggedPrevValue && this.draggedInput) this.draggedInput.value = this.draggedPrevValue
  }

  dragEnd = (e) => {
    e.preventDefault()
    this.setState((state) => {
      const prevIndex = state.trip.stops.indexOf(this.draggedPrevValue)
      const curIndex = state.trip.stops.indexOf(this.draggedValue)
      const waypoint = state.trip.waypoints[curIndex]

      state.trip.stops.splice(curIndex, 1, this.draggedPrevValue)
      state.trip.stops.splice(prevIndex, 1, this.draggedValue)
      state.trip.waypoints.splice(curIndex, 1, state.trip.waypoints[prevIndex])
      state.trip.waypoints.splice(prevIndex, 1, waypoint)
      return state
    })

    this.previewMapRef.cleanup()
    this.updateTrip()
    this.build()
  }

  onCardSelect = (e) => {
    if (e.target.value < 0) return this.setState({ showWidget: true, inputDisabled: true })
    this.setState({ trip: { ...this.state.trip, card_id: e.target.value } })
    localStorage.setItem(PAY_TYPE, e.target.value)
  }

  renderCardSelect = (cards, trip) => {
    let lastCardId = null
    if (!this.state.settings.cash && cards.length > 0) {
      lastCardId = cards[cards.length - 1].id
      localStorage.setItem(PAY_TYPE, lastCardId)
    }
    const value = this.state.settings.cash ? localStorage.getItem(PAY_TYPE) : lastCardId
    const cashOption = <option selected={false}>{i18n.trip.cash}</option>
    const cardsItems = cards.map(card => <option selected={value == card.id} value={card.id}>{card.pan}</option>)
    const addCardOption = cardsItems.length == 0 ? <option value={-1}>{i18n.cards.add}</option> : null

    return (
      <label className='select' htmlFor='card_id'>
        {value ? <Card width='24' /> : <Hrivna width='44' />}
        <select id='card_id' disabled={this.state.inputDisabled} onChange={this.onCardSelect} value={value}>
          {this.state.settings.cash ? [cashOption, addCardOption].concat(cardsItems) : cardsItems}
        </select>
      </label>
    )
  }

  renderFields(trip, isValid, cards) {
    return (
      <div id='fields' class='options' ref={fields => this.fields = fields}>
        <button class='trigger' onClick={() => this.scroll(1)}>
          <Chevron class='chevron' height='50' />
        </button>
        <button class='trigger back' onClick={() => this.scroll(1000)}>
          <Chevron class='chevron' height='50' />
        </button>
        <div class='option'>
          {trip.stops.map((e, i) => {
            return (
              <div className='draggable'
                draggable={isAllowedFeature}
                onDragStart={this.dragStart}
                onDragOver={this.dragOver}
                onDragLeave={this.dragLeave}
                onDragEnd={this.dragEnd}
              >
                <AddressInput setAddress={this.setAddress}
                  eraseAddress={this.eraseAddress}
                  favorite_addresses={() => this.props.favorite_addresses()}
                  language={this.props.language}
                  coords={trip.waypoints[i]}
                  readonly={![CONFIRM_UPDATE_TRIP, CANCELED, CANCELED_BY_DRIVER, undefined].includes(trip.status) && i == 0}
                  address={e}
                  index={i}
                  fieldsCount={trip.stops.length}
                  pickAddress={this.pickAddress}
                  currentLocation={this.state.currentLocation}
                  inputDisabled={this.state.inputDisabled}
                  isGeocoding={this.props.isGeocoding}
                  setGeocoding={this.props.setGeocoding} />
              </div>
            )
          })}
          <div class="button-line-wrapper">
            <button type='button' onClick={this.addAddress} class='button add-address' disabled={isValid} title={i18n.current_trip.add_address}>
              <Add height='15' />
            </button>
          </div>
        </div>
        <div class='option'>
          <div className='trip-params'>
            <div className='additions'>
              <label htmlFor='no_call' className='nocall'>
                <input id='no_call' type='checkbox' checked={trip.no_call} onChange={this.setField} />
                <Phone width='24' class='cross' />
                {i18n.current_trip.no_call}
              </label>
              <label htmlFor='entrance'>
                <Entrance height='15' />
                <select id='entrance' value={trip.entrance} onChange={this.setField}>
                  <option value=''>{i18n.current_trip.select_entrance}</option>
                  {ENTRANCES.map((el) => {
                    return (<option value={el}>{el} {i18n.current_trip.entrance}</option>)
                  })}
                </select>
              </label>
              <label htmlFor='time' data-placeholder={!trip.time}>
                <Clock width='24' fill='#312d50' />
                <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]'
                  value={trip.time} placeholder='Now' onBlur={this.setTime} />
                <span className='time-placeholder'>{i18n.current_trip.now}</span>
              </label>{' '}
              {this.renderCardSelect(cards, trip)}
            </div>
            <label htmlFor='comment'>
              {/*<Comment width='24'/>*/}
              <input id='comment' type='text' className='comment' value={trip.comment}
                placeholder={i18n.current_trip.comment} onChange={this.setField} />
            </label>
          </div>
        </div>
      </div>
    )
  }

  renderLoading() {
    return (
      <div>
        <div className="driverSearch">
          {[PENDING].includes(this.state.trip.status) && `${i18n.trip.driver_search}`}
        </div>
        <div className="loaderWrapper">
          <SearchLogo className="search_logo" />
        </div>
      </div>
    )
  }

  isShowLoading = () => [PENDING].includes(this.state.trip.status) || this.state.showLoading

  clearPicker = () => {
    this.setState({ picker: null, klass: '' })
  }

  resetTrip = () => {
    this.props.setActivateFeedback()
    this.setState({ trip: this.initialTripState, car: null, driver: null })
  }

  render() {
    const { lastTripId, showWidget, trip,
      buttonDisabled, car, driver,
      picker, cancelTimer } = this.state
    const { language, isGeocoding, setGeocoding,
      showFeedback, availableBonusTrips, cashbackAmount } = this.props
    const cards = this.props.cards()
    let isValid = trip.stops.includes('')
    let cost = (trip.cost) ? `${trip.cost}` : ''

    return (
      <div class='general__holder'>
        <header></header>
        <section class={`new_design ${this.state.klass} ${this.isShowLoading() ? 'background' : ''}`}>
          {this.props.showFeedback() && <Feedback trip={trip} updateTrip={this.resetTrip} handleBack={this.resetTrip} lastTripId={lastTripId} />}
          <style>{`fieldset.address:nth-child(${this.state.picker + 1}) { opacity: 1;}`}</style>
          <PreviewMap
            trip={() => trip}
            car={car}
            driver={driver}
            isValid={this.isValid}
            language={language}
            picker={picker}
            setAddress={this.setAddress}
            isGeocoding={isGeocoding}
            setGeocoding={setGeocoding}
            pickAddress={this.pickAddress}
            mainBurger={this.props.mainBurger}
            clearPicker={this.clearPicker}
            fetchUser={this.props.fetchUser}
            ref={(el) => this.previewMapRef = el}
          />
          {!this.props.showFeedback() &&
            <div class='wrapper'>
              {this.isShowLoading() ?
                this.renderLoading()
                :
                [CONFIRM_UPDATE_TRIP, CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) && this.renderFields(trip, isValid, cards)
              }
            </div>
          }
          <Buttons trip={trip}
            isValid={this.isValid}
            cost={cost}
            bonusTrips={this.props.bonus_trips()}
            createTrip={this.createTrip}
            updateRoute={this.updateRoute}
            confirmUpdate={this.confirmUpdate}
            cancel={this.cancel}
            retry={this.retry}
            cancelDeclined={this.cancelDeclined}
            picker={picker}
            isGeocoding={isGeocoding}
            showWidget={this.showWidget}
            showWidgetTrue={this.showWidgetTrue}
            cards={cards}
            buttonDisabled={buttonDisabled}
            cancelTimer={cancelTimer}
            showFeedback={showFeedback}
            cashbackAmount={cashbackAmount}
            availableBonusTrips={availableBonusTrips}
            cash={this.state.settings.cash} />
          {showWidget && <Widget paymentSystem={this.props.paymentSystem} updateCards={this.props.updateCards} showWidget={() => this.setState({ showWidget: false })} />}
        </section>
      </div>
    )
  }
}
