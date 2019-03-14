import { h, render, Component } from 'preact';
import axios from 'axios';

import MapImg from './map_img.js'
import Widget from './widget.js'
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
    history.pushState(null, 'Confirm Trip','/')
    window.addEventListener('popstate', this.props.handleBack, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.props.handleBack)
    }
    this.getCards()
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
    axios.post('trips', {trip: params}).then((res) => {
      this.props.updateTrip(res.data)
      window.removeEventListener('popstate', this.props.handleBack);
    }).catch((error) => {
      if (error.response) {
        if (!confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
          this.submitDisabled(false)
          return;
        }
        this.retryPendingPayment()
      } 
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
    return (
      <div class='confirm-container'>
        {this.retryLoader()}
        <button type='button' id='arrow' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
        <header>{i18n.confirm_trip.header}</header>
        <section class='confirm-trip'>
          <div class='details'>
            <ul class='details-list'>
              <li>
                <TripPrice />
                <span>{i18n.confirm_trip.cost}</span>
                <span><b id='trip_cost'>{this.props.trip.cost} {i18n.confirm_trip.currency}</b></span>
              </li>
              <li>
                <Pin />
                <span>{i18n.confirm_trip.distance}</span>
                <span><b id='trip_distance'>{(this.props.trip.distance/1000).toFixed(1)} {i18n.confirm_trip.km}</b></span>
              </li>
            </ul>
          </div>
          { (this.state.cards.length > 0) &&
            <div class='select-section'>
              <label for='card'>{i18n.confirm_trip.card}</label>
              <div class='select'>
                <select id='card' onChange={(e) => this.selectCard(e)}>
                  {this.state.cards.map((el) => this.renderCard(el))}
                </select>
              </div>
            </div>
          }
          { (this.state.cards.length < 1) &&
              <button class='button fixed' type='button' disabled={this.state.showWidget} onClick={() => this.setState({showWidget: true}) }>+ {i18n.cards.add}</button>
          }
          <MapImg trip={() => this.props.trip} />
          <div class='buttons'>
            { this.renderBonus() }
            { (this.state.cards.length > 0) &&
              <button class='button fixed' type='button' value='false' disabled={this.state.submitDisabled} onClick={this.createTrip}>{i18n.confirm_trip.go}</button>
            }
            { this.state.showWidget && <Widget createCard={this.createCard}/> }
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
    if (this.props.bonus_trips().some((e) => e.status == 1)) {
      return(<button class='button fixed bonus' type='button' disabled={this.state.submitDisabled} onClick={this.createTrip} value='true'>{i18n.confirm_trip.bonus}</button>)
    }
  }

  retryLoader = () => {
    if (this.state.showLoader !== true) return;
    return [
      <div class='load-background'></div>,
      <SearchLogo class='search_logo'/>
    ]
  }

  createTrip = (e) => {
    this.setState({bonus: e.target.value}, () => {
      this.create()
    })
  }
}
