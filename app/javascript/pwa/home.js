import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import CurrentTrip from './current-trip.js'
import ConfirmTrip from './confirm_trip.js'
import FindDriver from './find_driver.js'
import Trip from './trip.js'
import Feedback from '../pwa/feedback.js';

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()

export default class Home extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: JSON.parse(localStorage.getItem('trip')),
      subscription: null
    }
  }

  componentDidMount() {
    if (!!this.state.trip) this.subscribe()
    this.getTrip()
  }

  componentWillUnmount() {
    this.unsubscribe()
  }

  subscribe = () => {
    console.log(this.state.subscription)
    if (this.state.subscription) return this.state.subscription
    console.log('Subscribe')
    let component = this
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: this.state.trip.id },
      {
        received: data => {
          console.log(data)
          component[data['action']](data)
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
    this.vibrate()
    setTimeout(() => {
      if (confirm(i18n.trip.car_not_found)) {
        this.retry()
      } else {
        this.unsubscribe()
        this.updateTrip(null)
      }
    }, 500)
  }

  TripAccepted = (data) => {
    this.vibrate()
    this.updateTrip(data.trip)
  }

  TripUnavailable = (data) => {
    this.unsubscribe()
    this.updateTrip(null)
    alert(i18n.trip.canceled)
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
    alert(i18n.trip.canceled)
  }

  cancel = (e) => {
    // if (!confirm(i18n.find_driver.confirm_cancel)) return;
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
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = (event) => {
    event.stopPropagation()
    this.updateTrip(null)
  }

  render() {
    if (!this.state.trip) return(<CurrentTrip updateTrip={this.updateTrip} handleBack={this.handleBack}/>)
    if (this.state.trip && !this.state.trip.id) return(<ConfirmTrip trip={this.state.trip} updateTrip={this.updateTrip} handleBack={this.handleBack}/>)
    if (this.state.trip && this.state.trip.id && [0,6].includes(this.state.trip.status)) return(<FindDriver trip={this.state.trip} updateTrip={this.updateTrip} TripDeclined={this.TripDeclined} subscribe={this.subscribe} cancel={this.cancel}/>)
    if (this.state.trip && [1,2,3].includes(this.state.trip.status)) return(<Trip trip={this.state.trip} updateTrip={this.updateTrip} cancel={this.cancel}/>)
    if (this.state.trip && this.state.trip.status == 4) return(<Feedback trip={this.state.trip} updateTrip={this.updateTrip} />)
    return(<Trip updateTrip={this.updateTrip}/>)
  }
}
