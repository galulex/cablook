import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from '../pwa/i18n.js'

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
    document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') this.getTrips() }, false);
    window.addEventListener('online', this.getTrips)
  }

  componentWillUnmount() {
    this.unsubscribe()
    window.removeEventListener('online', this.getTrips)
  }

  subscribe = () => {
    if (!this.state.trip.id) return;
    if (this.state.subscription) return this.state.subscription
    let component = this
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'TripChannel', trip_id: this.state.trip.id },
      {
        received: data => {
          component[data['action']](data)
        }
      }
    )})
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({subscription: null})
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  getTrips = () => {
    if (!this.state.trip || !this.state.trip.id) return;
    axios.get(`trips/${this.state.trip.id}`).then((res) => {
      this.updateTrip(res.data)
      if (res.data.status == 6) this.TripDeclined()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = (event) => {
  }

  render() {
    return(
      <section>
        <header>Home</header>
        <h1>Home</h1>
      </section>
    )
  }
}
