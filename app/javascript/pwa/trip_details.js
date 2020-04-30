import { h, render, Component } from 'preact';
import { route } from 'preact-router';

import Feedback from './feedback.js'
import MapImg from './map_img.js'
import TripPrice from './images/trip_price.js'
import TripStatus from './images/trip_status.js'
import Clock from './images/clock.js'
import Star from './images/star.js'
import Pin from './images/pin.js'
import i18n from './i18n.js'

export default class TripCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showDetails: false,
      isFeedbackVisible: false
    }
  }

  componentDidMount() {
    this.setRate()
    this.setState({showDetails: true})
    if (window.ios) return;
    // history.pushState(null, 'Trip Details',`/trips/${this.props.trip.id}`);
    window.addEventListener('popstate', this.props.handleBack, {once: true});
  };

  componentWillUnmount() {
    window.removeEventListener('popstate', this.props.handleBack)
  }

  showFeedback = () => {
    if (this.state.isFeedbackVisible) return;
    this.setState({isFeedbackVisible: true})
    window.removeEventListener('popstate', this.props.handleBack)
  };

  handleFeedbackBack = (event) => {
    this.setState({isFeedbackVisible: false})
    window.addEventListener('popstate', this.props.handleBack, {once: true});
  };

  render() {
    const { trip } = this.props;

    return (
      <div class="trip-details">
        <header>{i18n.trip.header}</header>
        <section class="trip-details-section">
          <MapImg trip={() => this.props.trip} />
          <div class='trip-details__content'>
            <div class="buttons">
              <button type='button' class= 'button dark-color' onClick={this.repeatTrip}>{i18n.trips.repeat}</button>
              <button type='button' class= 'button dark-color' onClick={this.reverseTrip}>{i18n.trips.reverse}</button>
            </div>
            <div class='trip-details-content'><TripPrice/>{`${trip.cost} ${i18n.trip.currency}`}</div>
            <div class='trip-details-content'><TripStatus/>{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
            <div class='trip-details-content'>
              <address><Pin class='address-pin'/>{trip.departure_address}</address>
              <address><Pin class='address-pin'/>{trip.destination_address}</address>
            </div>
            <div class='trip-details-content'><Clock/>{trip.formatted_date}</div>
            {this.renderRate()}
          </div>
        </section>
        {this.state.isFeedbackVisible && <Feedback trip={this.props.trip} handleBack={this.handleFeedbackBack} isFeedbackVisible={this.state.isFeedbackVisible} getRate={this.getRate}/>}
      </div>
    )
  }

  repeatTrip = () => {
    const trip = { ...this.props.trip, status: undefined, id: undefined, osrm: true }
    delete trip.formatted_date
    this.props.setCurrentTrip(trip)
    route('/', true)
  }

  reverseTrip = () => {
    let start = this.props.trip.departure;
    let start_address = this.props.trip.departure_address;
    let finish = this.props.trip.destination;
    let finish_address = this.props.trip.destination_address;
    let waypoints = this.props.trip.waypoints.reverse();
    let stops = this.props.trip.stops.reverse();

    const trip = {
      ...this.props.trip,
      status: undefined,
      id: undefined,
      departure: finish,
      departure_address: finish_address,
      destination: start,
      destination_address: start_address,
      osrm: true
    }
    delete trip.formatted_date

    this.props.setCurrentTrip(trip)
    route('/', true)
  }

  getRate = (value) => {
    this.setState({rate: value})
  }

  setRate = () => {
    if (this.props.trip.feedbacks.length >= 1) {
      this.setState({rate: this.props.trip.feedbacks[0].rate})
    }
  }

  renderRate = () => {
    if (this.props.trip.status !== 4) return;
    if (this.state.rate) {
      return(<div class='trip-details-content'>{Array(this.state.rate).fill(<Star class='star-icon' />)}</div>)
    } else {
      return(<div class='trip-details-content'><button class='button' onClick={this.showFeedback}>{i18n.trips.rate}</button></div>)
    }
  }
}
