import { h, render, Component } from 'preact';
import axios from 'axios';

import Close from './images/times-circle.svg';
import i18n from './i18n.js';
import AddressInput from '../pwa/trips/address-input.js';
import './css/profile.css'

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props);
      this.state = {
      showing: false,
      favorite_addresses: [],
      id: null,
      name: null,
      location: null,
      user_id: null,
      address: '',
      place_id: ''
    }
  }

  componentDidMount() {
    this.setState({favorite_addresses: this.props.favorite_addresses()})
  }

  componentWillReceiveProps() {
    this.setState({favorite_addresses: this.props.favorite_addresses()})
  }

  handleChange = (e) => {
    this.setState({ [e.target.name] : e.target.value });
  }

  setAddress = (name, location) => {
    this.setState({ address: name, location: location });
    this.getPlaceID(location);
  }

  getPlaceID = (coordinates) => {
    let self = this;
    let latLng = coordinates.split(',')
    let geocoder = new google.maps.Geocoder()
    let location = new google.maps.LatLng(parseFloat(latLng[0]), parseFloat(latLng[1]))
      geocoder.geocode( { 'location': location}, function(res, status) {
        if (status == 'OK') {
          let place = res[0]
          self.setState({ place_id: place.place_id });
        } else {
          alert(status)
        }
      })
  }

  render() {
    const { showing } = this.state;
    return (
      <section class='profile'>
        <header>{i18n.profile_page.header}</header>
          <h4 class='center'>{i18n.profile_page.favorite_addresses}</h4>
          { this.favoriteAddressesList() }
          { showing ? this.newForm() : <button class='button add_fav_address' type='button' onClick={() => this.setState({ showing: !showing })}>+ {i18n.profile_page.add_address}</button> }
      </section>
    )
  }

  favoriteAddressesList = () => {
    if (this.state.favorite_addresses.length > 0) {
      return(
        <ul class='favorite_addresses'>
          { this.state.favorite_addresses.map((address, i) => {
            return(
              <li>
                <span>{address.name } ({address.address})</span>
                <button class='x-card' type='button' onClick={() => this.delete(address.id, i)}><Close fill='#a925ad'/></button>
              </li>
            )
          })}
        </ul>
      )
    } else {
      return(<div><h5 class='nocards center'>{i18n.profile_page.no_addresses}</h5></div>)
    }
  }

  newForm = () => {
    return(
      <form id="newFavoriteAddressForm">
        <input required class="address" type="text" name="name" placeholder={i18n.profile_page.type_name} value={this.state.name} onChange={this.handleChange} />
        <AddressInput setAddress={this.setAddress} favorite_addresses = {() => []} />
        <button class="button add_fav_address" type="reset" onClick={() => this.create(this.state.name, this.state.location, this.state.address, this.state.place_id)}>OK</button>
      </form>
    )
  }

  create = (name, location, address, place_id) => {
    let self = this;
    axios.post('/favorite_addresses', {
      name: name,
      location: location,
      address: address,
      place_id: place_id
    })
    .then( response => {
      self.setState({
        favorite_addresses: [...self.state.favorite_addresses, response.data],
        showing: false,
        name: '',
        address: ''
      });
    })
    .catch( error => {
      if (error.response) alert(error.response.data.errors)
    });
  }

  delete = (id, index) => {
    if (!confirm('Are you sure?')) return;
    let favorite_addresses = this.state.favorite_addresses

    axios.delete(`favorite_addresses/${id}`).then((address) => {
      favorite_addresses.splice(index, 1)
      this.setState({favorite_addresses: favorite_addresses})
      this.props.updateFavoriteAddresses(favorite_addresses)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
