import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import './css/statistic.css'

const Ranges = [
  {name: 'All time', value: 'all_time'},
  {name: 'This mounth', value: 'this_month'},
  {name: 'Last week', value: 'last_week'},
  {name: 'Last mount', value: 'last_mount'}
]

export default class Statistic extends Component {
  constructor(props) {
    super(props)
    this.state = {
      range: 'all_time',
      ranges: Ranges
    }
  }

  render() {
    return (
      <section class='statistic'>
        <header>{i18n.statistic.header}</header>
        <div class='select-section'>
        <label for='range'>{i18n.statistic.period}</label>
        <div class='select'>
          <select id='range' onChange={this.selectRange}>
            {this.state.ranges.map(el => this.renderRange(el))}
          </select>
        </div>
      </div>
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