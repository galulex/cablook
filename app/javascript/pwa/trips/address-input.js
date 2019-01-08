import { h, render, Component } from 'preact';

export default class AddressInput extends Component {
  constructor(props) {
    super(props)
    this.state = {
      predictions: [],
      address: '',
      isValid: false
    }
  }

  render() {
    return (
      <fieldset>
        <button type='button' onClick={this.props.removeAddress}>x</button>
        { this.renderLocationButton(this.props.index) }
        <input required type='text' onInput={this.autocomlete} value={this.state.address}/>
        <ul>
          {this.state.predictions.map(this.renderPrediction)}
        </ul>
      </fieldset>
    );
  }

  componentDidMount() {
    this.base.childNodes[2].setCustomValidity('Choose address from a list')
  }

  renderLocationButton = (i) => {
    if (i == 0) return(<button type='button' onClick={this.getCurrentLocation}>^</button>)
  }

  getCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(result => {
        var location = new google.maps.LatLng(result.latitude, result.longitude);
        var geocoder = new google.maps.Geocoder();
        console.log(result)
        geocoder.geocode({ 'location': location }, (result, status) => {
          console.log(status)
        })
      },
        (error) => { console.log(error.message) },
        { enableHighAccuracy: true }
      );
    } else {
       alert("Geolocation is not supported by this browser.");
    }
  }

  renderPrediction = (prediction) => {
    return(
      <li onClick={() => this.setLocation(prediction)}>
        <b>{prediction.structured_formatting.main_text}</b>
        <br/>
        <sub>{prediction.structured_formatting.secondary_text}</sub>
      </li>
    )
  }

  setLocation = (place) => {
    let placeService = new google.maps.places.PlacesService(document.createElement('div'))
    let address = this
    placeService.getDetails({placeId: place.place_id}, function(result) {
      address.setState({ address: place.structured_formatting.main_text, predictions: [], isValid: true });
      address.props.setAddress(place.structured_formatting.main_text, `${result.geometry.location.lng()},${result.geometry.location.lat()}`, address.props.index)
      address.base.childNodes[2].setCustomValidity('')
    })
  }

  autocomlete = e => {
    if (e.target.value === '') return false
    let autocomplete = new google.maps.places.AutocompleteService()
    autocomplete.getPlacePredictions({input: e.target.value, componentRestrictions: {country: 'ua'}, location: new google.maps.LatLng(49.4311119, 31.9791903), radius: 10, strictbounds: true, offset: 2}, data => {
      if (!data) return this.setState({ predictions: [], address: e.target.value })
      this.setState({ predictions: data, address: e.target.value });
    })
  }
}
