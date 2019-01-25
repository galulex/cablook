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
        osrm: true
      },
      entrance: Array.from({length: 15}, (v, k) => `${k + 1} ${i18n.current_trip.entrance}`),
      new: false
    }
    this.setAddress = this.setAddress.bind(this)
  }

  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
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
    })
  }

  setComment = (e) => {
    let state = this.state
    state.trip.comment = e.target.value
    this.setState(state);
  }

  build = (e) => {
    let component = this
    const params = this.state.trip
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    params.waypoints = params.waypoints.slice(1, -2)
    params.stops = params.stops.slice(1, -2)

    axios.post('trips/new', {trip: params}).then((res) => {
      component.setState({trip: res.data, new: true})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  create = (e) => {
    const params = this.state.trip
    let component = this
    axios.post('trips', {trip: component.state.trip}).then((res) => {
      localStorage.setItem('trip', res.data.id)
      component.setState({trip: res.data})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  render() {
    if (!this.state.new && !this.state.trip.id) {
      return(
        <section class="home">
          <header>{i18n.current_trip.header}</header>
          <form action='#'>
            <div class='addresses'>
              { this.state.trip.stops.map((e, i) => {
                return(<AddressInput setAddress = {this.setAddress.bind(this)} removeAddress = { this.removeAddress.bind(this) } index = {i} />)
              })}
              <div>
                <Add width='32px' class='add-address' onClick={this.addAddress}/>
                <button type='button' onClick={this.addAddress} class='add-address'>{ i18n.current_trip.add_address }</button>
              </div>
            </div>
            <div class='nocall'>
              <input id='nocall' type='checkbox'/>
              <label for='nocall'>
                No Call
              </label>
            </div>
            <label for='entrance'>
              <span>Where to pick?</span>
              <select id='entrance'>
                <option value=''>{i18n.current_trip.select_entrance}</option>
                {this.state.entrance.map((el) => {
                  return(<option value={el}>{el}</option>)
                })}
              </select>
            </label>
            <label for='time'>
              <span>When?</span>
              <input id='time' type='time' step='600' placeholder='Now'/>
            </label>
            <input type='text' class='comment' placeholder={i18n.current_trip.comment} onInput={this.setComment}/>
            <input type='submit' class='submit' onClick={this.build} value='OK'/>
          </form>
        </section>
      )
    } else {
      return(
        <button type='button' class='submit' onClick={this.create}>Go</button>
      )
    }
  }
}
