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

import '../pwa/css/buttons.css';

import axios from 'axios';
axios.defaults.baseURL = '/api';
axios.defaults.headers.common['Auth-Token'] = localStorage.token;
axios.defaults.headers.common['Content-Type'] = 'application/json';

i18n.setLanguage(i18n.getInterfaceLanguage())

export default class App extends Component {

  constructor(props){
    super(props)
    this.state = {
      currentUser: localStorage.token,
      drawer: false,
      cards: [],
      bonus_trips: [],
      parent_bonus: [],
    }
  }

  componentDidMount() {
    if (this.state.currentUser) {
      this.fetchCards()
      this.fetchBonus()
      document.documentElement.style.setProperty('--body-bg', '#19a160')
    }
    window.addEventListener('offline', this.offline)
    window.addEventListener('online', this.online)
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
    this.setState({currentUser: null})
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

  render() {
    if (this.state.currentUser) {
      return(
        <main id="app">
          <Drawer active={this.state.drawer} triggerDrawer = {this.triggerDrawer} logOut={this.logOut} bonuses={() => this.state.bonus_trips.filter(e => { return e.status === 1 }).length }/>
          <button class='burger' onClick={() => this.triggerDrawer(true)}>☰</button>
          <Router>
            <Home path='/' cards={() => this.state.cards} bonus_trips={() => this.state.bonus_trips} createCard={this.createCard} />
            <Trips path='/trips/:id?' />
            <Bonus path='/bonus_trips' bonus_trips={() => this.state.bonus_trips} parent_bonus={() => this.state.parent_bonus} />
            <Cards path='/cards' cards={() => this.state.cards} create={this.createCard} />
            <Contacts path='/contacts' />
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
window.addEventListener('resize', () => {
  document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
});
