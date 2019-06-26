import { h, render, Component } from 'preact';

import i18n from './i18n.js';
import './css/time_array.css'
import './css/current_trip.css'

export default class GenerateArrayTimes extends Component {
  constructor(props) {
    super(props);
    this.state = {
      times: []
    }
    this.generateTimes()
  }

  generateTimes = () => {
    let { start_time, finish_time } = this.props
    const { times } = this.state
    const today = new Date()

    start_time = (today.getHours() > start_time) ? today.getHours() + 1 : start_time + 1
    finish_time = finish_time - 1

    const quarterHours = ["00", "10", "20", "30", "40", "50"]

    for(let i = start_time; i < finish_time; i++) {
      for(let j = 0; j < quarterHours.length; j++) {
        if ((today.getHours() + 1) === i && today.getMinutes() > quarterHours[j]) continue;
        const time = i + ":" + quarterHours[j]

        times.push(time)
      }
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
        <span>{i18n.current_trip.when}</span>
        <select id='select_time' onChange={(e) => this.updateTripTime(e)}>
          {this.state.times.map((val, index) => {
            return(<option key={index} value={val}>{val}</option>)
          })}
        </select>
      </label>
    )
  }
}
