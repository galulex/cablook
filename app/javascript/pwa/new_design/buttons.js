import { h } from 'preact'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from '../lib/constants.js'
import i18n from '../i18n.js'
import TripPrice from '../images/ukraine-hryvna.svg'

export default function Buttons() {
  let bonusButton
  const { trip, createTrip, availableBonusTrips,
    cancelTimer, cards, cost,
    picker, isValid, retry, cancel,
    buttonDisabled, showWidgetTrue,
    cancelDeclined, updateRoute,
    confirmUpdate, showFeedback, cashbackAmount } = this.props
  const { stops, status, bonus } = trip
  if ([CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(trip.status) && (picker === null)) {
    if (availableBonusTrips.length > 0) {
      bonusButton = bonusElement(`${i18n.confirm_trip.go} 0`, isValid, buttonDisabled, createTrip)
    } else {
      if (cost && cashbackAmount >= cost) {
        bonusButton = bonusElement(`${i18n.bonuses.cashback} ${cashbackAmount}`, isValid, buttonDisabled, createTrip, true)
      }
    }
  }

  return (
    <div className="buttons">
      {(cards.length < 1) && [CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(status) && !this.props.cash &&
        <button
          class='button green trip_add_card absolute'
          type='button'
          value={bonus}
          onClick={showWidgetTrue}>
          {(cost === '') ? `${i18n.confirm_trip.add_card}` : stops.includes('') ? `${i18n.confirm_trip.go}` : `${i18n.confirm_trip.go} ${cost}`}
          {(cost !== '' && !stops.includes('')) && <TripPrice />}
        </button>}
      {[CANCELED, CANCELED_BY_DRIVER, undefined, null].includes(status) && picker === null && !showFeedback() &&
        <button
          class='button green absolute'
          type='button'
          value={bonus}
          disabled={!isValid || buttonDisabled}
          onClick={createTrip}>
          {this.props.cash && trip.card_id === 'cash' && `${i18n.trip.cash}, `}{stops.includes('') ? `${i18n.confirm_trip.go}` : `${i18n.confirm_trip.go} ${!stops.includes('') && cost}`}
          {(cost !== '' && !stops.includes('')) && <TripPrice />}
        </button>
      }
      {bonusButton}
      {[CONFIRM_UPDATE_TRIP].includes(status) &&
        <button
          class='button absolute'
          type='button'
          value={trip.bonus}
          disabled={!isValid || buttonDisabled}
          onClick={confirmUpdate}>
          {`${i18n.confirm_trip.go} ${cost}`}
          {(cost !== '') && <TripPrice />}
        </button>
      }
      {([PENDING].includes(status) || (cancelTimer > 0 && [ON_THE_WAY].includes(status))) &&
        <button
          class='button absolute cancel'
          type='button'
          disabled={!isValid || buttonDisabled}
          onClick={cancel}>
          {i18n.find_driver.cancel} {cancelTimer}
        </button>
      }
      {[DECLINED].includes(status) &&
        <button
          class='button absolute retry'
          type='button'
          disabled={!isValid || buttonDisabled}
          onClick={retry}>
          {i18n.retry_trip.retry}
        </button>
      }
      {[DECLINED].includes(status) &&
        <button
          class='button absolute cancel'
          type='button'
          disabled={buttonDisabled}
          onClick={cancelDeclined}>
          {i18n.find_driver.cancel}
        </button>
      }
      {([WAITING_CLIENT, DRIVING].includes(status) || (!cancelTimer && status === ON_THE_WAY)) &&
        <button
          class='button absolute edit'
          type='button'
          value={bonus}
          onClick={updateRoute}>
          {i18n.trip.edit}
        </button>
      }
    </div>
  )
}

function bonusElement(title, isValid, buttonDisabled, createTrip, cashback = false) {
  return (
    <button
      class='button bonus'
      type='button'
      value='true'
      disabled={!isValid || buttonDisabled}
      onClick={cashback ? (e) => createTrip(e, true) : createTrip}>
      {title} <TripPrice />
    </button>
  )
}
