import { h, render, Component } from 'preact';
import axios from 'axios';

import CurrentTrip from './current-trip.js'
import ConfirmTrip from './confirm_trip.js'
import FindDriver from './find_driver.js'

export default class Home extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: null
    }
  }

  updateTrip = (trip) => {
    this.setState({trip: trip})
  }

  render() {
    console.log(this.state.trip)
    if (!this.state.trip) return(<CurrentTrip updateTrip={this.updateTrip}/>)
    if (this.state.trip && !this.state.trip.id) return(<ConfirmTrip trip={this.state.trip} updateTrip={this.updateTrip}/>)
    if (this.state.trip && this.state.trip.id && this.state.trip.status == 0) return(<FindDriver trip={this.state.trip} updateTrip={this.updateTrip}/>)
    return(<CurrentTrip updateTrip={this.updateTrip}/>)
  }
}
