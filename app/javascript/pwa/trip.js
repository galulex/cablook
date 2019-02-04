import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import './css/trips.css'

export default class Trip extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <section class='trips'>
        <header>{i18n.trips.header}</header>
        <h1>Trip</h1>
      </section>
    );
  }
}
