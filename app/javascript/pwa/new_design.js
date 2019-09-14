import { h, render, Component } from 'preact'
import axios from 'axios'

import i18n from './i18n.js'
import './css/map.css'
import PreviewMap from './map/preview_map.js'
import AddressInput from '../pwa/trips/address-input.js';
import Add  from './images/add.svg'
import './css/new_design.css'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './lib/constants.js'

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()
const pathColor = window.dark ? ['#ffffff', '#19a160'] : ['#312d50', '#19a160']
const ENTRANCES = Array.from({length: 15}, (v, k) => (k+1))

export default class NewDesign extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: this.props.trip || {stops: ['', ''], waypoints: []},
      subscription: null,
      car_location: null,
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

  pickAddress = (address) => {
    console.log(1)
  }

  render() {
    const { trip } = this.state
    let isValid = trip.stops.includes('')
    let cost = (trip.cost) ? `${trip.cost} ${i18n.grn}` : ''

    return(
      <section class='new_design'>
        <header></header>
        <div class='header'>
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
              <Add width='40px'/>
            </button>
          </div>
        </div>
        <PreviewMap trip={() => trip} isValid={this.isValid} language={this.props.language}/>
        <div class='options'>
          <div class='nocall'>
            <input id='nocall' type='checkbox' checked={trip.no_call} onChange={this.setNoCall}/>
            <label for='nocall'>
              {i18n.current_trip.no_call}
            </label>
          </div>
          <label for='entrance'>
            <select id='entrance' value={trip.entrance} onChange={(e) => this.setEntrance(e)}>
              <option value=''>{i18n.current_trip.select_entrance}</option>
              {ENTRANCES.map((el) => {
                return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
              })}
            </select>
          </label>
        </div>
        <button class='button fixed' type='button' value={trip.bonus} disabled={!this.isValid} onClick={this.createTrip}>{`${i18n.confirm_trip.go} ${cost}`}</button>
      </section>
    )
  }
}

