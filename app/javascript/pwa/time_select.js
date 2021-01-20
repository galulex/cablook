import { h } from 'preact'

import i18n from './i18n.js'
import Clock from './images/clock.svg'

export default function TimeSelect(props) {
  const minDeliveryTime = `${(new Date().getHours() + 1).toString().padStart(2, '0')}:${new Date().getMinutes().toString().padStart(2, '0')}`
  const time = props.time || minDeliveryTime

  return (
    <label htmlFor='time'>
      <Clock width='24' fill='#312d50'/>
      <input id='time' required type='time' step='60' title='HH:MM' pattern='([01]?[0-9]|2[0-3]):[0-5][0-9]'
        value={time} min={minDeliveryTime} max={props.close_at} onChange={this.props.setTime}/>
    </label>
  )
}
