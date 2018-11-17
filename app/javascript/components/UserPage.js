import React, { Component } from 'react'
import Session from './Session'
import Trip from './Trip'
import Localization from '../localization/Localization'

export default class UserPage extends Component {
  constructor(props){
    super(props)
    this.state = {
      waypoints: [
        {
          id: 0,
          idEl: 'departure_address',
          df: 'departure',
          placeholder: `${Localization.user_page.from}`,
          predictions: []
        },
        {
          id: 1,
          idEl: 'destination_address',
          df: 'destination',
          placeholder: `${Localization.user_page.to}`,
          predictions: []
        }
      ],
      time_select: Array(24 * 6).fill(0).map((_, i) => { return ('0' + ~~(i / 6) + ':0' + Math.round(60  * (i / 6 % 1))).replace(/\d(\d\d)/g, '$1') }),
      entrance: Array.from({length: 15}, (v, k) => k + 1)
    }
  }

  componentDidMount = () => {
    window.addEventListener('load', this.handleLoad())
  }

  addPoint = () => {
    this.setState({waypoints: [...this.state.waypoints,
      {
        id: this.state.waypoints.length,
        idEl: this.state.waypoints[this.state.waypoints.length - 1].idEl,
        df: this.state.waypoints[this.state.waypoints.length - 1].df,
        placeholder: this.state.waypoints[this.state.waypoints.length - 1].placeholder,
        predictions: []
      }]
    })
  }

  removePoint = (event) => {
    let point = event.target.nextElementSibling
    point.parentElement.parentNode.removeChild(event.target.parentElement)
  }

  renderRemoveButton = () => {
    return (<button className='form__location-remove link' onclick={this.removePoint} type='button'>×</button>)
  }

  renderWaypoint = (id, idEl, df, placeholder, predictions) => {
    return(
      <div className='form__location' key={id} >
      {id == 0 ? (<div className="form__location-pin" onClick={this.getLocation}></div>) : null}
      <button className='form__location-remove link' onClick={this.removePoint} type='button'>×</button>
      <input autoComplete='off' className='form__location-field' data-field={df} id={idEl} name='waypoints' data-location='false' onInput={(e) => this.handleInput(e, id)} placeholder={placeholder} required type='text' />
      <ul className='form__location-list' data-list=''>
      {this.state.waypoints[id].predictions.map((el, index) => this.renderPrediction(el, index))}
      </ul>
      <span className='circle'></span>
      </div>
    )
  }

  handleSubmit = (event) => {
    event.preventDefault()
    Trip.build().then(data => {
      trip = data.data
      this.props.setPath(Trip.show())
      setTimeout(() =>
        this.props.updateStep(4), 500)
    }).catch(err =>
      alert(err.response.data.errors)
    )
  }

  handleClick = (event) => {
    this.addPoint()
  }

  handleLoad = () => {
    let input = document.querySelectorAll('input')[0]
    input.focus()
  }

  renderPrediction = (data, id) => {
    return (<li key={id} id={id} onClick={this.setLocation} data-place={data.place_id}><b>{(typeof data.structured_formatting !== "undefined") ? data.structured_formatting.main_text : data}</b><br /><span>{(typeof data.structured_formatting !== "undefined") ? data.structured_formatting.secondary_text : 'Cherkasy'}</span></li>)
  }

  handleInput = (event, id) => {
    let input = event.target
    input.nextElementSibling.hidden = false
    input.setCustomValidity('')
    input.removeAttribute('data-place')
    trip[input.id] = ''
    if (input.value.length < 1) return false
    let hits = streets.filter(function(s) { return s.toLowerCase().indexOf(input.value.toLowerCase()) != -1 }).slice(0, 5)
    console.log(hits)
    if (hits.length > 0) {
      this.setState({
        waypoints: this.state.waypoints.map((el) => el.id == id ? {...el, predictions: hits } : el)
      })
      return false
    }
    let autocomplete = new google.maps.places.AutocompleteService()
    autocomplete.getPlacePredictions({input: input.value, componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 10, strictbounds: true, offset: 2}, data => {
      this.suggestions = []
      if (!data) return false
      this.suggestions = data
      this.setState({
        waypoints: this.state.waypoints.map((el) => el.id == id ? {...el, predictions: data } : el)
      })
    })
  }

  setLocation = (event) => {
    event.preventDefault()
    let li = event.currentTarget
    let input = li.parentElement.previousElementSibling
    console.log(this.suggestions)
    input.value = li.querySelector('b').textContent + ' '
    trip[input.id] = input.value
    input.setAttribute('data-location', false)
    li.parentNode.hidden = true
    input.focus()
    if (li.getAttribute('data-place') == null) return false
    let placeService = new google.maps.places.PlacesService(document.createElement('div'))
    placeService.getDetails({placeId: li.getAttribute('data-place')}, function(result) {
      let coords = result.geometry.location
      input.setAttribute('data-place', `${coords.lat()},${coords.lng()}`)
      if (input.parentElement.nextSibling) input.parentElement.nextSibling.querySelector('input').focus()
    })
  }

  renderSelectTime = (el) => {
    return(<option value={el} key={el}>{el}</option>)
  }

  renderEntrance = (el) => {
    return(<option value={el} key={el}>{`${el} ${Localization.user_page.entrance}`}</option>)
  }

  logOut = () => {
    Session.destroy()
    this.props.updateStep(1)
  }

  noCallChecked = (e) => {
    (e.target.checked == true) ? trip.no_call = true : trip.no_call = null
  }

  handleTimeSelect = (e) => {
    (e.target.value == '') ? trip.time = null : trip.time = e.target.value
    document.querySelector('[data-time]').setAttribute('data-time', trip.time)
  }

  handleEntranceSelect = (e) => {
    (e.target.value == '') ? trip.entrance = null : trip.entrance = e.target.value
  }

  getLocation = () => {
    let field = document.getElementsByClassName('form__location-field')[0]
    let location_attr = field.getAttribute('data-location')
    if (location_attr == "false" || !(field.hasAttribute('data-place'))) {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(this.showPosition, this.showError)
      }
    }
  }

  showPosition = (position) => {
    let lat = position.coords.latitude
    let lng = position.coords.longitude
    document.getElementById('departure_address').setAttribute('data-place', `${lat},${lng}`)
    fetch(`https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&language=ru&key=AIzaSyDx2cLwlAG3muHMV9DVYY3l2PupoYCS-Mk`)
      .then(response => {
        return response.json()
      })
      .then(location => {
        this.setAddress(location)
      })
  }

  showError = (error) => {
    if (error.code == error.PERMISSION_DENIED) {
      alert(`${Localization.user_page.geo_alert}`)
    }
  }

  setAddress = (location) => {
    let result = location.results[0]
    let address = result.formatted_address.split(', ')
    let field = document.getElementsByClassName('form__location-field')[0]
    field.value = `${address[0]}, ${address[1]}`
    trip[field.id] = field.value
    field.setAttribute('data-location', true)
  }

  render (){
    return (
      <form onSubmit={this.handleSubmit} className='form'>
      <div className='form__fieldset'>
      <button className='button exit' onClick={this.logOut} type='button'>{Localization.user_page.exit}</button>
      <div className='form__user-number' id='account'>{this.props.number}</div>
      <div className='points'>
      {this.state.waypoints.map((el, index) => this.renderWaypoint(index, el.idEl, el.df, el.placeholder, el.predictions))}
      </div>
      <div className='form__first-box'>
      <button className='link add-point' id='add_point' onClick={this.handleClick} type='button'><span className='plus'></span>{Localization.user_page.add_point}</button>
      <div className='form__entrance select'>
      <label htmlFor='entrance'><span className='door'></span></label>
      <select id='entrance' name='trip[entrance]' onChange={this.handleEntranceSelect}>
      <option value=''>{Localization.user_page.entrance}</option>
      {this.state.entrance.map((el) => this.renderEntrance(el))}
      </select>
      </div>
      </div>
      <div className='form__second-box'>
      <div className='form__time-select'>
      <label htmlFor='time' className='form__tiem-label'><span className='clock' data-time='12:10'></span></label>
      <div className='select'>
      <select id='time' name='trip[time]' onChange={this.handleTimeSelect}>
      <option value=''>{Localization.user_page.start_time_placeholder}</option>
      {this.state.time_select.map((el) => this.renderSelectTime(el))}
      </select>
      </div>
      </div>
      <div className='form__no-call'>
      <label htmlFor='no_call'>{Localization.user_page.no_call}</label>
      <label className='checkbox__wrapper'>
      <input type='checkbox' id='no_call' name='trip[no_call]' onChange={this.noCallChecked}></input>
      <span className="checkbox__checkmark"></span>
      </label>
      </div>
      </div>
      <details>
      <summary><span className='comment-arrow'></span>{Localization.user_page.comment}</summary>
      <textarea id='comment' name='trip[comment]' onInput={(e) => trip.comment = e.target.chacked}></textarea>
      </details>
      <br/><button className='button' id='done' type='submit'>{Localization.user_page.submit}</button>
      </div>
      </form>
    )
  }
}
