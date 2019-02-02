import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import Back from './images/arrow-left.svg'

export default class ConfirmTrip extends Component {
  constructor(props) {
    super(props)
    this.state = {
    }
  }

  create = (e) => {
    const params = this.props.trip
    axios.post('trips', {trip: params}).then((res) => {
      // localStorage.setItem('trip', res.data.id)
      this.props.updateTrip(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    return (
      <section>
        <header>{i18n.confirm_trip.header}</header>
        <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
        <h1>Confirm Trip</h1>
        <h2>{this.props.trip.cost}</h2>
        <button class='add-card' type='button' onClick={this.create}>{i18n.confirm_trip.go}</button>
      </section>
    )
  }
}
