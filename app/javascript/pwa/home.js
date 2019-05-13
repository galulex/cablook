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

var timeout

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
    document.addEventListener('visibilitychange', this.onVisibilityChange, false);
    window.addEventListener('online', this.getTrip)
    timeout = setTimeout(this.getTrip, 70000)
  }

  componentWillUnmount() {
    this.unsubscribe()
    window.removeEventListener('online', this.getTrip)
    document.removeEventListener('visibilitychange', this.onVisibilityChange)
    clearTimeout(timeout)
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

  onVisibilityChange = () => {
    if (document.visibilityState === 'visible') this.getTrip()
  }

  updateTrip = (trip) => {
    localStorage.setItem('trip', JSON.stringify(trip))
    this.setState({trip: trip})
  }

  TripDeclined = (data) => {
    clearTimeout(timeout)
    if (document.visibilityState !== 'hidden') {
      this.vibrate()
      this.getTrip()
      return
    }
  }

  TripAccepted = (data) => {
    this.vibrate()
    this.updateTrip(data.trip)
    clearTimeout(timeout)
  }

  TripUnavailable = (data) => {
    this.unsubscribe()
    this.updateTrip(null)
    if (data.by_driver) alert(i18n.trip.canceled)
  }

  DriverLocationUpdated = (data) => {
    let trip = this.state.trip
    if (trip && [null, 10].includes(trip.status)) return;

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
    this.props.fetchUser()
  }

  waiting_client = () => {
    let trip = this.state.trip
    if ([null, 10].includes(trip.status)) return;

    this.vibrate()
    trip.status = 2
    this.updateTrip(trip)
  }

  start_trip = () => {
    let trip = this.state.trip
    if ([null, 10].includes(trip.status)) return;

    this.vibrate()
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
      this.props.fetchUser()
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

  edit = () => {
    axios.get(`trips/${this.state.trip.id}`).then((res) => {
      let trip = res.data
      trip.status = null
      this.updateTrip(trip)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = (event) => {
    event.stopPropagation()
    let trip = this.state.trip
    trip.status = null
    this.updateTrip(trip)
  }

  handleFeedbackBack = (event) => {
    event.stopPropagation()
    this.updateTrip(null)
  }

  render() {
    const { trip } = this.state

    if (!trip || [5,7,null].includes(trip.status)) return(<CurrentTrip updateTrip={this.updateTrip} handleBack={this.handleBack} language={this.props.language} trip={trip} favorite_addresses={this.props.favorite_addresses()}/>)
    if (trip && (!trip.id || trip.status == 10)) return(<ConfirmTrip cards={this.props.cards} bonus_trips={this.props.bonus_trips} trip={trip} updateTrip={this.updateTrip} handleBack={this.handleBack} createCard={this.props.createCard} />)
    if (trip && trip.id && [0].includes(trip.status)) return(<FindDriver trip={trip} updateTrip={this.updateTrip} TripDeclined={this.TripDeclined} subscribe={this.subscribe} cancel={this.cancel}/>)
    if (trip && trip.id && [6].includes(trip.status)) return(<RetryTrip trip={trip} retry={this.retry} cancel={this.cancel}/>)
    if (trip && [1,2,3].includes(trip.status)) return(<Trip trip={trip} updateTrip={this.updateTrip} edit={this.edit} cancel={this.cancel} location={this.state.car_location} language={this.props.language}/>)
    if (trip && trip.status == 4) return(<Feedback trip={trip} updateTrip={this.updateTrip} handleBack={this.handleFeedbackBack} />)
    return(<Trip updateTrip={this.updateTrip}/>)
  }
}
