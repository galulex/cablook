//Apply dark theme
window.dark = localStorage.getItem('dark') === 'true'
window.ios = ['iPhone', 'iPad', 'iPod'].includes(navigator.platform)
window.geolocate = () => {}
if (window.dark) {
  document.documentElement.style.setProperty('--white', 'black');
  document.documentElement.style.setProperty('--navy', 'white');
  document.documentElement.style.setProperty('--grey', 'black');
  document.documentElement.style.setProperty('--map-bg', 'black');
  document.documentElement.style.setProperty('--path-color', ' #ffffff');
  document.documentElement.style.setProperty('--placeholder', 'rgba(255, 255, 255, 0.5)');
  document.documentElement.style.setProperty('--shadow', '0 3px 6px rgba(255,255,255,0.2)');
  document.documentElement.style.setProperty('--focus-shadow', '0 3px 6px rgba(255,255,255,0.2), 0 3px 6px rgba(255,255,255,255.23)');
  document.documentElement.style.setProperty('--bg', 'rgba(0,0,0,0.9)');
}
import '../pwa/android_polyfills.js';

import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { createMemoryHistory } from 'history';

import i18n from '../pwa/i18n.js'
import Home from '../pwa/home.js';
import NewDesign from '../pwa/new_design.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Bonus from '../pwa/bonus_trips.js';
import Contacts from '../pwa/contacts.js';
import Trips from '../pwa/trips.js';
import Drawer from '../pwa/drawer.js';
import FindDriver from '../pwa/find_driver.js';
import Prompt from '../pwa/prompt.js';
import Statistics from '../pwa/statistics.js';
import Profile from '../pwa/profile.js';
import { messaging, firebaseAuth } from '../pwa/firebase.js'

import Burger from '../pwa/images/burger.svg';
import Vendors from '../pwa/vendors.js';
import Vendor from '../pwa/vendor.js';
import Cart from '../pwa/cart.js';
import NotFound from '../pwa/not_found.js';

import '../pwa/css/buttons.css';

import axios from 'axios';
axios.defaults.baseURL = '/api';
axios.defaults.headers.common['Auth-Token'] = localStorage.token;
axios.defaults.headers.common['Content-Type'] = 'application/json';

export default class App extends Component {

  constructor(props){
    super(props)
    this.state = {
      currentUser: localStorage.token,
      currentUserID: '',
      drawer: false,
      cards: [],
      bonus_trips: [],
      parent_bonus: [],
      language: localStorage.getItem('language') || i18n.getInterfaceLanguage().split('-')[0],
      favorite_addresses: [],
      notification_settings: [],
      currentTrip: null
    }
    axios.defaults.headers.common['Pwa-Language'] = this.state.language
  }

  componentDidMount() {
    i18n.setLanguage(this.state.language)
    this.loadScript()
    if (window.ios) this.focusOutForIos()
    if (this.state.currentUser) {
      this.fetchUser()
      this.checkOneSignalToken()
      document.documentElement.style.setProperty('--body-bg', '#19a160')
    }
    this.requestPermission()
    window.addEventListener('offline', this.offline)
    window.addEventListener('online', this.online)
    document.addEventListener('visibilitychange', this.onVisibilityChange, false);
    if (!navigator.onLine) this.offline()
  }


  onVisibilityChange = () => {
    if (document.visibilityState !== 'visible') return;
    navigator.onLine ? this.online() : this.offline()
  }

  checkOneSignalToken = () => {
    const token = localStorage.getItem('one_signal_token')

    if (token) this.sendTokenToServer(token)
  }

  requestPermission = () => {
    if (!messaging) return;
    messaging.requestPermission()
      .then(() => {
        messaging.getToken().then((token) => {
          if (localStorage.getItem('fcm_token') === token) return;
          localStorage.setItem('fcm_token', token)
          localStorage.setItem('device', navigator.platform)
          if (this.state.currentUser) this.sendTokenToServer(token)
        })
      })
      .catch((err) => {
        console.log('Unable to get permission to notify.', err);
      });
  }

  sendTokenToServer = (token) => {
    let device_params = { token: token, platform: navigator.platform }

    axios.post('device', { device: device_params })
      .catch((error) => {
        if (error.response) alert(error.response.data.errors)
      })
  }

  focusOutForIos = () => {
    document.addEventListener('focusout', function(e) {window.scrollTo(0, 0)});
  }

  handleRoute = e => {
    this.currentUrl = e.url;
  };

  offline = () => {
    document.documentElement.style.setProperty('--body-bg', 'red')
    document.body.className = 'offline'
  }

  online = () => {
    document.documentElement.style.setProperty('--body-bg', '#19a160')
    document.body.className = ''
  }

  setCurrentTrip = (trip) => {
    this.setState({currentTrip:trip})
  }

  fetchUser = () => {
    axios.get('user').then((res) => {
      this.setState({cards: res.data.cards,
        favorite_addresses: res.data.favorite_addresses,
        notification_settings: res.data.enabled_notifications,
        bonus_trips: res.data.bonus_trips,
        parent_bonus: res.data.parent_bonus || [],
        currentUserID: res.data.id,
        currentTrip: JSON.parse(res.data.current_trip)
      })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      // this.removeData()
    })
  }

  logIn = (data) => {
    this.setState({currentUser: data.auth_token})
    localStorage.setItem('token', data.auth_token)
    localStorage.setItem('referral', data.referral_code)
    if (!!data.email) localStorage.setItem('email', data.email)
    localStorage.setItem('phone', data.phone_number)
    axios.defaults.headers.common['Auth-Token'] = data.auth_token;
    this.fetchUser()
  }

  logOut = (e) => {
    e.preventDefault()
    if (confirm('Are you sure?')) this.removeData();
  }

  removeData = () => {
    firebaseAuth().signOut()
    this.setState({currentUser: null, drawer: false})
    localStorage.removeItem('email')
    localStorage.removeItem('token')
    localStorage.removeItem('trip')
    localStorage.removeItem('cart')
    localStorage.removeItem('delivery_trip')
  }

  triggerDrawer = (e) => {
    e.target.parentNode.scrollTo(0,0)
  }

  updateCards = (cards) => {
    this.setState({cards: cards, drawer: false})
  }

  updateFavoriteAddresses = (favorite_addresses) => {
    this.setState({favorite_addresses: favorite_addresses, drawer: false})
  }

  updateNotificationSettings = (notification_settings) => {
    this.setState({notification_settings, drawer: false})
  }

  createCard = (data) => {
    let cards = this.state.cards

    axios.post('cards', data).then((res) => {
      cards.push(res.data)
      this.updateCards(cards)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  setLanguage = (e) => {
    this.setState({language: e.target.value, drawer: false})
    localStorage.setItem('language', e.target.value)
    i18n.setLanguage(this.state.language)
    this.setScriptLanguage()
    axios.defaults.headers.common['Pwa-Language'] = e.target.value
  }

  setScriptLanguage = () => {
    let script = document.getElementById('google-script')
    if (script !== null) script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDg2-aLroQJWY8LV8x1Gv5ZYDhIArWCDeU&libraries=places&language=${this.state.language}`);
  }

  loadScript = () => {
    if (document.getElementById('google-script') === null) {
      let script = document.createElement('script');
      script.setAttribute('id', 'google-script');
      script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDg2-aLroQJWY8LV8x1Gv5ZYDhIArWCDeU&libraries=places&language=${this.props.language}&callback=window.geolocate`);
      document.body.appendChild(script);
    }
  }

  render() {
    const { currentTrip } = this.state;

    if (this.state.currentUser) {
      return(
        <main id="app">
          <button class='burger' onClick={this.triggerDrawer}><Burger/></button>
          <Router history={window.ios ? createMemoryHistory() : null}>
            <NewDesign path='/'
              trip={currentTrip}
              cards={() => this.state.cards}
              bonus_trips={() => this.state.bonus_trips}
              createCard={this.createCard}
              language={this.state.language}
              favorite_addresses={() => this.state.favorite_addresses}
              fetchUser={this.fetchUser}
            />
            <Trips path='/trips/:id?'
              setCurrentTrip={this.setCurrentTrip}
            />
            <Bonus path='/bonus_trips' bonus_trips={() => this.state.bonus_trips} parent_bonus={() => this.state.parent_bonus} />
            <Cards path='/cards' cards={() => this.state.cards} create={this.createCard} currentUserID={() => this.state.currentUserID} />
            <Contacts path='/contacts' />
            <Statistics path='/statistics' />
            <Profile path='/profile'
              notification_settings={this.state.notification_settings}
              updateNotificationSettings={this.updateNotificationSettings}
              favorite_addresses={() => this.state.favorite_addresses}
              updateFavoriteAddresses={this.updateFavoriteAddresses}
              language = {this.state.language}
              setLanguage = {this.setLanguage}
              bonus_trips={() => this.state.bonus_trips}
              parent_bonus={() => this.state.parent_bonus}
            />
            <Vendors path='/delivery'/>
            <Vendor path='/delivery/:id' />
            <NotFound type='404' default />
            <Cart path='/delivery/cart' cards={() => this.state.cards} createCard={this.createCard} favorite_addresses={() => this.state.favorite_addresses} />
          </Router>
          <Drawer active={this.state.drawer} triggerDrawer = {this.triggerDrawer} logOut={this.logOut} />
          <Prompt />
        </main>
      )
    } else {
      return(
        <main id='app' class='login'>
          <Session login = {this.logIn} />
          <Prompt />
        </main>
      )
    }
  }
}

render(<App />, document.body);

document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
// window.addEventListener('resize', function() {
//   document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
// });
