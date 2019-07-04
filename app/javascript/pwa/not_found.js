import { h, render, Component } from 'preact'

import i18n from './i18n.js'
import './css/not_found.css'
import NotFoundText from './images/404/404.svg'
import Car from './images/leaf.svg'
import Blot from './images/404/Blot.svg'
import TireTracks from './images/404/Tire_tracks.svg'

export default class NotFound extends Component {
  render() {
    return (
      <div class='not-found-page'>
        <NotFoundText class='not-found-text'/>
        <Car class='car'/>
        <Blot class='blot'/>
        <TireTracks class='tire-tracks'/>
      </div>
    )
  }
}

