import { h, render, Component } from 'preact';
import { route } from 'preact-router';

import Details from './trip_details.js'
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

  showDetails = (val) => {
    this.setState({showDetails: val})
  };

  showRate = () => {
    if (this.props.trip.feedbacks.length >= 1) {
      return(Array(this.props.trip.feedbacks[0].rate).fill(<Star class='trip-card-star'/>))
    }
  }

  render() {
    const { trip } = this.props;
    return (
      <li class="trip-card" onClick={() => this.showDetails(true) }>
        <div class='address-block'>
          <address>{trip.departure_address}</address>
          <address>{trip.destination_address}</address>
        </div>
        <p>
          <span>{[`${trip.cost} ${i18n.trip.currency}`, trip.formatted_date, i18n.trips.statuses[trip.status]].join(", ")}</span>
          <span>{ this.showRate() }</span>
        </p>
        {this.state.showDetails && <Details trip={trip} showDetails={this.showDetails}/>}
      </li>
    );
  }
}
