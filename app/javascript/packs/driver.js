import { h, render, Component } from 'preact';
import { Router } from 'preact-router';

import i18n from '../pwa/i18n.js'
import Session from '../driver/session.js';
import Drawer from '../driver/drawer.js';
import Home from '../driver/home.js';

import Burger from '../pwa/images/burger.svg';

import '../pwa/css/buttons.css';

import axios from 'axios';
axios.defaults.baseURL = '/api/drivers_app';
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

  logIn = (data) => {
    this.setState({currentUser: data.auth_token})
    localStorage.setItem('token', data.auth_token)
    localStorage.setItem('car', data.car.number)
    localStorage.setItem('username', data.username)
    axios.defaults.headers.common['Auth-Token'] = data.auth_token;
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

  render() {
    if (this.state.currentUser) {
      return(
        <main id="app">
          <Drawer active={this.state.drawer} triggerDrawer = {this.triggerDrawer} logOut={this.logOut} bonuses={() => this.state.bonus_trips.filter(e => { return e.status === 1 }).length }/>
          <button class='burger' onClick={() => this.triggerDrawer(true)}><Burger/></button>
          <Router>
            <Home path='/'/>
          </Router>
        </main>
      )
    } else {
      return(
        <main id='app' class='login'>
          <Session login = {this.logIn} />
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
