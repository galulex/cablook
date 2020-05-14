import { h, render, Component, createRef } from 'preact'
import i18n from '../i18n.js'
import axios from 'axios'

import Close from '../images/close.js'
import AddressInput from '../../pwa/trips/address-input.js'

const LOCALES = { en: '🇺🇸', uk: '🇺🇦', ru: '🇷🇺' }

export default class Settings extends Component {
  constructor(props) {
    super(props)
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
    const { notification_settings } = this.state
    this.updateNotificationSettings(notification_settings)
  }

  handleChange = (e) => {
    this.setState({ [e.target.name] : e.target.value })
  }

  setAddress = (name, location) => {
    this.setState({ address: name, location: location })
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
    let { notification_settings } = this.state

    if (e.currentTarget.checked) {
      notification_settings.push(e.currentTarget.value)
    } else {
      notification_settings = notification_settings.filter((x) => { return x !== e.currentTarget.value})
    }

    this.setState({notification_settings: notification_settings})
  }

  favoriteAddressesList = () => {
    if (this.state.favorite_addresses.length > 0) {
      return(
        <ul class='tab-content__container-items places'>
          { this.state.favorite_addresses.map((address, i) => {
            return(
              <li class='tab-content__container-item'>
                <span>{address.name} ({address.address})</span>
                <button class='x-card' type='button' onClick={() => this.delete(address.id, i)}><Close /></button>
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
        <AddressInput
          hideRemove={true}
          setAddress={this.setAddress}
          favorite_addresses={() => []}
          placeholder={i18n.profile_page.placeholder}
          geocode={this.props.geocode}
          language={this.props.language}
          isGeocoding={this.props.isGeocoding}
          setGeocoding={this.props.setGeocoding}
        />
        <button class="button add_fav_address" type="button" disabled={this.state.disabled} onClick={this.create}>OK</button>
        <input type="submit" onClick={this.create} hidden/>
      </form>
    )
  }

  create = (e) => {
    let self = this
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity()
    this.setState({ disabled: true })
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
      })
      this.props.updateFavoriteAddresses([...this.state.favorite_addresses, response.data])
    })
    .catch( error => {
      this.setState({ disabled: false })
      if (error.response) alert(error.response.data.errors)
    })
  }

  delete = (id, index) => {
    if (!confirm(i18n.are_you_sure)) return
    let favorite_addresses = this.state.favorite_addresses

    axios.delete(`favorite_addresses/${id}`).then((address) => {
      favorite_addresses.splice(index, 1)
      this.setState({favorite_addresses: favorite_addresses})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    const { showing, notification_settings } = this.state

    return (
      <div class='tab-content__holder'>
        <div class='tab-content__container'>
          <div class='tab-content__items'>
            <div class='tab-content__label-container'>
              <input id='dark' class='custom-checkbox' type='checkbox' value='dark' onChange={this.changeTheme} checked={window.dark}/>
              <label for='dark'>{i18n.profile_page.theme}</label>
            </div>
            <span> | </span>
            <div class='tab-content__label-container'>
              <label for='language'>{i18n.profile_page.language}</label>
              <select onChange={this.props.setLanguage} id='language'>
                {Object.keys(LOCALES).map(key => {
                  return(<option value={key} selected={key == this.props.language}>{LOCALES[key]}</option>)
                })}
              </select>
            </div>
          </div>
        </div>
        <div class='tab-content__container'>
          <div class='tab-content__header'>Notifications</div>
          <div class='tab-content__container-items'>
            {['accept_trip', 'decline_trip', 'waiting_client'].map((value) => {
              return(
                <div class='tab-content__container-item'>
                  <input id={value} type='checkbox' value={value} onChange={this.changeNotificationSettings} checked={notification_settings.includes(value)}/>
                  <label for={value} class='label-header'>{i18n.profile_page.notification_names[value]}</label>
                  <label for={value} class='label-switcher'/>
                </div>
              )
            })}
          </div>
        </div>
        <div class='tab-content__container'>
          <div class='tab-content__header'>Places</div>
          { this.favoriteAddressesList() }
          { showing ? this.newForm() : <button class='button add_fav_address' type='button' onClick={() => this.setState({ showing: !showing })}>+ {i18n.profile_page.add_address}</button> }
        </div>
      </div>
    )
  }
}
