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
    console.log('SHOW')
    history.pushState(null, 'Trip Details',`/trips/${this.props.trip.id}`);
    this.setState({showDetails: true})
    window.addEventListener('popstate', this.handleBack, {once: true});
  };

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack)
  }

  showFeedback = () => {
    if (this.state.isFeedbackVisible) return;
    this.setState({isFeedbackVisible: true})
    window.removeEventListener('popstate', this.handleBack)
  };

  handleBack = (event) => {
    this.props.showDetails(false)
    event.stopPropagation();
  };

  handleFeedbackBack = (event) => {
    this.setState({isFeedbackVisible: false})
    window.addEventListener('popstate', this.handleBack, {once: true});
    event.stopPropagation();
  };

  render() {
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
    let mapURL = 'https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+188753-0.8(' + encodeURIComponent(trip.path) + ')/auto/600x600?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ'

    return (
      <div class="trip-details">
        <button type='button' class='burger' onFocus={(event) => window.history.back()} onClick={(event) => window.history.back()}><Back fill='#132d50'/></button>
        <header>
          {i18n.trip.header}
        </header>
        <section>
          <img src={mapURL}/>
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
          {this.renderRate()}
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

  getRate = (value) => {
    this.setState({rate: value})
  }

  setRate = () => {
    if (this.props.trip.feedbacks.length >= 1) {
      this.setState({rate: this.props.trip.feedbacks[0].rate})
    }
  }

  renderRepeatReverse = () => {
    if ([1,2,3].includes(this.props.trip.status)) return;
    return(
      <div class="buttons">
        <button type='button' class= 'button' onClick={this.repeatTrip}>{i18n.trips.repeat}</button>
        <button type='button' class= 'button' onClick={this.reverseTrip}>{i18n.trips.reverse}</button>
      </div>
    )
  }

  renderRate = () => {
    if (this.props.trip.status !== 4) return;
    if (this.state.rate) {
      return(<div class='trip-details-content'>{Array(this.state.rate).fill(<Star />)}</div>)
    } else {
      return(<div class='trip-details-content'><button class='button cancel' onClick={this.showFeedback}>{i18n.trips.rate}</button></div>)
    }
  }
}
