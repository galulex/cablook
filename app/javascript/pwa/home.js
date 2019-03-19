import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import CurrentTrip from './current-trip.js'
import ConfirmTrip from './confirm_trip.js'
import FindDriver from './find_driver.js'
import RetryTrip from './retry_trip.js'
import Trip from './trip.js'
import Feedback from '../pwa/feedback.js';

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()

export default class Home extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: JSON.parse(localStorage.getItem('trip')),
      subscription: null,
      car_location: []
    }
  }

  componentDidMount() {
    if (!!this.state.trip) this.subscribe()
    this.getTrip()
    if (window.Notification) Notification.requestPermission()
    document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') this.getTrip() }, false);
    window.addEventListener('online', this.getTrip)
    setInterval(this.getTrip, 70000)
  }

  componentWillUnmount() {
    this.unsubscribe()
    window.removeEventListener('online', this.getTrip)
  }

  subscribe = () => {
    if (!this.state.trip.id) return;
    if (this.state.subscription) return this.state.subscription
    let component = this
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: this.state.trip.id },
      {
        received: data => {
          component[data['action'] || data['body']['action']](data)
        }
      }
    )})
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({subscription: null})
  }

  updateTrip = (trip) => {
    localStorage.setItem('trip', JSON.stringify(trip))
    this.setState({trip: trip})
  }

  TripDeclined = (data) => {
    if (document.visibilityState !== 'hidden') {
      this.vibrate()
      this.getTrip()
      return
    }
    this.notify(this.declineData())
  }

  notify = (data) => {
    navigator.serviceWorker.getRegistrations().then(registrations => {
      registrations[0].showNotification('CabLook', data)
    })
  }

  TripAccepted = (data) => {
    this.vibrate()
    this.updateTrip(data.trip)
    if (document.visibilityState == 'hidden') this.notify(this.acceptData())
  }

  TripUnavailable = (data) => {
    this.unsubscribe()
    this.updateTrip(null)
    if (data.by_driver) alert(i18n.trip.canceled)
  }

  DriverLocationUpdated = (data) => {
    this.setState({car_location: [data.body.location.longitude, data.body.location.latitude]})
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  finish_trip = (data) => {
    this.vibrate()
    let trip = this.state.trip
    trip.status = 4
    this.updateTrip(trip)
  }

  waiting_client = () => {
    this.vibrate()
    let trip = this.state.trip
    trip.status = 2
    this.updateTrip(trip)
    if (document.visibilityState == 'hidden') this.notify(this.waitingData())
  }

  start_trip = () => {
    this.vibrate()
    let trip = this.state.trip
    trip.status = 3
    this.updateTrip(trip)
  }

  cancel = (e, callback = false) => {
    if (!confirm(i18n.find_driver.confirm_cancel)) {
      if (callback) callback()
      return;
    }
    axios.patch(`trips/${this.state.trip.id}/cancel`).then((res) => {
      this.updateTrip(null)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  getTrip = () => {
    if (!this.state.trip || !this.state.trip.id) return;
    axios.get(`trips/${this.state.trip.id}`).then((res) => {
      this.updateTrip(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  retry = () => {
    axios.patch(`trips/${this.state.trip.id}/retry`).then((res) => {
      this.updateTrip(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = (event) => {
    event.stopPropagation()
    this.updateTrip(null)
  }

  acceptData = () => {
    let data = {icon: '/icon_128x128.png',
                data: {id: this.state.trip.id, token: localStorage.token},
                badge: '/icon_96x96.png',
                body: `${this.state.trip.driver_name} ${i18n.trip.will_arrive} ${this.state.trip.start_time} ${i18n.trip.on} ${this.state.trip.car_number}`}
    return data
  }

  waitingData = () => {
    let data = {icon: '/icon_128x128.png',
                data: {id: this.state.trip.id, token: localStorage.token},
                badge: '/icon_96x96.png',
                body: i18n.trip.waiting_notice}
    return data
  }

  declineData = () => {
    let data = {icon: '/icon_128x128.png',
                data: {id: this.state.trip.id, token: localStorage.token},
                badge: '/icon_96x96.png',
                body: i18n.trip.no_cars_notice,
                actions: [{action: 'retry', title: '🔄 Retry'}]}
    return data
  }

  render() {
    if (!this.state.trip) return(<CurrentTrip updateTrip={this.updateTrip} handleBack={this.handleBack} language={this.props.language} favorite_addresses={this.props.favorite_addresses()}/>)
    if (this.state.trip && !this.state.trip.id) return(<ConfirmTrip cards={this.props.cards} bonus_trips={this.props.bonus_trips} trip={this.state.trip} updateTrip={this.updateTrip} handleBack={this.handleBack} createCard={this.props.createCard}/>)
    if (this.state.trip && this.state.trip.id && [0].includes(this.state.trip.status)) return(<FindDriver trip={this.state.trip} updateTrip={this.updateTrip} TripDeclined={this.TripDeclined} subscribe={this.subscribe} cancel={this.cancel}/>)
    if (this.state.trip && this.state.trip.id && [6].includes(this.state.trip.status)) return(<RetryTrip trip={this.state.trip} retry={this.retry} cancel={this.cancel}/>)
    if (this.state.trip && [1,2,3].includes(this.state.trip.status)) return(<Trip trip={this.state.trip} updateTrip={this.updateTrip} cancel={this.cancel} location={this.state.car_location} language={this.props.language}/>)
    if (this.state.trip && this.state.trip.status == 4) return(<Feedback trip={this.state.trip} updateTrip={this.updateTrip} handleBack={this.handleBack} />)
    return(<Trip updateTrip={this.updateTrip}/>)
  }
}
