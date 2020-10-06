<script>
  import { getContext } from 'svelte'
  import { contextKey } from '@beyonk/svelte-mapbox'
  import { onMount, afterUpdate } from 'svelte'

  import '../../../css/map.css'

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
        "coordinates": polyline.decode(trip.path).map(e => { return e.reverse() }),
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
      'line-width': 4,
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
    let marker = document.createElement('div');
    marker.className = 'marker-path';
    marker.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width='180px' height='80px' viewBox="0 0 602.6 236.7"><path fill="#FFF" d="M603 23c0-13-11-23-23-23H77C35 0 0 35 0 77c0 62 74 160 77 160 1 0 11-13 23-31h480c12 0 23-10 23-23V23z"/><path fill="${color(i)}" d="M140 79a63 63 0 00-126 0c0 50 61 130 63 130s63-80 63-130zm-63 24a23 23 0 010-47 23 23 0 010 47z"/></svg> <span>${trip.stops[i]}</span>`;
    let pin = new mapbox.Marker(marker)
    pin.setLngLat(w.split(',').reverse()).addTo(map)
  }

  let color = (i) => {
    if (i === trip.stops.length - 1) return '#19a160'
    if (i !== 0) return '#efcc3a'
    return '#312d50'
  }

</script>
