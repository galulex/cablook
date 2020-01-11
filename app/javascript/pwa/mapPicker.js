import { h, render, Component } from 'preact';
import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl from 'mapbox-gl'
import MapboxLanguage from '@mapbox/mapbox-gl-language';

import i18n from './i18n.js'
import Back from './images/arrow-left.svg'
import Pin from './images/pin.svg'
import './css/picker.css'

mapboxgl.accessToken = 'pk.eyJ1IjoiZ2FsdWxleCIsImEiOiJjamx6ampoZjgyMnYxM3FvZ2ppNjV2M2x5In0.bPgk2WI9NT-DJwnE-OtiLA';

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

    let style = window.dark ? 'mapbox://styles/galulex/cju84cmu11atr1flfoxocwbq7' : 'mapbox://styles/mapbox/streets-v10';
    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: style,
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

    this.map.on('dragstart', () => {
      this.hideAddressBar()
    });

    this.map.on('zoom', () => {
      this.hideAddressBar()
    });

    this.map.on('dragend', () => {
      timeout = setTimeout(this.showAddressBar, delay_time)
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

  setAddressData = (addressData) => {
    this.setState({ address_bar: true, address: `${addressData.addressInfo[0]}${addressData.addressInfo[1]}` });
  }

  showAddressBar = () => {
    const { lng, lat } = this.map.getCenter();

    this.props.getAddressInfo([lat, lng], this.setAddressData)
  }

  hideAddressBar = () => {
    clearTimeout(timeout)
    this.setState({ address_bar: false, address: '' })
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
        <button type='button' class='button fixed' onClick={this.props.onCloseMap([this.state.lng, this.state.lat])}>OK</button>
      </div>
    );
  }
}
