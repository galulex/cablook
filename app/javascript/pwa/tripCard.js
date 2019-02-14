import { h, render, Component } from 'preact';
import { route } from 'preact-router';

import Feedback from './feedback.js'
import TripPrice from './images/trip_price.svg'
import TripStatus from './images/trip_status.svg'
import TripTime from './images/trip_time.svg'
import Back from './images/arrow-left.svg'
import Star from './images/star.svg'
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
  }

  showDetails = () => {
    if (this.state.showDetails) return;
    history.pushState(null, 'Trip Details','/trips');
    this.setState({showDetails: true})
    window.addEventListener('popstate', this.handleBack, {once: true});
  };

  showFeedback = () => {
    if (this.state.isFeedbackVisible) return;
    this.setState({isFeedbackVisible: true})
    window.removeEventListener('popstate', this.handleBack)
  };

  handleBack = (event) => {
    this.setState({showDetails: false})
    event.stopPropagation();
  };

  handleFeedbackBack = (event) => {
    this.setState({isFeedbackVisible: false})
    window.addEventListener('popstate', this.handleBack, {once: true});
    event.stopPropagation();
  };

  renderDetails = () => {
    const { trip } = this.props;

    const departure = []
    const destination = []
    const waypoints = []
    trip.departure.map((el, index) => departure[index] = el)
    trip.destination.map((el, index) => destination[index] = el)
    destination.reverse()
    departure.reverse()
    trip.waypoints.map((w, index) => {
      waypoints[index] = w.split(',').reverse().join(',')
    })
    localStorage.mapURL = 'https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+188753-0.8(' + encodeURIComponent(trip.path) + ')/auto/600x600?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ'

    return (
      <div class="trip-details">
        <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
        <header>
          {i18n.trip.header}
        </header>
        <section>
          <img src={localStorage.mapURL}/>
          <div class="buttons">
            <button type='button' class= 'button' onClick={this.repeatTrip}>{i18n.trips.repeat}</button>
            <button type='button' class= 'button' onClick={this.reverseTrip}>{i18n.trips.reverse}</button>
          </div>
          <div class='trip-details-content'><TripPrice/>{`${trip.cost} ${i18n.trip.currency}`}</div>
          <div class='trip-details-content'><TripStatus/>{`${i18n.trips.status} - ${i18n.trips.statuses[trip.status]}`}</div>
          <div class='trip-details-content'>
            <address>{trip.departure_address}</address>
            <address>{trip.destination_address}</address>
          </div>
          <div class='trip-details-content'><TripTime/>{trip.formatted_date}</div>
          <div class='trip-details-content'>{this.renderRate()}</div>
        </section>
        {this.state.isFeedbackVisible && <Feedback trip={this.props.trip} handleBack={this.handleFeedbackBack} isFeedbackVisible={this.state.isFeedbackVisible} getRate={this.getRate}/>}
      </div>
    )
  }

  repeatTrip = () => {
    const { trip } = this.props
    trip.status = 0
    trip.id = null
    delete trip.formatted_date
    localStorage.setItem('trip', JSON.stringify(trip))
    route('/', true)
  }

  reverseTrip = () => {
    const { trip } = this.props;
    trip.status = 0
    trip.id = null
    delete trip.formatted_date
    let start = trip.departure
    let address = trip.departure_address
    trip.departure_address = trip.destination_address
    trip.departure = trip.destination
    trip.destination_address = address
    trip.destination = start
    trip.waypoints = trip.waypoints.reverse()
    trip.stops = trip.stops.reverse()
    localStorage.setItem('trip', JSON.stringify(trip))
    route('/', true)
  }

  render() {
    const { trip } = this.props;
    return (
      <li class="trip-card" onClick={this.showDetails}>
        <div class='address-block'>
          <address>{trip.departure_address}</address>
          <address>{trip.destination_address}</address>
        </div>
        <p>{[`${trip.cost} ${i18n.trip.currency}`, trip.formatted_date, i18n.trips.statuses[trip.status]].join(", ")}</p>
        {this.state.showDetails && this.renderDetails()}
      </li>
    );
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
    if (this.state.rate) {
      return(Array(this.state.rate).fill(<Star />))
    } else {
      return(<button class='button cancel' onClick={this.showFeedback}>{i18n.trips.rate}</button>)
    }
  }
}
