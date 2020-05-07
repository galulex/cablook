import { h, render, Component } from 'preact'
import { route } from 'preact-router'

import Details from './trip_details.js'
import getRate from './new_design/rate.js'
import i18n from './i18n.js'
import Pin from './images/pin.js'

export default class TripCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showDetails: false,
      isFeedbackVisible: false
    }
  }

  showDetails = (val) => {
    this.props.changeShowDet()
    this.setState({showDetails: val})
  };

  componentWillReceiveProps(nextProps) {
    if (!nextProps.showDet) {
      this.setState({showDetails: false})
    }
  }

  showRate = () => {
    if (this.props.trip.feedbacks.length >= 1) return(getRate(this.props.trip.feedbacks[0].rate))
  }

  render() {
    const { trip, handleBack } = this.props
    return (
      <li class="trip-card" onClick={() => this.showDetails(true) }>
        <div class='address-block'>
          <address><Pin class='address-pin'/>{trip.departure_address}</address>
          <address><Pin class='address-pin'/>{trip.destination_address}</address>
        </div>
        <p>
          <span>{[`${trip.cost} ${i18n.trip.currency}`, trip.formatted_date, i18n.trips.statuses[trip.status]].join(", ")}</span>
          <span>{ this.showRate() }</span>
        </p>
        { this.state.showDetails && 
          <Details 
            handleBack={handleBack}
            showDetails={this.showDetails}
            trip={trip}
            setCurrentTrip={this.props.setCurrentTrip}
            showFeedback={this.props.showFeedback}
            setActivateFeedback={this.props.setActivateFeedback}
          />
        }
      </li>
    );
  }
}
