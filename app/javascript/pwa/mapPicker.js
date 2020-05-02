import { h, render, Component } from 'preact';
import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

import i18n from './i18n.js'
import Back from './images/arrow-left.svg'
import Pin from './images/pin.js'
import './css/picker.css'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA';
const MAPSTYLE = (localStorage.getItem('dark') === 'true') ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/okunieva/cjzwn3wx40yhq1cpjl3yo8p1z';
const LANGUAGES = {en: 'en', uk: 'ru', ru: 'ru'}

var timeout
var delay_time = 500

export default class MapPicker extends Component {
  constructor(props) {
    super(props);
    this.map = null;
    this.state = {
      address_bar: false,
      address: '',
      lng: 32.059769,
      lat: 49.444431,
      zoom: 12
    };
  }

  componentDidMount() {
    const { lng, lat, zoom } = this.state;

    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: MAPSTYLE,
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

    this.map.on('movestart', () => {
      this.hideAddressBar()
      this.props.setGeocoding(true)
    });

    this.map.on('moveend', () => {
      timeout = setTimeout(this.showAddressBar, delay_time)
    });

    const geolocate = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: false
    });

    const language = new MapboxLanguage({
      defaultLanguage: LANGUAGES[this.props.language]
    });

    this.map.addControl(language);
    this.map.addControl(geolocate);
    this.map.addControl(new mapboxgl.NavigationControl({showCompass: false}));
    this.map.on('load', () => geolocate.trigger());

    if (window.dark) {
      let mapboxCtrlRight = document.getElementsByClassName('mapboxgl-ctrl-top-right');
      mapboxCtrlRight[0].classList.add('dark');
    }
  }

  componentWillUnmount() {
    this.map.remove()
  }

  showAddressBar = () => {
    const { lng, lat } = this.map.getCenter();

    this.props.geocode(`${lng},${lat}`, (address) => {
      this.props.setGeocoding(false)
      this.setState({ address_bar: true, address: address });
    })
  }

  hideAddressBar = () => {
    if (timeout) clearTimeout(timeout)
    timeout = null
    this.setState({ address_bar: false, address: '' })
  }

  render() {
    const style = {
      position: "fixed",
      left: "0",
      right: "0",
      top: "50px",
      bottom: "0",
      background: 'var(--map-bg)'
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
          <button type='button' class='burger' onClick={() => window.ios ? this.props.handleBack() : window.history.back()}><Back/></button>
        </header>
        <div ref={el => this.mapContainer = el} style={style}  />
        { this.state.address_bar &&
          <div class='address-bar'>{ this.state.address }</div>
        }
        <Pin class='picker-pin'/>
        <button type='button' 
                disabled={this.props.isGeocoding} 
                class='button fixed' 
                onClick={() => { this.props.onCloseMap(`${this.state.lat},${this.state.lng}`, this.state.address) }}>
                OK
                </button>
      </div>
    );
  }
}
