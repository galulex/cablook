import { h, render, Component } from 'preact';
import mapboxgl from 'mapbox-gl'
import axios from 'axios';

import { streets } from '../streets.js'
import Pin from '../images/pin.svg'
import MapPicker from '../mapPicker'
import i18n from '../i18n.js'
import Cablook  from '../images/cablook.svg'
import Location  from '../images/target.svg'

export default class AddressInput extends Component {
  constructor(props) {
    super(props);
    this.state = {
      predictions: [],
      address: props.address || '',
      isValid: false,
      isShowMap: false,
      geocoded: false,
      disabled: false,
      isFetching: false
    }
  }

  componentDidMount() {
    this.input.setCustomValidity(this.state.address ? '' : i18n.choose_address)
    // if (this.props.index === 0) window.geolocate = this.getLocation
    if (this.props.index === this.props.fieldsCount - 1) this.input.focus()
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.address || nextProps.address === '') this.setState({address: nextProps.address})
  }

  componentWillUnmount() {
    if (window.timeout) clearTimeout(window.timeout)
  }

  favoriteAddressesPredictions = () => {
    let fav = [];
    {this.props.favorite_addresses().map((el) => {
      fav.push({location: el.location,
                address: el.address,
                favorite_address: true,
                structured_formatting: { main_text: el.address, secondary_text: el.name }})
      })
    };
    this.setState({predictions: fav})
  }

  renderPrediction = (prediction) => {
    return(
      <li disabled={this.state.disabled} onClick={() => this.setLocation(prediction)} class='prediction'>
        <Cablook width='32px'/>
        <b>{(prediction.structured_formatting) ? prediction.structured_formatting.main_text : prediction}</b>
        <br/>
        <sub>{(prediction.structured_formatting) ? prediction.structured_formatting.secondary_text : 'Cherkasy'}</sub>
      </li>
    )
  }

  getLocation = (e) => {
    let component = this
    if (navigator.geolocation) {
      // e.target.classList.add('running')
      navigator.geolocation.getCurrentPosition((result) => {
        let geocoder = new google.maps.Geocoder()
        let location = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)
        geocoder.geocode( { 'location': location}, function(res, status) {
          if (status == 'OK') {
            let place = res[0]
            component.setState({ address: `${place.address_components[1].long_name}, ${place.address_components[0].long_name}`, predictions: [], isValid: true, geocoded: true });
            component.props.setAddress(`${place.address_components[1].long_name}, ${place.address_components[0].long_name}`, `${place.geometry.location.lat()},${place.geometry.location.lng()}`, component.props.index);
            component.input.setCustomValidity('')
          } else {
            alert(status)
          }
        })
        // e.target.classList.remove('running')
      },
        (error) => {
          // e.target.classList.remove('running')
          switch(error.code) {
            case error.PERMISSION_DENIED :
              console.log(i18n.location.permission_denied);
              break;
            case error.TIMEOUT:
              alert(i18n.location.timeout);
              break;
            case error.POSITION_UNAVAILABLE :
              alert(i18n.location.position_unavailable);
              break;
            default:
              alert(error.message)
              break;
          }
        }
      )
    }
  }

  setLocation = (place) => {
    if (place.favorite_address) {
      this.setState({ address: place.address, predictions: [], isValid: true });
      this.props.setAddress(place.address, place.location, this.props.index);
      this.input.setCustomValidity('');
      return;
    }

    if (!place.place_id) {
      this.setState({ address: `${place}, `, predictions: [], isValid: false });
      this.input.focus();
      return;
    }

    this.setState({isFetching: true})
    let placeService = new google.maps.places.PlacesService(document.createElement('div'));
    placeService.getDetails({placeId: place.place_id}, (result) => {
      this.setState({ address: place.structured_formatting.main_text, predictions: [], isValid: true });
      this.props.setAddress(place.structured_formatting.main_text, `${result.geometry.location.lat()},${result.geometry.location.lng()}`, this.props.index);
      this.setState({isFetching: false})
      this.input.setCustomValidity('')
    })
  }

  setLocationFromMap = ([lng, lat]) => {
    const latlng = {lat, lng};
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({'location': latlng}, (results, status) => {
      if (status === 'OK') {
        if (results[0]) {
          this.setState({ address: `${results[0].address_components[1].long_name}, ${results[0].address_components[0].long_name}`, predictions: [], isValid: true });
          this.props.setAddress(`${results[0].address_components[1].long_name}, ${results[0].address_components[0].long_name}`, `${lat},${lng}`, this.props.index);
          this.input.setCustomValidity('')
        } else {
          window.alert('No results found');
        }
      } else {
        window.alert('Geocoder failed due to: ' + status);
      }
    });
  }

  autocomplete = e => {
    if (e.target.value === '') {
      this.setState({ predictions: [], address: e.target.value});
      this.favoriteAddressesPredictions()
      return false
    }
    this.input.setCustomValidity(i18n.choose_address)
    let hits = streets.filter(function(s) { return s.toLowerCase().indexOf(e.target.value.toLowerCase()) != -1 }).slice(0, 5)
    if (hits.length > 0) {
      this.setState({ predictions: hits, address: e.target.value, disabled: false });
      return false
    }
    let autocomplete = new google.maps.places.AutocompleteService()
    this.setState({ predictions: [i18n.address_input.loading], address: e.target.value, disabled: true })
    autocomplete.getPlacePredictions({input: e.target.value + ' Cherkasy', componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 100000, strictbounds: true, offset: 2}, data => {
      if (!data) return this.setState({ predictions: [i18n.address_input.no_result], address: e.target.value, disabled: true })
      this.setState({ predictions: data, address: e.target.value, disabled: false });
    })
  }

  openMap = (event) => {
    if (this.props.pickAddress) {
      event.target.classList.add('current')
      this.props.pickAddress(this.props.index)
      return
    }

    this.setState({isShowMap: true});
    if (window.ios) return;
    history.pushState(null, null,'/');
    window.addEventListener('popstate', this.handleBack, {once: true});
  }

  closeMap = (coords) => () => {
    this.setLocationFromMap(coords);
    this.setState({isShowMap: false});
  }

  focus = (e) => {
    this.input.classList.add('focus')
    if (this.state.address == '') {
      this.favoriteAddressesPredictions()
    }
    // e.target.focus()
    if (window.timeout) clearTimeout(window.timeout)
    document.getElementById('fields').classList.add('noscroll')
  }

  blur = (e) => {
    this.input.classList.remove('focus')
    window.timeout = setTimeout(() => {
      if (e.target.value === '' ||  e.target.checkValidity() || this.state.disabled || this.state.isFetching) return;
      let prediction = this.state.predictions[0]
      if (prediction) this.setLocation(prediction)
    }, 500)
    window.timeout = setTimeout(() => { document.getElementById('fields').classList.remove('noscroll') }, 300)
  }

  handleBack = (event) => {
    this.setState({isShowMap: false})
    if (event) event.stopPropagation()
  };

  keydown = (e) => {
    let prediction = this.state.predictions[0]
    if (![13, 9].includes(e.which) || !prediction || this.state.disabled) return;
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
    const { fieldsCount, address, index, readonly, language, hideRemove} = this.props

    return (
      <fieldset class='address'>
        {(fieldsCount > 2 || address !== '') && !hideRemove && !readonly && (<button class='remove-address' type='button' onClick={() => this.eraseAddress(index)}>×</button>)}
        {mapboxgl.supported() && <Pin onClick={this.openMap} disabled={readonly} height='24px' class='map-pick'/>}
        {this.state.isShowMap && <MapPicker onCloseMap={this.closeMap} handleBack={this.handleBack} language={language}/>}

        <input required class='address' placeholder={placeholder} type='text'
          onClick={this.focus} onFocus={this.focus} onKeyDown={this.keydown} onBlur={this.blur} onInput={this.autocomplete}
          value={this.state.address} ref={input => this.input = input} readonly={readonly}
        />

        <ul class='predictions'>
          { this.state.predictions.map(this.renderPrediction) }
        </ul>
      </fieldset>
    );
  }
}
