//Apply dark theme
window.dark = localStorage.getItem('dark') === 'true'
window.ios = ['iPhone', 'iPad', 'iPod'].includes(navigator.platform)
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
  document.documentElement.style.setProperty('--controls', '#19A160');
}

import '../pwa/android_polyfills.js';
import smoothscroll from 'smoothscroll-polyfill';
smoothscroll.polyfill();

import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { createMemoryHistory } from 'history';

import i18n from '../pwa/i18n.js'
import NewDesign from '../pwa/new_design.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Bonus from '../pwa/bonus_trips.js';
import Contacts from '../pwa/contacts.js';
import Trips from '../pwa/trips.js';
import Drawer from '../pwa/drawer.js';
import Prompt from '../pwa/prompt.js';
import Statistics from '../pwa/statistics.js';
import Profile from '../pwa/profile.js';
import { messaging, firebaseAuth } from '../pwa/firebase.js'

import Burger from '../pwa/images/burger.svg';
import Vendors from '../pwa/vendors.js';
import Vendor from '../pwa/vendor.js';
import Cart from '../pwa/cart.js';
import NotFound from '../pwa/not_found.js';

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from '../pwa/lib/constants.js'

import '../pwa/css/buttons.css';

import axios from 'axios';
axios.defaults.baseURL = '/api';
axios.defaults.headers.common['Auth-Token'] = localStorage.token;
axios.defaults.headers.common['Content-Type'] = 'application/json';

let waitForToken

export default class App extends Component {

  constructor(props){
    super(props)
    this.state = {
      currentUser: localStorage.token,
      currentUserID: '',
      cards: [],
      bonus_trips: [],
      parent_bonus: [],
      availableBonusTrips: [],
      language: localStorage.getItem('language') || i18n.interfaceLanguage.split('-')[0],
      favorite_addresses: [],
      notification_settings: [],
      currentTrip: null,
      isYmapsLoading: false
    }
    axios.defaults.headers.common['Pwa-Language'] = this.state.language
  }

  componentDidMount() {
    if (localStorage.fcm_token === 'null') waitForToken = setInterval(this.waitForFCMToken(localStorage.fcm_token), 3000)
    this.loadScript()
    if (window.ios) this.focusOutForIos()
    if (this.state.currentUser && this.state.currentUser.length !== 0) {
      this.fetchUser()
      this.checkOneSignalToken()
      document.documentElement.style.setProperty('--body-bg', '#19a160')
    }
    this.registerServiceworker()
    window.addEventListener('offline', this.offline)
    window.addEventListener('online', this.online)
    document.addEventListener('visibilitychange', this.onVisibilityChange, false);
    if (!navigator.onLine) this.offline()
  }

  waitForFCMToken = (token) => {
    if (token !== 'null') {
      this.sendTokenToServer(token)
      clearInterval(waitForToken)
    }
  }

  onVisibilityChange = () => {
    document.documentElement.style.setProperty('--car-transition', '0s')
    if (document.visibilityState !== 'visible') return;
    if (this.state.currentUser && this.state.currentUser.length !== 0) this.fetchUser()
    navigator.onLine ? this.online() : this.offline()
  }

  checkOneSignalToken = () => {
    const token = localStorage.getItem('one_signal_token')

    if (token) this.sendTokenToServer(token)
  }

  registerServiceworker = () => {
    if ('serviceWorker' in navigator ) {
      navigator.serviceWorker.register('/serviceworker.js').then((registration) => {
        messaging.useServiceWorker(registration)
        this.requestPermission()
        messaging.onMessage((payload) => {
          let trip = JSON.parse(payload.data.trip)
          if (trip.action && trip.action === 'remove_notifications') { this.clearNotifications(registration); return }
          let { title, body, icon, tag, renotify, actions } = payload.data
          let options = { title, body, icon, tag, renotify }
          if (actions) {
            let actionsData = JSON.parse(actions)
            let showActions = true
            actionsData.actions.map((el) => {
              if (el.action === 'reply') return showActions = false
            })
            if (showActions) options = { ...options, ...actionsData }
          }
          options = Object.assign(options, { data: payload.data.trip })
          registration.showNotification(title, options)
        })
      }).catch((err) => {
        console.log('Error: ', err)
      })
    }
  }

  requestPermission = () => {
    if (!messaging) return;
    messaging.requestPermission()
    .then(() => {
      messaging.getToken().then((token) => {
        if (localStorage.getItem('fcm_token') === token) return
        localStorage.setItem('fcm_token', token)
        localStorage.setItem('device', navigator.platform)
        if (this.state.currentUser) this.sendTokenToServer(token)
      })
    })
    .catch((err) => {
      console.log('Unable to get permission to notify.', err)
    })
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
    if (!this.state.currentTrip || ![PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, CONFIRM_UPDATE_TRIP].includes(this.state.currentTrip.status)) {
      this.setState({currentTrip:trip})
    } else {
      return
    }
  }

  setBonusTrips = (data) => {
    this.setState({parent_bonus: data.parent_bonus, bonus_trips: data.bonus_trips, availableBonusTrips: data.availableBonusTrips})
  }

  getAvailableBonusTrips = (bonus_trips) => {
    return bonus_trips.filter(trip => trip.status === 'fresh')
  }

  fetchUser = () => {
    return axios.get('user').then((res) => {
      let availableBonusTrips = []
      if (res.data.bonus_trips) availableBonusTrips = this.getAvailableBonusTrips(res.data.bonus_trips)
      this.setState({cards: res.data.cards,
        favorite_addresses: res.data.favorite_addresses,
        notification_settings: res.data.enabled_notifications,
        bonus_trips: res.data.bonus_trips,
        availableBonusTrips: availableBonusTrips,
        parent_bonus: res.data.parent_bonus || [],
        currentUserID: res.data.id,
        currentTrip: res.data.current_trip
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
    this.setState({currentUser: null})
    localStorage.clear()
  }

  triggerDrawer = (open = true) => {
    this.main && this.main.scrollTo({left: (open) ? 0 : 300, behavior: 'smooth'})
  }

  updateCards = (cards) => {
    this.setState({cards: cards})
  }

  updateFavoriteAddresses = (favorite_addresses) => {
    this.setState({favorite_addresses: favorite_addresses})
  }

  updateNotificationSettings = (notification_settings) => {
    this.setState({notification_settings})
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

  geocode = (point, callback) => {
    axios.get(`address?coords=${point}`).then((res) => {
      callback(res.data.address)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  setLanguage = (e) => {
    this.setState({language: e.target.value})
    localStorage.setItem('language', e.target.value)
    axios.defaults.headers.common['Pwa-Language'] = e.target.value
    window.location.reload()
  }

  loadScript = () => {
    if (document.getElementById('google-script') === null) {
      let script = document.createElement('script');
      script.setAttribute('id', 'google-script');
      script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDg2-aLroQJWY8LV8x1Gv5ZYDhIArWCDeU&libraries=places&language=${this.props.language}`);
      document.body.appendChild(script);
    }
  }

  clearNotifications = (registration) => {
    registration.getNotifications().then((ns)=>ns.forEach((n)=>n.close()))
  }

  closeDrawer = (e) => {
    if (!e.target.classList.contains('nav-wrapper') && !e.target.classList.contains('burger')) this.triggerDrawer(false)
  }

  scrollEnd = (e) => {
    let target = e.target
    clearTimeout(window.scrollTimeout)
    window.scrollTimeout = setTimeout(() => {
      if (target.scrollLeft == 0 || target.scrollLeft == target.offsetWidth || target.scrollLeft == 300) return
      let x = (target.scrollLeft > 0 && target.scrollLeft < target.offsetWidth / 2) ? 0 : target.offsetWidth
      target.scrollTo({left: x})
    }, 300)
  }

  resetCurrentTrip = () => {
    this.setState({currentTrip: null})
  }

  render() {
    const { currentTrip } = this.state;

    if (this.state.currentUser) {
      return(
        <main id="app" onClick={this.closeDrawer} ref={main => this.main = main} onScroll={this.scrollEnd}>
          <button class='burger' onClick={() => this.triggerDrawer(true)}><Burger/></button>
          <Drawer triggerDrawer={this.triggerDrawer} logOut={this.logOut} />
          <Router history={window.ios ? createMemoryHistory() : null} onChange={() => this.triggerDrawer(false)}>
            <NewDesign path='/'
              trip={currentTrip}
              cards={() => this.state.cards}
              bonus_trips={() => this.state.bonus_trips}
              createCard={this.createCard}
              language={this.state.language}
              favorite_addresses={() => this.state.favorite_addresses}
              fetchUser={this.fetchUser}
              geocode={this.geocode}
              scrollEnd={this.scrollEnd}
              isYmapsLoading={this.state.isYmapsLoading}
              setBonusTrips={this.setBonusTrips}
              getAvailableBonusTrips={this.getAvailableBonusTrips}
              availableBonusTrips={this.state.availableBonusTrips}
              resetCurrentTrip={this.resetCurrentTrip}
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
              geocode={this.geocode}
            />
            <Vendors path='/delivery'
              setCurrentTrip={this.setCurrentTrip}
            />
            <Vendor path='/delivery/:id'
              setCurrentTrip={this.setCurrentTrip}
            />
            <NotFound type='404' default />
            <Cart path='/delivery/cart'
              cards={() => this.state.cards}
              createCard={this.createCard}
              favorite_addresses={() => this.state.favorite_addresses}
              geocode={this.geocode}
            />
          </Router>
          <Prompt />
        </main>
      )
    } else {
      return(
        <main id='app' class='login' ref={main => this.main = main}>
          <Session login = {this.logIn} />
          <Prompt />
        </main>
      )
    }
  }
}

render(<App />, document.body);
