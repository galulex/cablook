import { h, render, Component } from 'preact';
import { route } from 'preact-router';

import Feedback from './feedback.js'
import MapImg from './map_img.js'
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
    this.setState({showDetails: true})
    if (window.ios) return;
    history.pushState(null, 'Trip Details',`/trips/${this.props.trip.id}`);
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
    if (event) event.stopPropagation()
  };

  handleFeedbackBack = (event) => {
    this.setState({isFeedbackVisible: false})
    window.addEventListener('popstate', this.handleBack, {once: true});
  };

  render() {
    const { trip } = this.props;

    return (
      <div class="trip-details">
        <button type='button' id='arrow' class='burger' onClick={() => window.ios ? this.handleBack(event) : window.history.back()}><Back/></button>
        <header>
          {i18n.trip.header}
        </header>
        <section>
          <MapImg trip={() => this.props.trip} />
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
    trip.status = null
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
    trip.osrm = true
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
