import { h, render, Component } from 'preact';
import axios from 'axios';

import MapImg from './map_img.js'
import i18n from './i18n.js'
import './css/confirm_trip.css'
import Back from './images/arrow-left.svg'

export default class ConfirmTrip extends Component {
  constructor(props) {
    super(props)
    this.state = {
      cards: this.props.cards(),
      card_id: null
    }
  }

  componentDidMount() {
    history.pushState(null, 'Confirm Trip','/pwa')
    window.addEventListener('popstate', this.props.handleBack, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.props.handleBack, true)
    }
  }

  componentWillReceiveProps() {
    this.setState({cards: this.props.cards()})
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.props.handleBack, true);
  }

  create = (e) => {
    let params = this.props.trip
    params.card_id = this.state.card_id
    axios.post('trips', {trip: params}).then((res) => {
      // localStorage.setItem('trip', res.data.id)
      this.props.updateTrip(res.data)
      window.removeEventListener('popstate', this.props.handleBack, true);
      // window.history.back()
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    return (
      <section class='confirm_trip'>
        <header>{i18n.confirm_trip.header}</header>
        <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
        <div class='details'>
          <br/>{i18n.confirm_trip.cost}{i18n.confirm_trip.dots}<b id='trip_cost'>{this.props.trip.cost}{i18n.confirm_trip.currency}</b>
          <br/>{i18n.confirm_trip.distance}{i18n.confirm_trip.dots}<b id='trip_distance'>{(this.props.trip.distance/1000).toFixed(1)}{i18n.confirm_trip.km}</b>
        </div>
        <div class='card_select'>
          <label for='card'>{i18n.confirm_trip.card}</label>
          <select onChange={(e) => this.selectCard(e)}> 
            {this.state.cards.map((el) => this.renderCard(el))}
          </select>
        </div>
        <div class='map'>
          <MapImg trip={() => this.props.trip} />
          <button class='add-card' type='button'>{i18n.confirm_trip.bonus}</button>
          <button class='add-card' type='button' onClick={this.create}>{i18n.confirm_trip.go}</button>
        </div>
      </section>
    )
  }

  renderCard = (card) => {
    return(<option value={card.id} key={card.id}>{card.pan} - {card.type}</option>)
  }

  selectCard = (event) => {
    this.setState({card_id: event.target.value})
  }
}
