import { h, render, Component } from 'preact'
import mapboxgl from 'mapbox-gl'
import axios from 'axios'

import { streets } from '../streets.js'
import Pin from '../images/pin.js'
import MapPicker from '../mapPicker'
import i18n from '../i18n.js'
import Cablook  from '../images/cablook.svg'
import Target from '../images/target.svg'
import Location  from '../images/target.svg'

let burgers, headers

export default class AddressInput extends Component {
  constructor(props) {
    super(props)
    this.state = {
      predictions: [],
      address: props.address || '',
      isValid: false,
      isShowMap: false,
      disabled: false,
      isFetching: false
    }
  }

  componentDidMount() {
    this.input.setCustomValidity(this.state.address ? '' : i18n.choose_address)
  }

  componentWillReceiveProps(nextProps) {
    if ((nextProps.address || nextProps.address === '') && this.state.address === this.props.address) this.setState({address: nextProps.address})
  }

  componentWillUnmount() {
    if (window.timeout && this.props.index === 0) clearTimeout(window.timeout)
  }

  favoriteAddressesPredictions = () => {
    let fav = []
    if (this.props.currentLocation) {
      fav.push(this.props.currentLocation)
    }
    {this.props.favorite_addresses().map((el) => {
      fav.push({location: el.location,
                address: el.address,
                favorite_address: true,
                structured_formatting: { main_text: el.address, secondary_text: el.name }})
      })
    }
    this.setState({predictions: fav})
  }

  renderPrediction = (prediction) => {
    return(
      <li disabled={this.state.disabled} onClick={() => this.setLocation(prediction)} class={prediction === this.props.currentLocation ? 'prediction current_location' : 'prediction'}>
        {prediction === this.props.currentLocation ? <Target/> : <Cablook width='32px'/>}
        <b>{(prediction.structured_formatting) ? prediction.structured_formatting.main_text : prediction}</b>
        <br/>
        <sub>{(prediction.structured_formatting) ? prediction.structured_formatting.secondary_text : 'Cherkasy'}</sub>
      </li>
    )
  }

  setLocation = (place) => {
    if (place.favorite_address) {
      this.setState({ address: place.address, predictions: [], isValid: true })
      this.props.setAddress(place.address, place.location, this.props.index)
      this.input.setCustomValidity('')
      return
    }

    if (!place.place_id) {
      this.setState({ address: `${place}, `, predictions: [], isValid: false })
      this.input.focus()
      setTimeout(() => { this.input.scrollLeft = 500 }, 100)
      return
    }

    this.setState({isFetching: true})
    let placeService = new google.maps.places.PlacesService(document.createElement('div'))
    placeService.getDetails({placeId: place.place_id, fields: ['geometry']}, (result) => {
      this.setState({ address: place.structured_formatting.main_text, predictions: [], isValid: true })
      this.props.setAddress(place.structured_formatting.main_text, `${result.geometry.location.lat()},${result.geometry.location.lng()}`, this.props.index)
      this.setState({isFetching: false})
      this.input.setCustomValidity('')
    })
  }

  autocomplete = e => {
    if (e.target.value === '') {
      this.setState({ predictions: [], address: e.target.value})
      this.favoriteAddressesPredictions()
      return false
    }
    this.input.setCustomValidity(i18n.choose_address)
    let hits = streets.filter(function(s) { return s.toLowerCase().indexOf(e.target.value.toLowerCase()) != -1 }).slice(0, 5)

    if (hits.length > 0) {
      this.setState({ predictions: hits, address: e.target.value, disabled: false })
      return false
    }
    if (!window.google) {
      return this.setState({ predictions: [i18n.address_input.no_result], address: e.target.value, disabled: true })
    }
    let autocomplete = new google.maps.places.AutocompleteService()
    this.setState({ predictions: [i18n.address_input.loading], address: e.target.value, disabled: true })
    autocomplete.getPlacePredictions({input: e.target.value + ' Cherkasy', componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 100000, strictbounds: true, offset: 2}, data => {
      if (!data) return this.setState({ predictions: [i18n.address_input.no_result], address: e.target.value, disabled: true })
      this.setState({ predictions: data, address: e.target.value, disabled: false })
    })
  }

  toggleElements = () => {
    const burgers = document.getElementsByClassName('burger')
    const headers = document.querySelectorAll('header')
    if (burgers.length <= 1 && headers.length <= 1) return
    if (burgers[0].classList.contains('hidden') && headers[0].classList.contains('hidden')) {
      burgers[0].classList.remove('hidden')
      headers[0].classList.remove('hidden')      
    } else {
      burgers[0].classList.add('hidden')
      headers[0].classList.add('hidden')
    }
  }

  openMap = (event) => {
    if (this.props.pickAddress) {
      event.target.classList.add('current')
      this.props.pickAddress(this.props.index)
      return
    }
    this.setState({isShowMap: true}, () => { this.toggleElements() })
    if (window.ios) return
    history.pushState(null, null,'/')
    window.addEventListener('popstate', this.handleBack, {once: true})
  }

  closeMap = (point, address) => {
    this.props.setAddress(address, point, this.props.index)
    this.setState({ address: address, predictions: [], isValid: true, isShowMap: false })
    this.input.setCustomValidity('')
  }

  focus = (e) => {
    const fields = document.getElementById('fields')
    this.input.classList.add('focus')
    if (this.state.address == '') this.favoriteAddressesPredictions()
    // e.target.focus()
    if (window.timeout) clearTimeout(window.timeout)
    if (fields) fields.classList.add('noscroll')
  }

  blur = (e) => {
    const fields = document.getElementById('fields')
    this.input.classList.remove('focus')
    window.timeout = setTimeout(() => {
      if (e.target.value === '' ||  e.target.checkValidity() || this.state.disabled || this.state.isFetching) return
      let prediction = this.state.predictions[0]
      if (prediction) this.setLocation(prediction)
    }, 500)
    if (fields) {
      window.timeout = setTimeout(() => { fields.classList.remove('noscroll') }, 300)
    }
  }

  handleBack = (event) => {
    this.setState({isShowMap: false})
    if (event) { event.stopPropagation() }
  }

  keydown = (e) => {
    let prediction = this.state.predictions[0]
    if (![13, 9].includes(e.which) || !prediction || this.state.disabled) return
    this.setLocation(prediction)
    if (!prediction.place_id) e.preventDefault()
  }

  setPlaceholder = () => {
    if (this.props.placeholder) return this.props.placeholder
    return (this.props.index !== 0) ? i18n.address_input.where : i18n.address_input.from
  }

  eraseAddress =  () => {
    if (this.state.address !== '') setTimeout(() => { this.input.focus() }, 300)
    this.props.eraseAddress(this.props.index)
  }

  render() {
    let placeholder = this.setPlaceholder()

    const { fieldsCount, address, index, readonly, language, hideRemove, inputDisabled, geocode } = this.props
    return (
      <fieldset class='address'>
        {(fieldsCount > 2 || address !== '') && !hideRemove && !readonly && (<button disabled={index === 0 ? inputDisabled : false} class='remove-address' type='button' onClick={() => this.eraseAddress(index)}>×</button>)}
        {mapboxgl.supported() && <Pin onClick={this.openMap} disabled={readonly || ( index === 0 ? inputDisabled : false )} class='map-pick'/>}
        {this.state.isShowMap && <MapPicker
                                    onCloseMap={this.closeMap}
                                    handleBack={this.handleBack}
                                    language={language}
                                    geocode={geocode}
                                    isGeocoding={this.props.isGeocoding}
                                    setGeocoding={this.props.setGeocoding}
                                    toggleElements={this.toggleElements}
                                  /> }

        <input required class='address' placeholder={placeholder} type='text' disabled={index === 0 ? inputDisabled : false}
          onClick={this.focus} onFocus={this.focus} onKeyDown={this.keydown} onBlur={this.blur} onInput={this.autocomplete}
          value={this.state.address} ref={input => this.input = input} readonly={readonly}
        />

        <ul class='predictions'>
          { this.state.predictions.map(this.renderPrediction) }
        </ul>
      </fieldset>
    )
  }
}
