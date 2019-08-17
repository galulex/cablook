import { h, render, Component } from 'preact';
import axios from 'axios';

import Close from './images/times-circle.svg';
import i18n from './i18n.js';
import AddressInput from '../pwa/trips/address-input.js';
import './css/profile.css'
import Bonus from '../pwa/bonus_trips.js';

const LOCALES = { en: '🇺🇸', uk: '🇺🇦', ru: '🇷🇺' }

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showing: false,
      favorite_addresses: [],
      notification_settings: [],
      id: null,
      name: null,
      location: null,
      user_id: null,
      address: '',
      disabled: false
    }
  }

  componentDidMount() {
    this.setState({favorite_addresses: this.props.favorite_addresses(),
                   notification_settings: this.props.notification_settings})
  }

  componentWillReceiveProps(nextProps) {
    if (this.props.notification_settings !== nextProps.notification_settings) {
      this.setState({favorite_addresses: nextProps.favorite_addresses(),
                     notification_settings: nextProps.notification_settings})
    } else {
      this.setState({favorite_addresses: nextProps.favorite_addresses()})
    }
  }

  componentWillUnmount() {
    const { notification_settings } = this.state;
    this.updateNotificationSettings(notification_settings)
  }

  handleChange = (e) => {
    this.setState({ [e.target.name] : e.target.value });
  }

  setAddress = (name, location) => {
    this.setState({ address: name, location: location });
  }

  changeTheme = (e) => {
    localStorage.setItem('dark', e.target.checked)
    window.location.reload()
  }

  updateNotificationSettings = (data) => {
    axios.patch('notification_settings', { notification_settings: data })
      .then((res) => {
        this.props.updateNotificationSettings(this.state.notification_settings)
      })
      .catch((error) => {
        if (error.response) alert(error.response.data.errors)
    })
  }

  changeNotificationSettings = (e) => {
    let { notification_settings } = this.state;

    if (e.currentTarget.checked) {
      notification_settings.push(e.currentTarget.value)
    } else {
      notification_settings = notification_settings.filter((x) => { return x !== e.currentTarget.value})
    }

    this.setState({notification_settings: notification_settings})
  }

  render() {
    const { showing, notification_settings } = this.state;

    return (
      <section class='profile'>
        <header>{i18n.profile_page.header}</header>
          <div class='nocall'>
            <input id='dark' type='checkbox' value='dark' onChange={this.changeTheme} checked={window.dark}/>
            <label for='dark'>{i18n.profile_page.theme}</label>
          </div>
          <div class='nocall'>
            <label for='language'>{i18n.profile_page.language}</label>
            <select onChange={this.props.setLanguage} id='language'>
              {Object.keys(LOCALES).map(key => {
                return(<option value={key} selected={key == this.props.language}>{LOCALES[key]}</option>)
              })}
            </select>
          </div>
          <h4 class='center'>{i18n.profile_page.notification_settings}</h4>
          {['accept_trip', 'decline_trip', 'waiting_client'].map((value) => {
            return(
              <div class='nocall'>
                <input id={value} type='checkbox' value={value} onChange={this.changeNotificationSettings} checked={notification_settings.includes(value)}/>
                <label for={value}>{i18n.profile_page.notification_names[value]}</label>
              </div>
            )
          })}
          <h4 class='center'>{i18n.profile_page.favorite_addresses}</h4>
          { this.favoriteAddressesList() }
          { showing ? this.newForm() : <button class='button add_fav_address' type='button' onClick={() => this.setState({ showing: !showing })}>+ {i18n.profile_page.add_address}</button> }
          <Bonus bonus_trips={this.props.bonus_trips} parent_bonus={this.props.parent_bonus}/>
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
        <button class="button add_fav_address" type="button" disabled={this.state.disabled} onClick={this.create}>OK</button>
        <input type="submit" onClick={this.create} hidden/>
      </form>
    )
  }

  create = (e) => {
    let self = this;
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    this.setState({ disabled: true });
    axios.post('/favorite_addresses', {
      name: self.state.name,
      location: self.state.location,
      address: self.state.address
    })
    .then( response => {
      this.setState({
        showing: false,
        name: '',
        address: '',
        disabled: false
      });
      this.props.updateFavoriteAddresses([...this.state.favorite_addresses, response.data])
    })
    .catch( error => {
      this.setState({ disabled: false })
      if (error.response) alert(error.response.data.errors)
    });
  }

  delete = (id, index) => {
    if (!confirm(i18n.are_you_sure)) return;
    let favorite_addresses = this.state.favorite_addresses

    axios.delete(`favorite_addresses/${id}`).then((address) => {
      favorite_addresses.splice(index, 1)
      this.setState({favorite_addresses: favorite_addresses})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
