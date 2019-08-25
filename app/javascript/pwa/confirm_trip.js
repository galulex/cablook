import { h, render, Component } from 'preact';
import axios from 'axios';

import MapImg from './map_img.js'
import PreviewMap from './preview_map.js'
import Widget from './widget.js'
import Loader from './loader.js'
import i18n from './i18n.js'
import './css/confirm_trip.css'
import TripPrice from './images/trip_price.svg'
import Pin from './images/pin.svg'
import Back from './images/arrow-left.svg'
import SearchLogo from './images/search_logo.svg'

export default class ConfirmTrip extends Component {
  constructor(props) {
    super(props)
    this.state = {
      cards: this.props.cards(),
      card_id: null,
      bonus: null,
      submitDisabled: false,
      showWidget: false,
      showLoader: false
    }
  }

  componentDidMount() {
    this.getCards()
    if (window.ios) return;
    history.pushState(null, null,'/')
    window.addEventListener('popstate', this.props.handleBack)
  }

  componentWillReceiveProps() {
    this.getCards()
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.props.handleBack);
  }

  create = (e) => {
    let params = {...this.props.trip}
    this.submitDisabled(true)
    params.departure = params.departure.join(',')
    params.destination = params.destination.join(',')
    params.card_id = this.state.card_id
    if (this.state.bonus === 'true') params.bonus = this.state.bonus
    this.sendRequest(params)
  }

  sendRequest = (params) => {
    axios({
      method: params.id ? 'put' : 'post',
      url: params.id ? `trips/${params.id}` : 'trips',
      data: { trip: params }
    }).then((res) => {
      this.props.updateTrip(res.data)
      window.removeEventListener('popstate', this.props.handleBack);
    }).catch((error) => {
      if (!error.response) return
      switch(error.response.status) {
        case 418:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
            this.retryPendingPayment()
          }
          break
        case 406:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.trip_payment}`)) {
            this.setState({bonus: false})
            this.props.trip.bonus = false
            this.create()
          }
          break
        default:
          alert(error.response.data.errors)
          break
      }
      this.submitDisabled(false)
    })
  }

  retryPendingPayment = () => {
    this.showLoader(true)
    axios.post('payments/retry_pendings', {card_id: this.state.card_id}).then((res) => {
      if (res.data.length === 0) {
        this.create()
      } else {
        this.showLoader(false)
        setTimeout(() => {alert(i18n.confirm_trip.payment_error)}, 500)
        this.submitDisabled(false)
      }
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  getCards = () => {
    this.setState({cards: this.props.cards(), card_id: (this.props.cards().length >= 1) ? this.props.cards()[0].id : null})
  }

  createCard = (data) => {
    this.props.createCard(data)
    this.setState({showWidget: false})
  }

  render() {
    const { trip } = this.props
    const { cards, submitDisabled, showWidget, showLoader } = this.state

    return (
      <div class='confirm-container'>
        {showLoader && <Loader/>}
        <button type='button' id='arrow' class='burger' onClick={() => window.ios ? this.props.handleBack() : window.history.back()}><Back/></button>
        <header>{i18n.confirm_trip.header}</header>
        <section class='confirm-trip'>
          <div class='details'>
            <ul class='details-list'>
              <li>
                <TripPrice />
                <span>{i18n.confirm_trip.cost}</span>
                <span><b id='trip_cost'>{trip.cost} {i18n.confirm_trip.currency}</b></span>
              </li>
              <li>
                <Pin />
                <span>{i18n.confirm_trip.distance}</span>
                <span><b id='trip_distance'>{(trip.distance/1000).toFixed(1)} {i18n.confirm_trip.km}</b></span>
              </li>
            </ul>
          </div>
          { (cards.length > 0) &&
            <div class='select-section'>
              <label for='card'>{i18n.confirm_trip.card}</label>
              <div class='select'>
                <select id='card' onChange={(e) => this.selectCard(e)}>
                  {cards.map((el) => this.renderCard(el))}
                </select>
              </div>
            </div>
          }
          <PreviewMap trip={() => trip}/>
          <div class='buttons'>
            { (cards.length < 1) &&
              <button class='button fixed' type='button' disabled={showWidget} onClick={() => this.setState({showWidget: true}) }>+ {i18n.cards.add}</button>
            }
            { this.renderBonus() }
            { (cards.length > 0) &&
              <button class='button fixed' type='button' value={trip.bonus} disabled={submitDisabled} onClick={this.createTrip}>{i18n.confirm_trip.go}</button>
            }
            { showWidget && <Widget createCard={this.createCard} showWidget={() => this.setState({showWidget: false})}/> }
          </div>
        </section>
      </div>
    )
  }

  submitDisabled = (val) => {
    this.setState(state => {
      state.submitDisabled = val
      return state
    })
  }

  showLoader = (val) => {
    this.setState({showLoader: val})
  }

  renderCard = (card) => {
    return(<option value={card.id} key={card.id}>{card.pan} - {card.type}</option>)
  }

  selectCard = (event) => {
    this.setState({card_id: event.target.value})
  }

  renderBonus = () => {
    const { trip, bonus_trips } = this.props

    if (bonus_trips().some((e) => e.status == 1) && !trip.id) {
      return(<button class='button fixed bonus' type='button' disabled={this.state.submitDisabled} onClick={this.createTrip} value='true'>{i18n.confirm_trip.bonus}</button>)
    }
  }

  createTrip = (e) => {
    this.setState({bonus: e.target.value}, () => {
      this.create()
    })
  }
}
