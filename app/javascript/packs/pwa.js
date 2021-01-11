//Apply dark theme
window.dark = localStorage.getItem('dark') === 'true'
window.ios = ['iPhone', 'iPad', 'iPod', 'MacIntel'].includes(navigator.platform)
if (window.dark) {
  document.documentElement.style.setProperty('--bg_gradient_color_1', '#0f0f0f')
  document.documentElement.style.setProperty('--bg_gradient_color_2', '#191730')
  document.documentElement.style.setProperty('--font_color_1', 'white')
  document.documentElement.style.setProperty('--font_color_2', 'white')
  document.documentElement.style.setProperty('--font_color_2_dark', 'black')
  document.documentElement.style.setProperty('--green_2', 'white')
  document.documentElement.style.setProperty('--green_3', '#233038')
  document.documentElement.style.setProperty('--black_2', 'white')
  document.documentElement.style.setProperty('--button-background', '#19a160')
  document.documentElement.style.setProperty('--shadow_color', 'rgba(20, 18, 33, 0.5)')
  document.documentElement.style.setProperty('--shadow_color_light', 'rgba(100, 100, 100, 0.3)')
  document.documentElement.style.setProperty('--white', 'black')
  document.documentElement.style.setProperty('--grey', 'black')
  document.documentElement.style.setProperty('--map-bg', 'black')
  document.documentElement.style.setProperty('--path-color', ' #ffffff')
  document.documentElement.style.setProperty('--placeholder', 'rgba(255, 255, 255, 0.5)')
  document.documentElement.style.setProperty('--shadow', '0 3px 6px rgba(255,255,255,0.2)')
  document.documentElement.style.setProperty('--focus-shadow', '0 3px 6px rgba(255,255,255,0.2), 0 3px 6px rgba(255,255,255,255.23)')
  document.documentElement.style.setProperty('--bg', 'rgba(0,0,0,0.9)')
  document.documentElement.style.setProperty('--controls', '#19A160')
  document.documentElement.style.setProperty('--orange_2', '#191730')
  document.documentElement.style.setProperty('--orange-button-bg', '#efcc3a')
  document.documentElement.style.setProperty('--address-input-bg', 'rgba(0, 0, 0, 0.65)')
  document.documentElement.style.setProperty('--comment-input-bg', 'rgba(0, 0, 0, 0.1)')
  document.documentElement.style.setProperty('--address-input-text', 'white')
  document.documentElement.style.setProperty('--navy-dark', 'black')
  document.documentElement.style.setProperty('--red-button-bg', 'rgba(204, 15, 52, 0.8)')
  document.documentElement.style.setProperty('--red-button-text', 'white')
  document.documentElement.style.setProperty('--input_bg_color', 'rgba(18, 18, 18, 0.3)')
  document.documentElement.style.setProperty('--container-background', 'rgba(170, 170, 170, 0.1)')
  document.documentElement.style.setProperty('--navy', '#4d496f')
  document.documentElement.style.setProperty('--trip-svg', '#4d496f')
  document.documentElement.style.setProperty('--transparent', '#19A160')
  document.documentElement.style.setProperty('--line-color', '#4d496f')


  document.documentElement.style.setProperty('--main_background', 'linear-gradient(to right, var(--bg_gradient_color_1), var(--bg_gradient_color_2), var(--bg_gradient_color_1))')
  document.documentElement.style.setProperty('--address-input-weight', 'bold')
}

import '../pwa/android_polyfills.js';
import smoothscroll from 'smoothscroll-polyfill';
smoothscroll.polyfill();

import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { createMemoryHistory } from 'history';

import i18n from '../pwa/i18n.js'
import geoLocation from '../pwa/geolocation.js'
import NewDesign from '../pwa/new_design.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Contacts from '../pwa/contacts.js';
import Trips from '../pwa/trips.js';
import Drawer from '../pwa/drawer.js';
import Prompt from '../pwa/prompt.js';
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
      currentLocation: null,
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
      isGeocoding: false,
      isScrollNegative: false,
      activateFeedback: false,
      isBurgerShowing: true,
      cashbackAmount: null
    }
    axios.defaults.headers.common['Pwa-Language'] = this.state.language
  }

  componentDidMount() {
    this.loadScript()
    geoLocation(this.geocode, this.setTrip)
    if (window.ios) this.focusOutForIos()
    if (this.state.currentUser && this.state.currentUser.length !== 0) {
      this.fetchUser()
      this.checkOneSignalToken()
      waitForToken = setInterval(this.waitForFCMToken, 3000)
      document.documentElement.style.setProperty('--body-bg', '#ced5d3')
    }
    this.registerServiceworker()
    window.addEventListener('offline', this.offline, { passive: true })
    window.addEventListener('online', this.online, { passive: true })
    document.addEventListener('visibilitychange', this.onVisibilityChange, false, { passive: true })
    this.main.addEventListener('scroll', this.scrollEnd, { passive: true })
    document.addEventListener('touchstart', this.setTouching, { passive: true })
    document.addEventListener('touchend', this.setTouching, { passive: true })
    if (!navigator.onLine) this.offline()
  }

  componentWillUnmount() {
    window.removeEventListener('offline', this.offline, { passive: true })
    window.removeEventListener('online', this.online, { passive: true })
    document.removeEventListener('visibilitychange', this.onVisibilityChange, false, { passive: true })
    this.main.removeEventListener('scroll', this.scrollEnd, { passive: true })
    document.removeEventListener('touchstart', this.setTouching, { passive: true })
    document.removeEventListener('touchend', this.setTouching, { passive: true })
  }

  waitForFCMToken = () => {
    let token = localStorage.getItem("fcm_token")

    if (token) {
      this.sendTokenToServer(token)
      clearInterval(waitForToken)
    }
  }

  setTouching = (event) => {
    window.isTouching = (event.type === 'touchstart' ? true : false)
  }

  setNegativeScroll = (scrollValue) => {
    this.setState({isScrollNegative: scrollValue < 0})
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
        if (!messaging) return
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
    document.documentElement.style.setProperty('--body-bg', '#e6efee')
    document.body.className = ''
  }

  setGeocoding = (isGeocoding = true) => {
    this.setState({ isGeocoding })
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
    return bonus_trips.filter(trip => trip.status === 'fresh' && trip.type !== 'cashback')
  }

  fetchUser = () => {
    return axios.get('user').then((res) => {
      if ((res.data.locale !== this.state.language)) { this.updateUserLocale(this.state.language) }
      let availableBonusTrips = []
      if (res.data.bonus_trips) availableBonusTrips = this.getAvailableBonusTrips(res.data.bonus_trips)
      this.setState({cards: res.data.cards,
        favorite_addresses: res.data.favorite_addresses,
        notification_settings: res.data.enabled_notifications,
        bonus_trips: res.data.bonus_trips,
        availableBonusTrips: availableBonusTrips,
        parent_bonus: res.data.parent_bonus || [],
        cashbackAmount: res.data.cashback/100,
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
    let fcmToken = localStorage.getItem("fcm_token");
    if (fcmToken) this.sendTokenToServer(fcmToken)
    this.checkOneSignalToken()
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
    setTimeout(() => { this.main && this.main.scrollTo({left: (open) ? 0 : 300, behavior: 'smooth'}) }, 10)
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

  geocode = (point, callback) => {
    axios.get(`address?coords=${point}`).then((res) => {
      callback(res.data.address)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateUserLocale = (locale) => {
    axios.patch('user', { locale: locale })
  }

  setLanguage = (e) => {
    this.setState({language: e.target.value})
    localStorage.setItem('language', e.target.value)
    axios.defaults.headers.common['Pwa-Language'] = e.target.value
    this.updateUserLocale(e.target.value)
    window.location.reload()
  }

  loadScript = () => {
    if (document.getElementById('google-script') === null) {
      let script = document.createElement('script')
      script.setAttribute('id', 'google-script')
      script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDg2-aLroQJWY8LV8x1Gv5ZYDhIArWCDeU&libraries=places&language=${this.state.language}`)
      document.body.appendChild(script)
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
      if (!window.isTouching) target.scrollTo({left: x})
    }, 300)
  }

  resetCurrentTrip = () => {
    this.setState({currentTrip: null})
  }

  showFeedback = () => {
    const { activateFeedback, currentTrip } = this.state
    return (activateFeedback || currentTrip && currentTrip.status == FINISHED)
  }

  setActivateFeedback = (activateFeedback = false) => {
    this.setState({activateFeedback})
  }

  showBurger = (isBurgerShowing = true) => {
    this.setState({isBurgerShowing})
  }

  setTrip = (address, lat, lng) => {
    this.setState({ 
        currentLocation: {
          location: `${lat},${lng}`,
          address: address,
          favorite_address: true,
          structured_formatting: { 
            main_text: address, 
            secondary_text: i18n.address_input.location 
          }
        }
      }
    )
  }

  render() {
    const { currentTrip, isGeocoding, availableBonusTrips,
            cards, language, bonus_trips, favorite_addresses } = this.state

    if (this.state.currentUser) {
      return(
        <main id="app" onClick={this.closeDrawer} ref={main => this.main = main}>
          { this.state.isBurgerShowing &&
            <button
              class={`button white-opacity burger ${this.state.activateFeedback ? 'hidden' : ''}`}
              ref={el => this.mainBurger = el}
              onClick={this.triggerDrawer}>
                <Burger/>
            </button>
          }
          <Drawer triggerDrawer={this.triggerDrawer} logOut={this.logOut} />
          <Router history={window.ios ? createMemoryHistory() : null} onChange={() => this.triggerDrawer(false) }>
            <NewDesign path='/'
              trip={currentTrip}
              cards={() => this.state.cards}
              currentLocation={this.state.currentLocation}
              bonus_trips={() => bonus_trips}
              language={language}
              favorite_addresses={() => favorite_addresses}
              fetchUser={this.fetchUser}
              geocode={this.geocode}
              scrollEnd={this.scrollEnd}
              isYmapsLoading={this.state.isYmapsLoading}
              setBonusTrips={this.setBonusTrips}
              getAvailableBonusTrips={this.getAvailableBonusTrips}
              availableBonusTrips={availableBonusTrips}
              resetCurrentTrip={this.resetCurrentTrip}
              isGeocoding={isGeocoding}
              showFeedback={this.showFeedback}
              setActivateFeedback={this.setActivateFeedback}
              setGeocoding={this.setGeocoding}
              showBurger={this.showBurger}
              mainBurger={this.mainBurger}
              updateCards={this.updateCards}
              cashbackAmount={this.state.cashbackAmount}
            />
            <Trips path='/trips/:id?'
              setCurrentTrip={this.setCurrentTrip}
              showFeedback={this.showFeedback}
              setActivateFeedback={this.setActivateFeedback}
              main={this.main}
            />
            <Cards path='/cards' cards={cards} updateCards={this.updateCards} currentUserID={this.state.currentUserID} />
            <Contacts path='/contacts' />
            <Profile path='/profile'
              notification_settings={this.state.notification_settings}
              updateNotificationSettings={this.updateNotificationSettings}
              favorite_addresses={() => this.state.favorite_addresses}
              updateFavoriteAddresses={this.updateFavoriteAddresses}
              language = {this.state.language}
              setLanguage = {this.setLanguage}
              bonus_trips={() => this.state.bonus_trips}
              parent_bonus={() => this.state.parent_bonus}
              cashbackAmount={this.state.cashbackAmount}
              geocode={this.geocode}
              isGeocoding={isGeocoding}
              setGeocoding={this.setGeocoding}
              showBurger={this.showBurger}
            />
            <Vendors path='/delivery'
              setCurrentTrip={this.setCurrentTrip}
              showBurger={this.showBurger}
            />
            <Vendor path='/delivery/:id'
              setCurrentTrip={this.setCurrentTrip}
              showBurger={this.showBurger}
            />
            <NotFound type='404' default />
            <Cart path='/delivery/cart'
              cards={() => this.state.cards}
              favorite_addresses={() => this.state.favorite_addresses}
              geocode={this.geocode}
              isGeocoding={isGeocoding}
              setGeocoding={this.setGeocoding}
              showBurger={this.showBurger}
              updateCards={this.updateCards}
            />
          </Router>
          <Prompt />
        </main>
      )
    } else {
      return(
        <main id='app' class='login' ref={main => this.main = main}>
          <Session login = {this.logIn} language={this.state.language} />
          <Prompt />
        </main>
      )
    }
  }
}

render(<App />, document.body);
