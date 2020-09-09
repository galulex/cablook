import { h } from 'preact'
import i18n from './i18n.js'

const MAPSTYLE = (localStorage.getItem('dark') === 'true') ? 'okunieva/ckb1wuli60k3u1ipjrdnqtan5' : 'okunieva/cjzwn3wx40yhq1cpjl3yo8p1z'

export default function MapImg(props) {
  const trip = props.trip
  const path_color = window.dark ? ' #ffffff' : ' #19a160'
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
  const src = ('https://api.mapbox.com/styles/v1/' + MAPSTYLE + '/static/pin-s-s+188753(' + departure.join(',') + '),' + waypoints.map((w) => 'pin-s-w+facc1f(' + w + '),').join('') + 'pin-s-f+312d50('+  destination.join(',') + '),path-5+' + (window.getComputedStyle(document.documentElement).getPropertyValue('--path-color') || path_color).slice(2) + '-0.8(' + encodeURIComponent(trip.path) + ')/auto/1024x1024?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ')

  return(
    <img src={src}></img>
  )
}
