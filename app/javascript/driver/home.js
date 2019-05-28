import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from '../pwa/i18n.js'
import Map from '../mapbox/map.js'

const ActionCable = require('actioncable')
const cable = ActionCable.createConsumer()

export default class Home extends Component {
  constructor(props) {
    super(props)
    this.state = {
      subscription: null,
      cars_locations: []
    }
  }

  componentDidMount() {
    this.getCarsLocations()
    this.subscribe()
  }

  componentWillUnmount() {
    this.unsubscribe()
  }

  subscribe = () => {
    if (this.state.subscription) return this.state.subscription
    this.setState({subscription: cable.subscriptions.create(
      { channel: 'DriverMapChannel' },
      {
        received: data => {
          let cars_locations = this.state.cars_locations
          let found = false

          cars_locations = cars_locations.map((l) => {
            if (l.car_id == data['car_id']) {
              found = true
              l.location = data['location'].reverse()
            }
            return l
          })
          if (!found) { cars_locations = [...cars_locations, { car_id: data['car_id'], location: data['location'].reverse() }] }
          this.setState({ cars_locations })
        }
      }
    )})
  }

  unsubscribe = () => {
    if (this.state.subscription) this.state.subscription.unsubscribe()
    this.setState({subscription: null})
  }

  getCarsLocations = () => {
    axios.get('maps').then((res) => {
      let cars_locations = this.state.cars_locations
      res['data']['cars'].forEach((data) => {
        cars_locations = [...cars_locations, { car_id: data['id'], color: data['color'], location: data['location'].reverse() }]
      })
      this.setState({ cars_locations })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    return(
      <section>
        <header>Home</header>
        <h1>Home</h1>
        <Map cars_locations={this.state.cars_locations}/>
      </section>
    )
  }
}
