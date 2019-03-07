import { h, render, Component } from 'preact';
import axios from 'axios';

import Close from './images/times-circle.svg';
import i18n from './i18n.js';
import AddressInput from '../pwa/trips/address-input.js';
import CurrentTrip from './current-trip.js';
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
      address: ''
    }
  }

  componentDidMount() {
    axios.get(`/favorite_addresses`)
      .then(res => {
        this.setState({favorite_addresses: res.data});
      })
  }

  handleChange = (e) => {
    this.setState({ [e.target.name] : e.target.value });
  }


  setAddress = (e) => {
    this.setState({ address: e });
    this.setLocation(e);
  }


  setLocation = (e) => {
    let geocoder = new google.maps.Geocoder();
    let address = `${e}, Cherkassy`;
    var coordinates = '';
    geocoder.geocode( { 'address': address }, (res, status) => {
      if (status == 'OK') {
        let place = res[0]
        coordinates = `${place.geometry.location.lat()},${place.geometry.location.lng()}`
        this.setState({ location: coordinates });
        } else {
          alert(status)
      }
    })
  }

  render() {
    const { showing } = this.state;
    let favoriteAddressesList = (<div><h5 class='nocards'>{i18n.profile_page.no_addresses}</h5></div>)
    let newForm = (
      <div>
        <form id="newFavoriteAddressForm">
          <input required class="address" type="text" name="name" placeholder={i18n.profile_page.type_name} value={this.state.name} onChange={this.handleChange} />
          <AddressInput setAddress = {this.setAddress}  onChange={this.setAddress}/>
          <button class="button add_fav_address" type="reset" onClick={() => this.create(this.state.name, this.state.location, this.state.address)}>+ {i18n.profile_page.add_address}</button>
        </form>
      </div>
    )

    if (this.state.favorite_addresses.length > 0) {
      favoriteAddressesList = (
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
    }
    return (
      <section>
        <header>{i18n.profile_page.header}</header>
          <h4>{i18n.profile_page.favorite_addresses}</h4>
          { favoriteAddressesList }
          { showing ? newForm : <button class='button' type='button' onClick={() => this.setState({ showing: !showing })}>+ {i18n.profile_page.add_address}</button> }
      </section>
    )
  }

  create = (name, location, address) => {
    var self = this;
    axios.post('/favorite_addresses', {
      name: name,
      location: location,
      address: address
    })
    .then(function (response) {
      self.setState({
        favorite_addresses: [...self.state.favorite_addresses, response.data],
        showing: false,
        name: '',
        address: ''
      });
      console.log(response);
    })
    .catch(function (error) {
      console.log(error);
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
