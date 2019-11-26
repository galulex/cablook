import { h, render, Component } from 'preact'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from '../lib/constants.js'
import i18n from '../i18n.js'
import Back from '../images/arrow-left.svg'
import TripPrice from '../images/ukraine-hryvna.svg'
import '../css/new_design.css'

export default class Buttons extends Component {
  render() {
    const { trip } = this.props

    return (
      <div className="buttons">
        { (this.props.cards.length < 1) && [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) &&
          <button class='button trip_add_card fixed' type='button' value={trip.bonus} onClick={this.props.showWidgetTrue}>{(this.props.cost === '') ? `${i18n.confirm_trip.add_card}` : `${i18n.confirm_trip.go} ${this.props.cost}`}
          {(this.props.cost !== '') && <TripPrice/>}
          </button> }
        { [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) &&
          <button class='button fixed' type='button' value={trip.bonus} disabled={!this.props.isValid || this.props.paymentButtonDisabled} onClick={this.props.createTrip}>{`${i18n.confirm_trip.go} ${this.props.cost}`}
          {(this.props.cost !== '') && <TripPrice/>}
          </button> }
        { [CONFIRM_UPDATE_TRIP].includes(trip.status) &&
          <button class='button fixed' type='button' value={trip.bonus} disabled={!this.props.isValid} onClick={this.props.confirmUpdate}>{`${i18n.confirm_trip.go} ${this.props.cost}`}
          {(this.props.cost !== '') && <TripPrice/>}
          </button> }
        { [CONFIRM_UPDATE_TRIP].includes(trip.status) && <button type='button' class='burger' onClick={this.props.handleBackEdit}><Back/></button> }
        { [PENDING, ON_THE_WAY].includes(trip.status) && <button class='button fixed cancel' type='button' onClick={this.props.cancel}>{i18n.find_driver.cancel}</button> }
        { [DECLINED].includes(trip.status) && <button class='button fixed retry' type='button' onClick={this.props.retry}>{i18n.retry_trip.retry}</button> }
        { [DECLINED].includes(trip.status) && <button class='button fixed cancel' type='button' onClick={this.props.cancelDeclined}>{i18n.find_driver.cancel}</button> }
        { [WAITING_CLIENT, DRIVING].includes(trip.status) && <button class='button fixed edit' type='button' onClick={this.props.updateRoute}>{i18n.trip.edit}</button> }
        { (this.props.picker !== null) && <button class='button fixed' type='button' onClick={this.props.pickAddress}>OK</button> }
      </div>
    )
  }
}
