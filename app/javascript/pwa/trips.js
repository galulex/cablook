import { h, render, Component } from 'preact';
import axios from 'axios';
import './css/trips.css'

import i18n from './i18n.js'
import TripCard from './tripCard.js'

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
    let app = document.getElementById('app')
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
      });
    });
  };

  render() {
    return (
      <section class='trips'>
        <header>{i18n.trips.header}</header>
        <ul>
          {this.state.trips.map((trip) => <TripCard trip={trip} />)}
        </ul>

        {this.state.isLoading && <div class="loader">{i18n.trips.loading}</div>}
      </section>
    );
  }
}
