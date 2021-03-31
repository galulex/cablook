import { h } from 'preact'

import i18n from './i18n.js'
import Clock from './images/clock.svg'

export default function TimeSelect(props) {
  let allDay = props.open_at === '02:00' && props.close_at === '01:59'

  return (
    <label htmlFor='time'>
      <Clock width='24' fill='#312d50'/>
      <input id='time' required type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]'
        value={props.time} min={props.minTime} max={allDay ? '' : props.close_at} onChange={this.props.setTime}/>
    </label>
  )
}
