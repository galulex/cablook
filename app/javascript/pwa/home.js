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
      trip: JSON.parse(localStorage.getItem('trip'))
    }
  }

  componentDidMount() {
    if (!!this.state.trip) this.subscribe()
  }

  subscribe = () => {
    console.log(this.state)
    let component = this
    cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: this.state.trip.id },
      {
        received: data => {
          console.log(data)
          component[data['action']](data)
        }
      }
    )
  }

  updateTrip = (trip) => {
    localStorage.setItem('trip', JSON.stringify(trip))
    this.setState({trip: trip})
  }

  TripDeclined = (data) => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
    setTimeout(() => {
      if (confirm(i18n.trip.car_not_fond)) {
        this.retry()
      } else {
        this.updateTrip(null)
      }
    }, 500)
  }

  TripAccepted = (data) => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
    this.updateTrip(data.trip)
  }

  TripUnavailable = (data) => {
    this.updateTrip(null)
    alert(i18n.trip.canceled)
  }

  finish_trip = (data) => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
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
    console.log(this.state.trip)
    if (!this.state.trip) return(<CurrentTrip updateTrip={this.updateTrip} handleBack={this.handleBack}/>)
    if (this.state.trip && !this.state.trip.id) return(<ConfirmTrip trip={this.state.trip} updateTrip={this.updateTrip} handleBack={this.handleBack}/>)
    if (this.state.trip && this.state.trip.id && this.state.trip.status == 0) return(<FindDriver trip={this.state.trip} updateTrip={this.updateTrip} subscribe={this.subscribe} cancel={this.cancel}/>)
    if (this.state.trip && [1,2,3].includes(this.state.trip.status)) return(<Trip trip={this.state.trip} updateTrip={this.updateTrip} cancel={this.cancel}/>)
    if (this.state.trip && this.state.trip.status == 4) return(<Feedback trip={this.state.trip} updateTrip={this.updateTrip} />)
    return(<Trip updateTrip={this.updateTrip}/>)
  }
}
