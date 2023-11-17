import { h } from 'preact'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from '../lib/constants.js'
import i18n from '../i18n.js'
import TripPrice from '../images/ukraine-hryvna.svg'
import { isAllowedFeature } from '.././lib/featureFlag.js'

export default function Buttons() {
  let bonusButton

  const { trip, createTrip, availableBonusTrips, cancelTimer, cards, cost,
    picker, isValid, retry, cancel, buttonDisabled, showWidgetTrue, cash,
    cancelDeclined, updateRoute, confirmUpdate, showFeedback, cashbackAmount } = this.props
  const { stops, status, bonus, card_id } = trip

  const createMobilePayment = () => {
    const payButton = document.querySelector('.f-wallet-pay-button-28 a')
    payButton ? payButton.click() : alert('Something went wrong')
  }

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
          onClick={card_id === 'mobile' ? createMobilePayment : createTrip}>
          {cash && card_id === 'cash' && `${i18n.trip.cash}, `}
          {stops.includes('') ? `${i18n.confirm_trip.go}` : `${i18n.confirm_trip.go} ${!stops.includes('') && cost}`}
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
      {isAllowedFeature && card_id === 'mobile' && trip.cost > 0 && picker === null &&
        <div id='fondy-container'>
          {googlePayButton(trip, createTrip)}
        </div>
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

function googlePayButton(trip, createTrip) {
  if (!isAllowedFeature) return

  const loadScript = (src, onLoad) => {
    const script = document.createElement('script')
    script.src = src
    script.async = true
    script.onload = onLoad
    document.head.appendChild(script)
  }

  const loadStylesheet = (href, onLoad) => {
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = href
    link.onload = onLoad
    document.head.appendChild(link)
  }

  const options = {
    methods: ['wallets'],
    button: false,
    tooltip: false,
    fields: false,
    full_screen: false
  }

  const params = {
    merchant_id: 1523866,
    required_rectoken: 'y',
    currency: 'UAH',
    amount: trip.cost * 100,
    order_desc: `Cablook Trip, ${new Date()}`,
    email: '',
    lang: 'uk'
  }

  loadStylesheet('https://pay.fondy.eu/latest/checkout.css', () => {
    loadScript('https://pay.fondy.eu/latest/checkout.js', () => {
      loadScript('https://pay.fondy.eu/latest/i18n/uk.js', () => {
        fondy('#fondy-container', { options, params })
          .$on('success', (model) => {
            document.getElementById('fondy-container').style.display = 'none'
            const order = model.attr('order')
            const approved = order.order_data.order_status == 'approved' && order.order_data.response_status == 'success'
            if (approved) createTrip({ target: { value: false } }, false, order)
          })
          .$on('error', (model) => {
            console.log('Order is declined: ' + model.attr('error.code') + ', description: ' + model.attr('error.message'))
          })
      })
    })
  })
}
