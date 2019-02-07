import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { route } from 'preact-router';
import { createContext } from "preact-context";
// import ReactMapboxGl, { Layer, Feature } from 'react-mapbox-gl';
import { Map } from 'mapbox-gl';

import Home from '../pwa/home.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Bonus from '../pwa/bonus_trips.js';
import Contacts from '../pwa/contacts.js';
import Trips from '../pwa/trips.js';
import Drawer from '../pwa/drawer.js';
import FindDriver from '../pwa/find_driver.js';

import '../pwa/css/buttons.css';

// const Map = ReactMapboxGl({
//   accessToken: 'pk.eyJ1IjoiYnJ1Y2VsaWF0b3IiLCJhIjoiY2oxcTJ5dDNzMDA2ajMybnR6M3V5cGVubiJ9.qjyqnH72UUVnsaY63OzMGg'
// });
//
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
      bonus_trips: []
    }
  }

  componentDidMount() {
    if (this.state.currentUser) {
      this.fetchCards()
      this.fetchBonus()
    }
  }

  handleRoute = e => {
    this.currentUrl = e.url;
  };

  fetchCards = () => {
    axios.get('cards').then((res) => {
      this.setState({cards: res.data.cards})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  fetchBonus = () => {
    axios.get('bonus_trips').then((res) => {
      this.setState({bonus_trips: res.data.bonus_trips})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  logIn = (data) => {
    this.setState({currentUser: data.auth_token})
    localStorage.setItem('token', data.auth_token)
    localStorage.setItem('email', data.email)
    localStorage.setItem('referral', data.referral_code)
    localStorage.setItem('email', data.email)
    localStorage.setItem('phone', data.phone_number)
    axios.defaults.headers.common['Auth-Token'] = data.auth_token;
    this.fetchCards()
  }

  logOut = () => {
    if (!confirm('Are you sure?')) return;
    this.setState({currentUser: null})
    localStorage.removeItem('token')
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
          <Drawer active={this.state.drawer} triggerDrawer = {this.triggerDrawer} logOut={this.logOut}/>
          <button class='burger' onClick={() => this.triggerDrawer(true)}>☰</button>
          <Router>
            <Home path='/' cards={() => this.state.cards} bonus_trips={() => this.state.bonus_trips} />
            <Trips path='/trips' />
            <Bonus path='/bonus_trips' />
            <Cards path='/cards' cards={() => this.state.cards} updateCards={this.updateCards} />
            <Contacts path='/contacts' />
          </Router>
        </main>
      )
    } else {
      return(
        <Session login = {this.logIn} ></Session>
      )
    }
  }
}

render(<App />, document.body);

document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
window.addEventListener('resize', () => {
  document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
});
