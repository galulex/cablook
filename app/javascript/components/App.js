import React, { Component } from 'react'
import axios from 'axios'

import Confirmation from './Confirmation'
import UserPage from './UserPage'
import MapScreen from './MapScreen'
import NumberForm from './NumberForm'
import TripScreen from './TripScreen'
import Trip from './Trip'
import Card from './Card'
import Bonus from './Bonus'
import Localization from '../localization/Localization'


export default class App extends Component {
  constructor(props){
    super(props)
    Localization.setLanguage('ua')
    this.state = {
      number: '',
      path: '',
      cards: [],
      bonus_trips: []
    }
  }

  componentDidMount = () => {
    window.addEventListener('load', null, this.handleLoad())
  }

  createCard = (attrs) => {
    Card.create(attrs).then(response =>{
        localStorage.ready = true
        this.fetchCards()
      }).catch(err =>
        alert(err.response.data.errors)
      )
  }

  addBonusTrips = (bonus_trips) => {
    bonus_trips.map((el) => this.addBonusTrip(el))
  }

  fetchCards = () => {
    Card.fetch().then(res => {
        if (res.data['cards'].length > 0) localStorage.ready = true
        this.setState({ cards: res.data['cards'] })
        this.fetchBonusTrips()
      }).catch(err =>
        alert(err.response.data.errors)
      )
  }

  fetchBonusTrips = () => {
    Bonus.fetch().then(response => {
        if (response.data['bonus_trips'].some((bonus_trip) => { return bonus_trip.status == 1 }))
          this.addBonusTrips(response.data['bonus_trips'])
          this.state.bonus_trips
      }).catch(err =>
        alert(err.response.data.errors)
      )
  }

  handleLoad = () => {
    document.getElementById('nissan').classList.remove('loader')
    if (localStorage.referralCode){
      this.updateNumber(localStorage.phone)
      this.fetchCards()
      if (localStorage.trip) {
        axios({method: 'GET',url:'api/trips/' + localStorage.trip, data: null, headers: {'Auth-Token': localStorage.token}}).then(response => {
          const trip = response.data
          if (trip.status == 0) {
            this.setStep(5)
            Trip.subscribe(this)
            return false
          }
          if (trip.status < 3) {
            this.setStep(5)
            Trip.showTrip({trip: trip})
            Trip.subscribe(this)
          } else {
            localStorage.removeItem('trip')
            this.setStep(3)
          }
        })
        return false
      }
      this.setStep(3)
      return false
    }
    this.setStep(1)
  }

  setStep = (step) => {
    this.setState({ step })
  }

  updateNumber = (number) => {
    this.setState({ number })
  }

  addBonusTrip = (bonus) => {
    this.setState({
      bonus_trips: [...this.state.bonus_trips, bonus]
    })
  }

  updatePath = (path) => {
    this.setState({ path })
  }

  renderComponent = () => {
    const { step, number, cards, bonus_trips, path } = this.state
    switch(this.state.step){
      case 1:
        return (
          <NumberForm
            updateStep={this.setStep}
          />
        )
      case 2:
        return (
          <Confirmation
            updateStep={this.setStep}
            number={number}
            updateNumber={this.updateNumber}
            fetchCards={this.fetchCards}
            cards={cards}
          />
        )
      case 3:
        return (
          <UserPage
            updateStep={this.setStep}
            number={number}
            setPath={this.updatePath}
          />
        )
      case 4:
        return(
          <MapScreen
            updateStep={this.setStep}
            path={path}
            cards={cards}
            bonuses={bonus_trips}
            createCard={this.createCard}
        />
        )
      case 5:
        return(
          <TripScreen
            updateStep={this.setStep}
          />
        )
    }
  }

  render () {
    return (
      <div className='container'>
        {this.renderComponent()}
      </div>
    );
  }
}
