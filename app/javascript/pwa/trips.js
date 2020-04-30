import { h, render, Component } from 'preact';
import axios from 'axios';
import './css/trips.css'
import './css/buttons.css'

import i18n from './i18n.js'
import TripCard from './tripCard.js'
import Back from './images/arrow-left.svg'

const PER_PAGE = 10;

export default class Trips extends Component {
  constructor(props) {
    super(props);
    this.state = {
      trips: this.props.trips || [],
      trip: null,
      isLoading: true,
      page: 0,
      hasMore: true,
      showDet: false,
    }
  }

  componentDidMount() {
    if (this.props.trips && this.props.trips.length > 0) return;
    this.loadTrips()
    window.addEventListener('scroll', this.handleScroll, true);
  }

  componentWillUnmount() {
    window.removeEventListener('scroll', this.handleScroll, true);
  }

  applyUpdateResult = (result) => (prevState) => ({
    trips: [...prevState.trips, ...result.trips],
    page: prevState.page + 1,
    isLoading: false,
    hasMore: !!result.trips.length,
  });

  handleScroll = () => {
    if (this.state.isLoading || !this.state.hasMore) return;
    let app = this.section
    if ((window.innerHeight + app.scrollTop >= (app.scrollHeight - 300)) && this.state.trips.length) {
      this.loadTrips()
    }
  };

  loadTrips = () => {
    this.setState({ isLoading: true }, () => {
      axios.get(`trips?page=${this.state.page}&per=${PER_PAGE}`).then((res) => {
        this.setState(this.applyUpdateResult(res.data))
      }).catch((error) => {
        this.setState({isLoading: false});
        if (error.response) alert(error.response.data.errors)
      })
    })
  }

  handleBack = () => {
    this.setState({showDet: false})
  }

  changeShowDet = () => {
    this.setState({showDet: true})
  }

  render() {

    return (
      <div>
        <button
          type='button'
          class='button burger'
          onClick={() => this.handleBack()}
          style={this.state.showDet ? "z-index:1000000" : "display: none"}>
          <Back/>
        </button>
        <header><span>{i18n.trips.header}</span></header>
        <section class='trips' ref={section => this.section = section}>
          <ul>
            {this.state.trips.map((trip) => <TripCard handleBack={this.handleBack} showDet={this.state.showDet} changeShowDet={this.changeShowDet} trip={trip} setCurrentTrip={this.props.setCurrentTrip}/>)}
          </ul>
          {this.state.isLoading && <div class="loader">{i18n.trips.loading}</div>}
        </section>
      </div>
    );
  }
}
