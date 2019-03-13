import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { createContext } from "preact-context";

import i18n from '../pwa/i18n.js'
import Home from '../pwa/home.js';
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
      drawer: false,
      cards: [],
      bonus_trips: [],
      parent_bonus: [],
      language: localStorage.getItem('language') || i18n.getInterfaceLanguage().split('-')[0],
      favorite_addresses: []
    }
    axios.defaults.headers.common['Pwa-Language'] = this.state.language
  }

  componentDidMount() {
    i18n.setLanguage(this.state.language)
    if (this.state.currentUser) {
      this.fetchFavoriteAddresses()
      this.fetchCards()
      this.fetchBonus()
      document.documentElement.style.setProperty('--body-bg', '#19a160')
    }
    window.addEventListener('offline', this.offline)
    window.addEventListener('online', this.online)
    if (!navigator.onLine) this.offline()
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

  fetchCards = () => {
    axios.get('cards').then((res) => {
      this.setState({cards: res.data.cards})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  fetchBonus = () => {
    axios.get('referrals').then((res) => {
      this.setState({bonus_trips: res.data.bonus_trips, parent_bonus: res.data.parent_bonus})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  fetchFavoriteAddresses = () => {
    axios.get('favorite_addresses').then((res) => {
      this.setState({favorite_addresses: res.data})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  logIn = (data) => {
    this.setState({currentUser: data.auth_token})
    localStorage.setItem('token', data.auth_token)
    localStorage.setItem('referral', data.referral_code)
    if (data.email !== undefined) localStorage.setItem('email', data.email)
    localStorage.setItem('phone', data.phone_number)
    axios.defaults.headers.common['Auth-Token'] = data.auth_token;
    this.fetchCards()
  }

  logOut = (e) => {
    if (!confirm('Are you sure?')) return;
    this.setState({currentUser: null, drawer: false})
    localStorage.removeItem('token')
    e.preventDefault()
  }

  triggerDrawer = (open) => {
    this.setState({drawer: open})
  }

  updateCards = (cards) => {
    this.setState({cards: cards})
  }

  createCard = (data) => {
    let cards = this.state.cards

    axios.post('cards', data).then((res) => {
      cards.push(res.data)
      this.setState({cards: cards})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  setLanguage = (e) => {
    this.setState({language: e.target.value})
    localStorage.setItem('language', e.target.value)
    i18n.setLanguage(this.state.language)
    this.setScriptLanguage()
    axios.defaults.headers.common['Pwa-Language'] = e.target.value
  }

  setScriptLanguage = () => {
    let script = document.getElementById('google-script')
    if (script !== null) script.setAttribute('src', `https://maps.googleapis.com/maps/api/js?key=AIzaSyDx2cLwlAG3muHMV9DVYY3l2PupoYCS-Mk&libraries=places&language=${this.state.language}`);
  }

  render() {
    if (this.state.currentUser) {
      return(
        <main id="app">
          <Drawer active={this.state.drawer} language = {this.state.language} setLanguage = {this.setLanguage} triggerDrawer = {this.triggerDrawer} logOut={this.logOut} bonuses={() => this.state.bonus_trips.filter(e => { return e.status === 1 }).length }/>
          <button class='burger' onClick={() => this.triggerDrawer(true)}>☰</button>
          <Router>
            <Home path='/' cards={() => this.state.cards} bonus_trips={() => this.state.bonus_trips} createCard={this.createCard} language={this.state.language} favorite_addresses={() => this.state.favorite_addresses}/>
            <Trips path='/trips/:id?' />
            <Bonus path='/bonus_trips' bonus_trips={() => this.state.bonus_trips} parent_bonus={() => this.state.parent_bonus} />
            <Cards path='/cards' cards={() => this.state.cards} create={this.createCard} />
            <Contacts path='/contacts' />
            <Statistics path='/statistics' />
            <Profile path='/profile' favorite_addresses={() => this.state.favorite_addresses} />
          </Router>
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
