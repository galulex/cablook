import { h, render, Component } from 'preact'
import axios from 'axios'

import i18n from './i18n.js'
import './css/map.css'
import PreviewMap from './map/preview_map.js'

import { PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, CANCELED_BY_DRIVER, CONFIRM_UPDATE_TRIP, MAP_MIN_ZOOM, MAP_MAX_ZOOM, CHERKASY_LONG_LAT } from './lib/constants.js'

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()

export default class NewDesign extends Component {
  constructor(props) {
    super(props)
    this.state = {
      trip: this.props,
      subscription: null,
      car_location: null,
      cars_locations: []
    }
  }

  render() {
    const { trip } = this.state

    return(
      <section class='new_design'>
        <PreviewMap trip={() => trip}/>
      </section>
    )
  }
}

