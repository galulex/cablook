<script>
  import { getContext } from 'svelte'
  import { contextKey } from '@beyonk/svelte-mapbox'
  import { onMount, afterUpdate } from 'svelte'

  import polyline from '@mapbox/polyline'

  export let trip

  const { getMap, getMapbox } = getContext(contextKey)
  const map = getMap()
  const mapbox = getMapbox()

  const GEOJSON = {
    "type": "FeatureCollection",
    "features": [{
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": polyline.toGeoJSON(trip.path),
        "type": "LineString"
      }
    }]
  }

  const PATHLAYER = {
    type: 'line',
    source: `line_${trip.id}`,
    id: `line_${trip.id}`,
    paint: {
      'line-color': '#19a160',
      'line-width': 40,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0, '#312d50',
        1, '#19a160'
      ]
    },
    layout: {
      'line-cap': 'round',
      'line-join': 'round'
    }
  }

  onMount(() => {
    map.addSource(`line_${trip.id}`, { type: 'geojson', lineMetrics: true, data: GEOJSON })
    map.addLayer(PATHLAYER)
    trip.waypoints.map(addPin)
  })

  let addPin = (w, i) => {
    let pin = new mapbox.Marker({color: color(i)})
    const popup = new mapbox.Popup({ className: 'stop', closeButton: false, closeOnClick: false })
    popup.setText(trip.stops[i])
    pin.setLngLat(w.split(',').reverse()).setPopup(popup).addTo(map).togglePopup()
  }

  let color = (i) => {
    if (i === trip.stops.length - 1) return '#19a160'
    if (i !== 0) return '#efcc3a'
    return '#312d50'
  }

</script>
