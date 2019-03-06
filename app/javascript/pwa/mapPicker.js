import { h, render, Component } from 'preact';
import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

import i18n from './i18n.js'
import Back from './images/arrow-left.svg'
import Pin from './images/pin'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA';

export default class MapPicker extends Component {
  constructor(props) {
    super(props);
    this.map = null;
    this.state = {
      lng: 32.059769,
      lat: 49.444431,
      zoom: 12
    };
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state;

    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: 'mapbox://styles/mapbox/streets-v10',
      center: [lng, lat],
      zoom
    });

    this.map.on('move', () => {
      const { lng, lat } = this.map.getCenter();

      this.setState({
        lng: lng,
        lat: lat,
        zoom: this.map.getZoom().toFixed(2)
      });
    });

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true
    });

    const language = new MapboxLanguage({
      defaultLanguage: this.setMapboxLangauge()
    });

    this.map.addControl(language);
    this.map.addControl(geolocate);
    this.map.on('load', () => geolocate.trigger());
  }

  componentWillUnmount() {
    this.map.remove()
  }

  setMapboxLangauge = () => {
    return (this.props.language === 'uk') ? 'ru' : this.props.language
  }

  render() {
    const style = {
      position: "fixed",
      left: "0",
      right: "0",
      top: "54px",
      bottom: "0",
      background: '#eae6e0'
    };

    const buttonStyle = {
      background: "#19A160",
      padding: "1rem",
      width: "44%",
      color: "white",
      textAlign: "center",
      position: "fixed",
      bottom: "15px",
      zIndex: "2",
      marginLeft: "-22%",
      left: "50%"
    };

    const pinStyle = {
      maxHeight: "30px",
      maxWidth: "30px",
      top: "0",
      bottom: "0",
      left: "0",
      right: "0",
      position: "fixed",
      zIndex: "5",
      margin: "auto"
    };

    return (
      <div class='trip-details'>
        <header>
          {i18n.map_picker.header}
          <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
        </header>
        <div ref={el => this.mapContainer = el} style={style}  />
        <Pin color={"#19A160"} fillColor={"#19A160"} style={pinStyle}/>
        <button type='button' class='button fixed' onClick={this.props.onCloseMap([this.state.lng, this.state.lat])}>OK</button>
      </div>
    );
  }
}
