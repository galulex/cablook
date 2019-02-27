import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import styles from './css/statistic.css'

export default class Statistic extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <section>
        <header>{i18n.statistic.header}</header>
      </section>
    )
  }
}