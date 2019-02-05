import { h, render, Component } from 'preact';

import i18n from './i18n.js'

export default class MapImg extends Component {
  constructor(props) {
    super(props);
    this.state = {
      trip: this.props.trip()
    }
  }

  componentWillReceiveProps() {
    this.setState({trip: this.props.trip()})
  }

  renderDetails = () => {
    const trip = this.state.trip;

    const departure = []
    const destination = []
    const waypoints = []
    trip.departure.map((el, index) => departure[index] = el)
    trip.destination.map((el, index) => destination[index] = el)
    destination.reverse()
    departure.reverse()
    trip.waypoints.map((w, index) => {
      waypoints[index] = w.split(',').reverse().join(',')
    })
    return ('https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+188753-0.8(' + encodeURIComponent(trip.path) + ')/auto/600x600?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ')
  }

  render() {
    return(
      <img src={this.renderDetails()}></img>
    )
  }
}
