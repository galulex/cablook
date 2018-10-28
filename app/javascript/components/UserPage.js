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
      ]
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
        <button className='form__location-remove link' onClick={this.removePoint} type='button'>×</button>
        <input autoComplete='off' className='form__location-field' data-field={df} id={idEl} name='waypoints' onInput={(e) => this.handleInput(e, id)} placeholder={placeholder} required type='text' />
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
    return (<li key={id} id={id} onClick={this.setLocation} data-place={data.place_id}><b>{data.structured_formatting.main_text}</b><br /><span>{data.structured_formatting.secondary_text}</span></li>)
  }

  handleInput = (event, id) => {
    let input = event.target
    input.nextElementSibling.hidden = false
    input.setCustomValidity('')
    input.removeAttribute('data-place')
    trip[input.id] = ''
    if (input.value.length == 0) return false
    let service = new google.maps.places.AutocompleteService()
    service.getPlacePredictions({input: input.value, componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 10, strictbounds: true, offset: 3}, data => {
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
    let i = Array.prototype.indexOf.call(li.parentElement.children, li)
    let input = li.parentElement.previousElementSibling 
    input.value = this.suggestions[i].structured_formatting.main_text + ' '
    trip[input.id] = input.value
    input.setAttribute('data-place', li.getAttribute('data-place'))
    li.parentNode.hidden = true
    input.focus()
  }

  logOut = () => {
    Session.destroy()
    this.props.updateStep(1)
  }

	render (){
		return (
      <form onSubmit={this.handleSubmit} className='form'>
        <div className='form__fieldset'>
          <button className='button exit' onClick={this.logOut} type='button'>{Localization.user_page.exit}</button> 
          <div className='form__user-number' id='account'>{this.props.number}</div>
          <div className='points'>
              {this.state.waypoints.map((el, index) => this.renderWaypoint(index, el.idEl, el.df, el.placeholder, el.predictions))}
              <button className='link add-point' id='add_point' onClick={this.handleClick} type='button'><span className='plus'></span>{Localization.user_page.add_point}</button>
          </div>
          <details>
              <input type='time' id='start_time' name='trip[start_time]' onInput={(e) => trip.start_time = e.target.value}></input>
              <summary><span className='comment-arrow'></span>{Localization.user_page.comment}</summary>
              <textarea id='comment' name='trip[comment]' onInput={(e) => trip.comment = e.target.value}></textarea>
          </details>
          <br/><button className='button' id='done' type='submit'>{Localization.user_page.submit}</button>
        </div>
      </form>
		)
	}
}