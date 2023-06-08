import { h } from 'preact'
import i18n from './i18n.js'

const TOKEN = 'pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ'
const BASE_URL = 'https://api.mapbox.com/styles/v1/okunieva'

export default function MapImg(props) {
  const trip = props.trip
  const departure = []
  const destination = []
  const waypoints = []

  trip.departure.map((el, index) => departure[index] = el)
  trip.destination.map((el, index) => destination[index] = el)
  destination.reverse()
  departure.reverse()
  trip.waypoints.slice(1).map((w, index) => {
    waypoints[index] = `pin-s-w+facc1f(${w.split(',').reverse()})`
  })

  const colors = {
    map: window.dark ? 'ckb1wuli60k3u1ipjrdnqtan5' : 'cjzwn3wx40yhq1cpjl3yo8p1z',
    departure: window.dark ? '38b04c' : '136320',
    path: window.dark ? 'ffffff' : '19a160',
    finish: window.dark ? '05961c' : '024f0e'
  }

  const path = `path-5+${colors.path}-0.8(${encodeURIComponent(trip.path)})`
  const departurePoint = `pin-s-s+${colors.departure}(${departure})`
  const finishPoint = `pin-s-f+${colors.finish}(${destination.join(',')})`

  const src = `${BASE_URL}/${colors.map}/static/${path},${departurePoint},${waypoints.join(',')},${finishPoint}/auto/1024x1024?padding=90&access_token=${TOKEN}`

  return(
    <img src={src}></img>
  )
}
