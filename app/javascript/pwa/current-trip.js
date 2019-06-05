import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import AddressInput from '../pwa/trips/address-input.js';
import Add  from './images/add.svg'
import Back from './images/arrow-left.svg'
import './css/current_trip.css'

export default class CurrentTrip extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: this.getTrip(),
      submitDisabled: false,
      entrance: Array.from({length: 15}, (v, k) => (k+1))
    }
  }

  componentDidMount() {
    history.pushState(null, 'Edit Trip', '/')
    window.addEventListener('popstate', this.props.getTripRequest, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.props.getTripRequest)
    }
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.props.getTripRequest);
  }

  getTrip = () => {
    if (this.props.trip !== null && this.props.trip.status !== 7) {
      let trip = {...this.props.trip}
      trip.stops.unshift(trip.departure_address)
      trip.stops.push(trip.destination_address)
      trip.departure = trip.departure.join()
      trip.destination = trip.destination.join()
      trip.waypoints.unshift(trip.departure)
      trip.waypoints.push(trip.destination)
      trip.osrm = true
      return trip
    } else {
      return { waypoints: [],
        stops: ['',''],
        departure: '',
        destination: '',
        departure_address: '',
        destination_address: '',
        no_call: false,
        entrance: null,
        time: null,
        osrm: true,
        comment: '' }
    }
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

  eraseAddress = (index) => {
    if (this.state.trip.stops[index] === '') {
      this.removeAddress(index)
    } else {
      this.setState(state => {
        state.trip.stops[index] = '';
        state.trip.waypoints[index] = '';
        return state
      })
      this.updateTrip()
    }
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
      if (res.data.id) res.data.status = 10
      this.props.updateTrip(res.data)
      window.removeEventListener('popstate', this.props.getTripRequest);
    }).catch((error) => {
      this.submitDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  submitDisabled = val => {
    this.setState({ submitDisabled: val })
  }

  renderTripData = () => {
    const { trip } = this.state
    if (trip.id) return;
    return [
      <div class='nocall'>
        <input id='nocall' type='checkbox' checked={trip.no_call} onChange={this.setNoCall}/>
        <label for='nocall'>
          {i18n.current_trip.no_call}
        </label>
      </div>,
      <label for='entrance'>
        <span>{i18n.current_trip.where_to_pick}</span>
        <select id='entrance' value={trip.entrance} onChange={(e) => this.setEntrance(e)}>
          <option value=''>{i18n.current_trip.select_entrance}</option>
          {this.state.entrance.map((el) => {
            return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
          })}
        </select>
      </label>,
      <label for='time'>
        <span>{i18n.current_trip.when}</span>
        <input id='time' type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]' value={trip.time} placeholder='Now' onChange={this.setOrderTime}/>
      </label>,
      <input type='text' class='comment' value={trip.comment} placeholder={i18n.current_trip.comment} onChange={this.setComment}/>
    ]
  }

  renderBackButton = () => {
    return (<button type='button' id='arrow' class='burger' onClick={() => window.history.back()}><Back/></button>)
  }

  render() {
    const { trip, trip: { stops } } = this.state
    let isValid = (stops.includes(''))

    return(
      <section class="home">
        {!!trip.id && this.renderBackButton()}
        <header>{i18n.current_trip.header}</header>
        <form action='#' onSubmit={(e) => e.preventDefault()}>
          <div class='addresses'>
            { trip.stops.map((e, i) => {
              return (
                <AddressInput
                  setAddress={this.setAddress}
                  eraseAddress={this.eraseAddress}
                  favorite_addresses={() => this.props.favorite_addresses}
                  language={this.props.language}
                  coords={trip.waypoints[i]}
                  readonly={!!trip.id && i == 0}
                  address={e}
                  index={i}
                  fieldsCount={stops.length}
                />
              )
            })}
            <div>
              <Add width='32px' class='add-address' onClick={this.addAddress} disabled={isValid}/>
              <button type='button' onClick={this.addAddress} class='add-address' disabled={isValid}>{ i18n.current_trip.add_address }</button>
            </div>
          </div>
          {this.renderTripData()}
          <input type='submit' disabled={this.state.submitDisabled} class='button' onClick={this.build} value='OK'/>
        </form>
      </section>
    )
  }
}
