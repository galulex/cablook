import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { route } from 'preact-router';
import { createContext } from "preact-context";
// import ReactMapboxGl, { Layer, Feature } from 'react-mapbox-gl';
import { Map } from 'mapbox-gl';

import CurrentTrip from '../pwa/current-trip.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Bonus from '../pwa/bonus_trips.js';
import Contacts from '../pwa/contacts.js';
import Trips from '../pwa/trips.js';
import Drawer from '../pwa/drawer.js';

// const Map = ReactMapboxGl({
//   accessToken: 'pk.eyJ1IjoiYnJ1Y2VsaWF0b3IiLCJhIjoiY2oxcTJ5dDNzMDA2ajMybnR6M3V5cGVubiJ9.qjyqnH72UUVnsaY63OzMGg'
// });
//
import axios from 'axios';
axios.defaults.baseURL = 'http://localhost:3000/api';
axios.defaults.headers.common['Auth-Token'] = localStorage.token;
axios.defaults.headers.common['Content-Type'] = 'application/json';

export default class App extends Component {

  constructor(props){
    super(props)
    this.state = {
      currentUser: localStorage.token,
      drawer: false
    }
  }

  handleRoute = e => {
    this.currentUrl = e.url;
  };

  logIn = (data) => {
    this.setState({currentUser: data.auth_token})
    localStorage.setItem('token', data.auth_token)
    localStorage.setItem('email', data.email)
    localStorage.setItem('referral', data.referral_code)
    localStorage.setItem('email', data.email)
    localStorage.setItem('phone', data.phone_number)
    axios.defaults.headers.common['Auth-Token'] = data.auth_token;
  }

  logOut = () => {
    if (!confirm('Are you sure?')) return;
    this.setState({currentUser: null})
    localStorage.removeItem('token')
  }

  triggerDrawer = (open) => {
    this.setState({drawer: open})
  }

  render() {
    if (this.state.currentUser) {
      return(
        <main id="app">
          <Drawer active={this.state.drawer} triggerDrawer = {this.triggerDrawer.bind(this)} logOut={this.logOut.bind(this)}/>
          <button class='burger' onClick={() => this.triggerDrawer(true)}>☰</button>
          <Router>
            <CurrentTrip path='/pwa' />
            <Trips path='/pwa/trips' />
            <Bonus path='/pwa/bonus_trips' />
            <Cards path='/pwa/cards' />
            <Contacts path='/pwa/contacts' />
          </Router>
        </main>
      )
    } else {
      return(
        <Session login = {this.logIn.bind(this)} ></Session>
      )
    }
  }
}

// class Map extends Component {
//   render() {
//     let trip = this.props.trip
//     let src = '';
//     let width = (window.innerWidth > 1280) ? 1280 : window.innerWidth
//     let height = (window.innerHeight > 1280) ? 1280 : window.innerHeight
//     src = `https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(${trip.departure}),${trip.waypoints}pin-s-f+312d50(${trip.destination}),path-5+188753-0.8(${encodeURIComponent(trip.path)})/auto/${width}x${height}?access_token=pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA`
//     return (
//       <img src={src} class='map'/>
//     );
//   }
// }

render(<App />, document.body);
