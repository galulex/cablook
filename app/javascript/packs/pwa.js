import { h, render, Component } from 'preact';
import { Router } from 'preact-router';
import { route } from 'preact-router';
import { createContext } from "preact-context";
import { Link } from 'preact-router/match';
// import ReactMapboxGl, { Layer, Feature } from 'react-mapbox-gl';
import { Map } from 'mapbox-gl';

import AddressInput from '../pwa/trips/address-input.js';
import Session from '../pwa/session.js';
import Cards from '../pwa/cards.js';
import Bonus from '../pwa/bonus_trips.js';

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
      currentUser: localStorage.token
    }
  }

  handleRoute = e => {
    this.currentUrl = e.url;
  };

  logIn = (token) => {
    this.setState({currentUser: token})
    localStorage.setItem('token', token)
  }

  logOut = () => {
    if (!confirm('Are you sure?')) return;
    this.setState({currentUser: null})
    localStorage.removeItem('token')
  }

  render() {
    if (this.state.currentUser) {
      return(
        <main id="app">
          <nav>
            <Link activeClassName='active' href='/pwa'>Home</Link>
            <Link activeClassName='active' href='/pwa/trips'>Trips</Link>
            <Link activeClassName='active' href='/pwa/bonus_trips'>Bonus</Link>
            <Link activeClassName='active' href='/pwa/cards'>Cards</Link>
            <button onClick={this.logOut}>Log Out</button>
          </nav>
          <Router>
            <Home path='/pwa' />
            <Trips path='/pwa/trips' />
            <Bonus path='/pwa/bonus_trips' />
            <Cards path='/pwa/cards' />
            <Trip path='/pwa/trip' />
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

class Home extends Component {
  constructor(props){
    super(props)
    this.state = {
      trip: {
        waypoints: [],
        stops: ['', ''],
        departure: '',
        destination: '',
        departure_address: '',
        destination_address: '',
        osrm: true
      },
      new: false
    }
    this.setAddress = this.setAddress.bind(this)
  }

  setAddress = (text, coords, index) => {
    this.setState(state => {
      state.trip.waypoints[index] = coords;
      state.trip.stops[index] = text;
      state.trip.departure = state.trip.waypoints[0]
      state.trip.destination = state.trip.waypoints[state.trip.waypoints.length - 1]
      state.trip.departure_address = state.trip.stops[0]
      state.trip.destination_address = state.trip.stops[state.trip.stops.length - 1]
      return state
    })
  }

  addAddress = () => {
    console.log(this.state)
    this.setState(state => {
      state.trip.stops.push('');
    })
  }

  removeAddress = (index) => {
    this.setState(state => {
      state.trip.stops.splice(index, 1);
      state.trip.waypoints.splice(index, 1);
    })
  }

  buildTrip = (e) => {
    const params = this.state.trip
    let component = this
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    console.log(this.state)
    params.waypoints = params.waypoints.slice(1, -2)
    params.stops = params.stops.slice(1, -2)
    fetch('api/trips/new', {
      method: 'post',
      headers: {'Content-Type':'application/json', 'Auth-Token':localStorage.token},
      body: JSON.stringify({ trip: params })
    }).then((response) => {
       if (response.status !== 200) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
      }

      response.json().then(function(data) {
        component.setState(state => {
          state.trip = data
          state.new = true
          return state
        })
      });
    });
  }

  createTrip = (e) => {
    const params = this.state.trip
    let component = this
    console.log(this.state)
    fetch('/api/trips', {
      method: 'post',
      headers: {'Content-Type':'application/json', 'Auth-Token':localStorage.token},
      body: JSON.stringify({ trip: component.state.trip })
    }).then((response) => {
       if (response.status !== 201) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
      }

      response.json().then(function(data) {
        localStorage.setItem('trip', data.id)
        component.setState(state => {
          state.trip = data
          console.log(state)
          return state
        })
      });
    });
  }

  render({ }, { text='Some Text' }) {
    // if (this.state.new) {
    //   return(
    //     <section class="home">
    //     </section>
    //   )
    // } else
    if (!this.state.new && !this.state.trip.id) {
      return(
        <section class="home">
          <header>Search</header>
          <form action='#'>
            { this.state.trip.stops.map((e, i) => {
              return(<AddressInput setAddress = {this.setAddress.bind(this)} removeAddress = { this.removeAddress.bind(this) } index = {i} />)
            })}
            <button type='button' onClick={this.addAddress}>+</button>
            <button type='button' onClick={this.buildTrip}>OK</button>
          </form>
        </section>
      )
    } else {
      return(
        <button type='button' onClick={this.createTrip}>Go</button>
      )
    }
  }
}

class Trips extends Component {
  render() {
    return (
      <section class='trips'>
        <header>Trips</header>
      </section>
    );
  }
}

class Trip extends Component {
  render() {
    console.log(this.props)
    return (
      <section class='trip'>
        <header>Trip Details</header>
      </section>
    );
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
