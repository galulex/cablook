import { h, render, Component } from 'preact'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from '../lib/constants.js'
import i18n from '../i18n.js'
import TripPrice from '../images/ukraine-hryvna.svg'
import '../css/new_design.css'

export default class Buttons extends Component {
  render() {
    const { trip, createTrip, availableBonusTrips,
            cancelTimer, cards, cost,
            picker, isValid, retry, cancel,
            paymentButtonDisabled, showWidgetTrue,
            cancelDeclined, pickAddress, updateRoute,
            confirmUpdate, showFeedback, isGeocoding } = this.props
    const { stops, status, bonus } = trip

    return (
      <div className="buttons">
        { (cards.length < 1) && [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(status) &&
          <button
            class='button green trip_add_card fixed'
            type='button'
            value={bonus}
            onClick={showWidgetTrue}>
              {(cost === '') ? `${i18n.confirm_trip.add_card}` : stops.includes('') ? `${i18n.confirm_trip.go}` : `${i18n.confirm_trip.go} ${cost}`}
              {(cost !== '' && !stops.includes('')) && <TripPrice/>}
          </button> }
        { [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(status) && picker === null && !showFeedback() && (cards.length >= 1) &&
          <button
            class='button green fixed'
            type='button'
            value={bonus}
            disabled={!isValid || paymentButtonDisabled}
            onClick={createTrip}>
              {stops.includes('') ? `${i18n.confirm_trip.go}` : `${i18n.confirm_trip.go} ${!stops.includes('') && cost}`}
              {(cost !== '' && !stops.includes('')) && <TripPrice/>}
          </button>
          }
        { [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) && (picker === null) && availableBonusTrips.length > 0 &&
          <button
            class='button bonus'
            type='button'
            value='true'
            disabled={!isValid || paymentButtonDisabled}
            onClick={createTrip}>
              {`${i18n.confirm_trip.go} 0`} <TripPrice/>
          </button>
        }
        { [CONFIRM_UPDATE_TRIP].includes(status) &&
          <button
            class='button fixed'
            type='button'
            value={trip.bonus}
            disabled={!isValid}
            onClick={confirmUpdate}>
              {`${i18n.confirm_trip.go} ${cost}`}
              {(cost !== '') && <TripPrice/>}
          </button>
        }
        { ([PENDING].includes(status) || (cancelTimer > 0 && [ON_THE_WAY].includes(status))) &&
          <button
            class='button fixed cancel'
            type='button'
            onClick={cancel}>
              {i18n.find_driver.cancel} {cancelTimer}
          </button>
        }
        { [DECLINED].includes(status) &&
          <button
            class='button fixed retry'
            type='button'
            onClick={retry}>
              {i18n.retry_trip.retry}
          </button>
        }
        { [DECLINED].includes(status) &&
          <button
            class='button fixed cancel'
            type='button'
            onClick={cancelDeclined}>
              {i18n.find_driver.cancel}
          </button>
        }
        { ([WAITING_CLIENT, DRIVING].includes(status) || (!cancelTimer && status === ON_THE_WAY)) &&
          <button
            class='button fixed edit'
            type='button'
            value={bonus}
            onClick={updateRoute}>
              {i18n.trip.edit}
          </button>
        }
        { (picker !== null) &&
          <button
            class='button green pick_address fixed'
            type='button'
            disabled={isGeocoding}
            onClick={pickAddress}>
              OK
          </button>
        }
      </div>
    )
  }
}
