import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import AddressInput from '../pwa/trips/address-input.js';
import Add  from './images/add.svg'
import './css/current_trip.css'

export default class CurrentTrip extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: {
        waypoints: [],
        stops: ['', ''],
        departure: '',
        destination: '',
        departure_address: '',
        destination_address: '',
        no_call: false,
        entrance: null,
        time: null,
        osrm: true,
        comment: ''
      },
      submitDisabled: false,
      entrance: Array.from({length: 15}, (v, k) => `${k + 1} ${i18n.current_trip.entrance}`)
    }
  }

  componentDidMount() {
    if (this.props.trip !== null) {
      this.setState({trip: this.props.trip})
      this.setPoints(this.state.trip)
    }
  }

  setPoints = (address) => {
    let trip = this.state.trip
    trip.stops.unshift(address.departure_address)
    trip.stops.push(address.destination_address)
    trip.waypoints.unshift(address.departure.join())
    trip.waypoints.push(address.destination.join())
    trip.osrm = true
    this.updateTrip(trip)
  }


  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
      return state
    })
    this.updateTrip()
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

  addAddress = () => {
    this.setState(state => {
      state.trip.stops.push('');
    })
  }

  removeAddress = (index) => {
    this.setState(state => {
      state.trip.stops.splice(index, 1);
      state.trip.waypoints.splice(index, 1);
      return state
    })
    this.updateTrip()
  }

  setComment = (e) => {
    let state = this.state
    state.trip.comment = e.target.value
    this.setState(state);
  }

  setNoCall = (e) => {
    (e.target.checked == true) ? this.state.trip.no_call = true : this.state.trip.no_call = false
    this.setState(this.state);
  }

  setEntrance = (e) => {
    this.state.trip.entrance = e.target.value
    this.setState(this.state);
  }

  setOrderTime = (e) => {
    this.state.trip.time = (e.target.value == '' ? null : e.target.value)
    this.setState(this.state);
  }

  build = (e) => {
    let params = {...this.state.trip}
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    this.submitDisabled(true)
    params.waypoints = params.waypoints.slice(1, -1)
    params.stops = params.stops.slice(1, -1)
    axios.post('trips/new', {trip: params}).then((res) => {
      this.props.updateTrip(res.data)
    }).catch((error) => {
      this.submitDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  submitDisabled = val => {
    this.setState(state => {
      state.submitDisabled = val
      return state
    })
  }

  render() {
    let trip = this.state.trip
    let isValid = (this.state.trip.stops.includes(''))
    return(
      <section class="home">
        <header>{i18n.current_trip.header}</header>
        <form action='#' onSubmit={(e) => e.preventDefault()}>
          <div class='addresses'>
            { this.state.trip.stops.map((e, i) => {
              return(<AddressInput setAddress = {this.setAddress} removeAddress = { this.removeAddress } favorite_addresses = {() => this.props.favorite_addresses} language={this.props.language} coords = {this.state.trip.waypoints[i]} address = {e} index = {i} />)
            })}
            <div>
              <Add width='32px' class='add-address' onClick={this.addAddress} disabled={isValid}/>
              <button type='button' onClick={this.addAddress} class='add-address' disabled={isValid}>{ i18n.current_trip.add_address }</button>
            </div>
          </div>
          <div class='nocall'>
            <input id='nocall' type='checkbox' checked={this.state.trip.no_call} onChange={this.setNoCall}/>
            <label for='nocall'>
              {i18n.current_trip.no_call}
            </label>
          </div>
          <label for='entrance'>
            <span>{i18n.current_trip.where_to_pick}</span>
            <select id='entrance' value={this.state.trip.entrance} onChange={(e) => this.setEntrance(e)}>
              <option value=''>{i18n.current_trip.select_entrance}</option>
              {this.state.entrance.map((el) => {
                return(<option value={el}>{el}</option>)
              })}
            </select>
          </label>
          <label for='time'>
            <span>{i18n.current_trip.when}</span>
            <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]' value={this.state.trip.time} placeholder='Now' onChange={this.setOrderTime}/>
          </label>
          <input type='text' class='comment' value={this.state.trip.comment} placeholder={i18n.current_trip.comment} onChange={this.setComment}/>
          <input type='submit' disabled={this.state.submitDisabled} class='button' onClick={this.build} value='OK'/>
        </form>
      </section>
    )
  }
}
