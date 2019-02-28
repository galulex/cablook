import { h, render, Component } from 'preact';
import axios from 'axios';

import Star from './images/star.svg'
import Tips from './images/tips.svg'
import Pin from './images/pin.svg'
import Price from './images/trip_price.svg'
import Leaf from './images/leaf_icon.svg'
import i18n from './i18n.js'
import './css/statistics.css'

const Ranges = [
  {name: 'All time', value: 'all_time'},
  {name: 'This mounth', value: 'this_month'},
  {name: 'Last week', value: 'last_week'},
  {name: 'Last mount', value: 'last_mount'}
]

export default class Statistics extends Component {
  constructor(props) {
    super(props)
    this.state = {
      range: 'all_time',
      ranges: Ranges
    }
  }

  render() {
    return (
      <section class='statistics'>
        <header>{i18n.statistics.header}</header>
        <div class='select-section'>
        <label for='range'>{i18n.statistics.period}</label>
        <div class='select'>
          <select id='range' onChange={this.selectRange}>
            {this.state.ranges.map(el => this.renderRange(el))}
          </select>
        </div>
      </div>
      <div class='trip-details-content'><Pin/>{i18n.statistics.distance}<span>Statistics{i18n.statistics.km}</span></div>
      <div class='trip-details-content'><Price/>{i18n.statistics.money}<span>Statistics{i18n.statistics.uah}</span></div>
      <div class='trip-details-content'><Leaf/>{i18n.statistics.orders}<span>Statistics</span></div>
      <div class='trip-details-content'><Star/>{i18n.statistics.rating}<span>Statistics</span></div>
      <div class='trip-details-content'><Tips/>{i18n.statistics.tips}<span>Statistics{i18n.statistics.uah}</span></div>
      </section>
    )
  }

  renderRange = (range) => {
    return(<option value={range.value} key={range.value}>{range.name}</option>)
  }

  selectRange = (e) => {
    this.setState({range: event.target.value})
  }
}