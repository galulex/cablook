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
      address: ''
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
                <span>{address.name} ({address.address})</span>
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
      <form id="newFavoriteAddressForm" onsubmit={(e) => e.preventDefault()}>
        <input required class="address" type="text" name="name" placeholder={i18n.profile_page.type_name} value={this.state.name} onChange={this.handleChange} />
        <AddressInput setAddress={this.setAddress} favorite_addresses={() => []} placeholder={i18n.profile_page.placeholder} />
        <button class="button add_fav_address" type="button" onClick={this.create}>OK</button>
        <input type="submit" onClick={this.create} hidden/>
      </form>
    )
  }

  create = (e) => {
    let self = this;
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    axios.post('/favorite_addresses', {
      name: self.state.name,
      location: self.state.location,
      address: self.state.address
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
