<script>
  import { afterUpdate } from 'svelte'

  export let trip

  let markers
  let url

  let zoom = (e) => {
    let zoomer = e.currentTarget;
    zoomer.firstChild.style.opacity = 0
    const offsetX = e.offsetX || e.touches[0].pageX
    const offsetY = e.offsetY || e.touches[0].pageY
    const x = offsetX / zoomer.offsetWidth * 100
    const y = offsetY / zoomer.offsetHeight * 100
    zoomer.style.backgroundPosition = `${x}% ${y}%`
    e.preventDefault()
  }

  let zoomEnd = (e) => {
    e.currentTarget.firstChild.style.opacity = 1
  }

  afterUpdate(() => {
    markers = trip.waypoints.map((w, i) => {
      return `pin-s-${i + 1}+188753(${w.split(',').reverse().join()})`
    })

    url = `https://api.mapbox.com/styles/v1/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z/static/path-3+19a160-0.8(${encodeURIComponent(trip.path)}),${markers}/auto/600x500@2x?access_token=pk.eyJ1IjoidHVwaWNraXl2IiwiYSI6ImNqcmJ1YjJsNDE2eTEzeXM3dnc4NGljZDIifQ.N5aaBOWqp1mCTjlxXrWzOQ`
  })
</script>

<style>
  .zoom img {
    transition: opacity .5s;
    display: block;
    width: 100%;
    max-height: 45vh;
    object-fit: cover;
  }

  figure.zoom {
    background-position: 50% 50%;
    position: relative;
    overflow: hidden;
    cursor: zoom-in;
    margin: 0;
    width: 100%;
  }
</style>

<figure class='zoom' style={`background: url('${url}')`} on:touchmove={zoom} on:touchstart={zoom} on:touchend={zoomEnd} on:mousemove={zoom} on:mouseleave={zoomEnd}>
  <img alt='Map' src={url}>
</figure>
