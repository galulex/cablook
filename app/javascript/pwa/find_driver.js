import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import SearchLogo from './images/search_logo.svg'
import './css/find_driver.css'

export default class FindDriver extends Component {
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

  componentDidMount() {
    this.props.subscribe()

    window.addEventListener('popstate', this.handleBack)
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleBack);
    if (!window.ios) window.history.back()
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
          <SearchLogo class='search_logo'/>
          <button disabled={this.state.disabled} class='button fixed cancel' type='button' onClick={this.cancel}>{i18n.find_driver.cancel}</button>
        </section>
      </div>
    )
  }
}
