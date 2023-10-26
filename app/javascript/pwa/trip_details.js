import { h, render, Component } from 'preact'
import axios from 'axios'
import { route } from 'preact-router'

import Feedback from './feedback.js'
import MapImg from './map_img.js'
import TripPrice from './images/trip_price.js'
import TripStatus from './images/trip_status.js'
import Clock from './images/clock.svg'
import Pin from './images/pin.svg'
import i18n from './i18n.js'
import getRate from './new_design/rate.js'

export default class TripCard extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isFeedbackVisible: false
    }
  }

  componentDidMount() {
    this.setRate()
    this.props.main.classList.add('noscroll')
    if (window.ios) return
    history.pushState(null, 'Trip Details', `/trips/${this.props.trip.id}`)
    window.addEventListener('popstate', this.props.handleBack, { once: true, passive: true })
  }

  componentWillUnmount() {
    this.props.main.classList.remove('noscroll')
    window.removeEventListener('popstate', this.props.handleBack, { passive: true })
  }

  toggleFeedback = () => {
    this.props.setActivateFeedback(true)
  }

  handleFeedbackBack = (event) => {
    this.props.setActivateFeedback()
  }

  render() {
    const { trip } = this.props

    return (
      <div class="trip-details">
        <header class='details'>{i18n.trip.header}</header>
        <section class="trip-details__section">
          <MapImg trip={this.props.trip} />
          <div class='trip-details__content'>
            <div class='trip-details__holder'>
              <div class="buttons">
                <button type='button' class='button white-opacity' onClick={this.repeatTrip}>{i18n.trips.repeat}</button>
                <button type='button' class='button white-opacity' onClick={this.reverseTrip}>{i18n.trips.reverse}</button>
              </div>
              <div class='trip-details-content'><TripPrice class='details-icon' />{`${trip.cost} ${i18n.trip.currency}`}</div>
              <div class='trip-details-content'><TripStatus class='details-icon' />{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
              <div class='trip-details-content'>
                <address><Pin class='pin address-pin details-icon' />{trip.departure_address}</address>
                <address><Pin class='pin address-pin details-icon' />{trip.destination_address}</address>
              </div>
              <div class='trip-details-content'><Clock class='details-icon' />{trip.formatted_date}</div>
              {this.renderRate()}
            </div>
          </div>
        </section>
        {this.props.showFeedback() && <Feedback trip={this.props.trip} handleBack={this.handleFeedbackBack} isFeedbackVisible={this.state.isFeedbackVisible} getRate={this.getRate} />}
      </div>
    )
  }

  repeatTrip = () => {
    const trip = {
      ...this.props.trip,
      status: undefined,
      id: undefined,
      osrm: true,
      departure: this.props.trip.departure.join(','),
      destination: this.props.trip.destination.join(',')
    }
    delete trip.formatted_date
    this.buildTrip(trip)
  }

  reverseTrip = () => {
    let start = this.props.trip.departure
    let start_address = this.props.trip.departure_address
    let finish = this.props.trip.destination
    let finish_address = this.props.trip.destination_address
    let waypoints = this.props.trip.waypoints.reverse()
    let stops = this.props.trip.stops.reverse()

    const trip = {
      ...this.props.trip,
      status: undefined,
      id: undefined,
      departure: finish.join(','),
      departure_address: finish_address,
      destination: start.join(','),
      destination_address: start_address,
      osrm: true
    }
    delete trip.formatted_date
    this.buildTrip(trip)
  }

  buildTrip = (trip) => {
    route('/', true)
    axios.post('trips/new', { trip: trip }).then((res) => {
      trip.path = res.data.path
      trip.cost = res.data.cost
      this.props.setCurrentTrip(trip)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  getRate = (value) => {
    this.setState({ rate: value })
  }

  setRate = () => {
    if (this.props.trip.feedbacks.length >= 1) {
      this.setState({ rate: this.props.trip.feedbacks[0].rate })
    }
  }

  renderRate = () => {
    if (this.props.trip.status !== 4) return
    if (this.state.rate) {
      return (<div class='trip-details-content'>{getRate(this.state.rate)}</div>)
    } else {
      return (<div class='trip-details-content'><button class='button green' onClick={this.toggleFeedback}>{i18n.trips.rate}</button></div>)
    }
  }
}
