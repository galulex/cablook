import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import SearchLogo from './images/search_logo.svg'
import './css/find_driver.css'

export default class FindDriver extends Component {
  constructor(props){
    super(props)
  }

  componentDidMount() {
    this.props.subscribe()
    if (this.props.trip.status !== 6) return;
    this.props.TripDeclined()
  }

  render() {
    return(
      <div class='find_driver'>
        <section>
          <div class='address-block'>
            <address>{this.props.trip.departure_address}</address>
            <address>{this.props.trip.destination_address}</address>
          </div>
          <SearchLogo class='search_logo'/>
          <button class='cancel' type='button' onClick={this.props.cancel}>{i18n.find_driver.cancel}</button>
        </section>
      </div>
    )
  }
}
