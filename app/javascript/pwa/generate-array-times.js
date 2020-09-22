import { h, render, Component } from 'preact';

import i18n from './i18n.js';
import './css/current_trip.css'
import Clock from './images/clock.svg'

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

export default class GenerateArrayTimes extends Component {
  constructor(props) {
    super(props);
    this.state = {
      times: []
    }
    this.generateTimes()
  }

  generateTimes = () => {
    let { open_at, close_at, weekends } = this.props
    const { times } = this.state
    const today = new Date()
    const day = today.getDay()

    let start = parseInt(open_at[0])* 60 + parseInt(open_at[1])
    let close = parseInt(close_at[0]) * 60 + parseInt(close_at[1])
    let current = today.getHours() * 60 + Math.floor(today.getMinutes()/10)*10
    if ((Math.abs(current - start) > 60 && current < start) || weekends.includes(DAYS[day - 1]) ) {
      this.props.setTripTime(null)
      return
    }
    start = (current > start - 60) ? current : start
    let range = Math.abs(close - start)

    for(let i = 60; i <= range - 60; i += 10) {
      let time = start + i
      if (time >= 24*60) time = Math.abs(60*24 - time)
      if (time >= close && time < start) continue;
      times.push(`${('0' + Math.floor(time/60)).slice(-2)}:${('0' + time%60).slice(-2)}`)
    }
    this.setState({ times })
    this.props.setTripTime(times[0])
  }

  updateTripTime = (e) => {
    this.props.updateTripTime(e)
  }

  render() {
    return (
      <label for='select_time'>
        <Clock width='24'/>
        <select id='select_time' onChange={(e) => this.updateTripTime(e)}>
          {this.state.times.map((val, index) => {
            return(<option key={index} value={val}>{val}</option>)
          })}
        </select>
      </label>
    )
  }
}
