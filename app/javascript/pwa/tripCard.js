import { h, render, Component } from 'preact';
import './css/trips.css'

import TripPrice from './images/trip_price.svg'
import TripStatus from './images/trip_status.svg'
import TripTime from './images/trip_time.svg'

export default class TripCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showDetails: false
    }
  }

  showDetails = () => {
    if (this.state.showDetails) return;
    this.setState({showDetails: true})
  };

  closeDetails = (e) => {
    e.stopPropagation();
    this.setState({showDetails: false})
  };

  renderDetails = () => {
    const { trip } = this.props;
    const style = {
      width: "100%",
      position: "fixed",
      height: "100%",
      background: "white",
      left: "0",
      top: "0",
      zIndex: "10001"
    };

    const backStyle = {
      background: "#19A160",
      height: "100%",
      position: "absolute",
      left: "0",
      top: "0",
      padding: "1rem"
    };

    const button = {
      background: "#19A160",
      padding: "10px",
      display: "inline-block",
      width: "49%",
      color: "white",
      textAlign: "center"
    };

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
    localStorage.mapURL = 'https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+188753-0.8(' + encodeURIComponent(trip.path) + ')/auto/500x500?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ'

    return (
      <div class="trip-details" style={style}>
        <header>
          Trip Details
          <span onClick={this.closeDetails} style={backStyle}>&lArr;</span>
        </header>
        <section>
          <img src={localStorage.mapURL}/>
          <div class="buttons">
            <span style={{...button, marginRight: "2%"}}>Repeat Trip</span>
            <span style={button}>Reverse Trip</span>
          </div>
          <div class='trip-details-content'><TripPrice/>{`${trip.cost} UAH`}</div>
          <div class='trip-details-content'><TripStatus/>{`Status - ${trip.human_status}`}</div>
          <div class='trip-details-content'>
            <address>{trip.departure_address}</address>
            <address>{trip.destination_address}</address>
          </div>
          <div class='trip-details-content'><TripTime/>{trip.formatted_date}</div>
        </section>
      </div>
    )
  };

  render() {
    const { trip } = this.props;
    return (
      <li class="trip-card" onClick={this.showDetails}>
        <div class='address-block'>
          <address>{trip.departure_address}</address>
          <address>{trip.destination_address}</address>
        </div>
        <p>{[`${trip.cost} UAH`, trip.formatted_date, trip.human_status].join(", ")}</p>
        {this.state.showDetails && this.renderDetails()}
      </li>
    );
  }
}
