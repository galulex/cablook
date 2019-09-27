import { h, render, Component } from 'preact'
import axios from 'axios'

import i18n from './i18n.js'
import './css/map.css'
import PreviewMap from './map/preview_map.js'
import AddressInput from '../pwa/trips/address-input.js';
import Add from './images/+.svg'
import Entrance from './images/entrance.svg'
import Clock from './images/trip_time.svg'
import Card from './images/credit-cards-payment.svg'
import Phone from './images/phone_crossed.svg'
import Comment from './images/contacts.svg'
import Arrows from './images/arrows.svg'
import './css/new_design.css'
import './css/range.css'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './lib/constants.js'

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()
const pathColor = (localStorage.getItem('dark') === 'true') ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
const ENTRANCES = Array.from({length: 15}, (v, k) => (k+1))

export default class NewDesign extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: this.props.trip || {stops: ['', ''], waypoints: [], osrm: true},
      subscription: null,
      car_location: null,
      picker: null,
      cars_locations: []
    }
  }

  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
      return state
    })
    this.updateTrip()
    this.build()
  }

  addAddress = () => {
    this.setState(state => {
      state.trip.stops.push('');
    })
  }

  updateTrip = () => {
    this.setState(state => {
      state.trip.departure = state.trip.waypoints[0]
      state.trip.destination = state.trip.waypoints[state.trip.waypoints.length - 1]
      state.trip.departure_address = state.trip.stops[0]
      state.trip.destination_address = state.trip.stops[state.trip.stops.length - 1]
      return state
    })
  }

  removeAddress = (index) => {
    this.setState(state => {
      state.trip.stops.splice(index, 1);
      state.trip.waypoints.splice(index, 1);
      return state
    })
    this.updateTrip()
    this.build()
  }

  eraseAddress = (index) => {
    if (this.state.trip.stops[index] === '') return this.removeAddress(index)
    this.setState(state => {
      state.trip.stops[index] = '';
      state.trip.waypoints[index] = '';
      delete state.trip.path
      return state
    })
    this.updateTrip()
    this.build()
  }

  get isValid() {
    return (!this.state.trip.stops.includes('') && this.state.trip.stops.length > 1 && !this.state.trip.waypoints.includes(''))
  }

  build = (e) => {
    let params = {...this.state.trip}
    if (!this.isValid) return;
    params.waypoints = params.waypoints.slice(1, -1)
    params.stops = params.stops.slice(1, -1)
    axios.post('trips/new', {trip: params}).then((res) => {
      this.setState(state => {
        state.trip.path = res.data.path
        state.trip.cost = res.data.cost
        return state
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  pickAddress = (i) => {
    if (this.state.picker !== null) return this.setState({picker: null, klass: ''})
    this.setState({picker: i, klass: 'pick'})
  }

  componentDidMount() {
  }

  scroll = val => {
    this.fields.scrollTo({left: this.fields.scrollWidth/val, behavior: 'smooth'})
  }

  setOrderTime = (e) => {
    this.state.trip.time = (e.target.value == '' ? null : e.target.value)
    this.setState(this.state);
  }

  render() {
    const { trip } = this.state
    const cards = this.props.cards()
    let isValid = trip.stops.includes('')
    let cost = (trip.cost) ? `${trip.cost} ${i18n.grn}` : ''

    return(
      <section class={`new_design ${this.state.klass}`}>
        <style>{`fieldset.address:nth-child(${this.state.picker + 1}) { opacity: 1;}`}</style>
        <header></header>
        <PreviewMap trip={() => trip} isValid={this.isValid} language={this.props.language} picker={this.state.picker} setAddress={this.setAddress} zoom={this.state.zoom}/>
        <div class='wrapper'>
          <div id='fields' class='options' ref={fields => this.fields = fields}>
            <button class='trigger' onClick={ () => this.scroll(1) }>
              <Arrows width='50'/>
            </button>
            <button class='trigger back' onClick={ () => this.scroll(1000) }>
              <Arrows width='50'/>
            </button>
            <div class='option'>
              { trip.stops.map((e, i) => {
                return (
                  <AddressInput
                    setAddress={this.setAddress}
                    eraseAddress={this.eraseAddress}
                    favorite_addresses={this.props.favorite_addresses}
                    language={this.props.language}
                    coords={trip.waypoints[i]}
                    readonly={!!trip.id && i == 0}
                    address={e}
                    index={i}
                    fieldsCount={trip.stops.length}
                    pickAddress={this.pickAddress}
                  />
                )
              })}
              <div>
                <button type='button' onClick={this.addAddress} class='add-address' disabled={isValid} title={ i18n.current_trip.add_address }>
                  <Add height='40'/>
                </button>
              </div>
            </div>
            <div class='option'>
              <div class='additions'>
                <label for='nocall' class='nocall'>
                  <input id='nocall' type='checkbox' checked={trip.no_call} onChange={this.setNoCall}/>
                  <Phone width='24' class='cross'/>
                  {i18n.current_trip.no_call}
                </label>
                <label for='entrance'>
                  <Entrance height='27'/>
                  <select id='entrance' value={trip.entrance} onChange={(e) => this.setEntrance(e)}>
                    <option value=''>{i18n.current_trip.select_entrance}</option>
                    {ENTRANCES.map((el) => {
                      return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
                    })}
                  </select>
                </label>
                <label for='time' data-placeholder={!trip.time}>
                  <Clock width='24'/>
                  <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]' value={trip.time} placeholder='Now' onChange={this.setOrderTime}/>
                  <span class='time-placeholder'>{i18n.current_trip.now}</span>
                </label>{' '}
                <label class='select' for='card'>
                  <Card width='24'/>
                  <select id='card' onChange={(e) => this.selectCard(e)}>
                    {cards.map(card => <option value={card.id}>{card.pan}</option>)}
                  </select>
                </label>
              </div>
              <label for='comment'>
                <Comment width='24'/>
                <input id='comment' type='text' class='comment' value={trip.comment} placeholder={i18n.current_trip.comment} onChange={this.setComment}/>
              </label>
            </div>
          </div>
        </div>
        <button class='button fixed' type='button' value={trip.bonus} disabled={!this.isValid} onClick={this.createTrip}>{`${i18n.confirm_trip.go} ${cost}`}</button>
        { (this.state.picker !== null) && <button type='button' class='button fixed' onClick={this.pickAddress}>OK</button> }
      </section>
    )
  }
}

