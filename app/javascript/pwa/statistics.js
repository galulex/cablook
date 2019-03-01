import { h, render, Component } from 'preact';
import axios from 'axios';

import Star from './images/star.svg'
import Tips from './images/tips.svg'
import Pin from './images/pin.svg'
import Amount from './images/trip_price.svg'
import Leaf from './images/leaf_icon.svg'
import i18n from './i18n.js'
import './css/statistics.css'

const initState = {distance: 0, amount: 0, trips_count: 0, rate: 0, tips: 0}

const Periods = [
  {name: i18n.statistics.periods.all_time, value: 'all_time'},
  {name: i18n.statistics.periods.this_month, value: 'this_month'},
  {name: i18n.statistics.periods.last_week, value: 'last_week'},
  {name: i18n.statistics.periods.last_month, value: 'last_month'}
]

export default class Statistics extends Component {
  constructor(props) {
    super(props)
    this.state = {
      period: 'all_time',
      periods: Periods,
      statistics: initState
    }
  }

  componentWillMount() {
    this.getStatistics()
  }

  getStatistics = () => {
    axios.get('statistics', {params: {period: this.state.period}}).then((res) => {
      this.updateStatistics(res.data)
      console.log(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateStatistics = (data) => {
    (data.statistics == null) ? this.setState({statistics: initState}) : this.setState(data)
  }

  render() {
    return (
      <section class='statistics'>
        <header>{i18n.statistics.header}</header>
        <div class='select-section'>
        <label for='range'>{i18n.statistics.period}</label>
        <div class='select'>
          <select id='range' onChange={this.selectPeriod}>
            {this.state.periods.map(el => this.renderPeriod(el))}
          </select>
        </div>
      </div>
      <div class='trip-details-content'><Pin/>{i18n.statistics.distance}<span>{this.state.statistics.distance / 1000}{i18n.statistics.km}</span></div>
      <div class='trip-details-content'><Amount/>{i18n.statistics.amount}<span>{this.state.statistics.amount}{i18n.statistics.uah}</span></div>
      <div class='trip-details-content'><Leaf/>{i18n.statistics.trips_count}<span>{this.state.statistics.trips_count}</span></div>
      <div class='trip-details-content'><Star/>{i18n.statistics.rate}<span>{this.state.statistics.rate}</span></div>
      <div class='trip-details-content'><Tips/>{i18n.statistics.tips}<span>{this.state.statistics.tips}{i18n.statistics.uah}</span></div>
      </section>
    )
  }

  renderPeriod = (period) => {
    return(<option value={period.value} key={period.value}>{period.name}</option>)
  }

  selectPeriod = (e) => {
    this.setState({period: event.target.value}, () => {
      this.getStatistics()
    })
  }
}