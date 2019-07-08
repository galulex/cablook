import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import LogoLight from './images/logo_light.svg'
import './css/find_driver.css'

export default class RetryTrip extends Component {
  constructor(props){
    super(props)
    this.state = {
      disabled: false
    }
  }

  cancel = (e) => {
    this.setState({disabled: true})
    this.props.cancel(e, () => {this.setState({disabled: false})})
  }

  retry = (e) => {
    this.setState({disabled: true})
    this.props.retry(e, () => {this.setState({disabled: false})})
  }

  componentDidMount() {
    if (window.ios) return;
    history.pushState(null, null, document.URL)
    window.addEventListener('popstate', this.handleBack)
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack);
  }

  handleBack = (event) => {
    history.pushState(null, null, document.URL)
  }

  render() {
    return(
      <div class='find_driver'>
        <section>
          <div class='address-block'>
            <address>{this.props.trip.departure_address}</address>
            <address>{this.props.trip.destination_address}</address>
          </div>
          <LogoLight class='retry-page-logo'/>
          <div class='retry-message-block'>
            <h1>{i18n.retry_trip.retry_message}</h1>
          </div>
          <button disabled={this.state.disabled} class='button fixed retry' type='button' onClick={this.retry}>{i18n.retry_trip.retry}</button>
          <button disabled={this.state.disabled} class='button fixed cancel' type='button' onClick={this.cancel}>{i18n.find_driver.cancel}</button>
        </section>
      </div>
    )
  }
}
