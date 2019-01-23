import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import TripCard from './tripCard.js'

const PER_PAGE = 10;

export default class Trips extends Component {
  constructor(props) {
    super(props);
    this.state = {
      trips: [],
      trip: null,
      isLoading: true,
      page: 0,
      hasMore: true,
    }
  }

  componentDidMount() {
    axios.get(`trips?page=${this.state.page}&per=${PER_PAGE}`).then((res) => {
      this.setState(this.applySetResult(res.data))
    }).catch((error) => {
      this.setState({isLoading: false});
      if (!error.response) return;
      alert(error.response.data.errors)
    });
    window.addEventListener('scroll', this.handleScroll, true);
  }

  componentWillUnmount() {
    window.removeEventListener('scroll', this.handleScroll, true);
  }

  applyUpdateResult = (result) => (prevState) => ({
    trips: [...prevState.trips, ...result.trips],
    page: prevState.page + 1,
    isLoading: false,
    hasMore: !!result.trips.length
  });

  applySetResult = (result) => () => ({
    trips: result.trips,
    isLoading: false,
    hasMore: !!result.trips.length
  });

  handleScroll = () => {
    if (this.state.isLoading || !this.state.hasMore) return;
    if ((window.innerHeight + document.body.scrollTop >= document.body.scrollHeight) && this.state.trips.length) {
      this.loadTrips()
    }
  };

  loadTrips = () => {
    this.setState({ isLoading: true }, () => {
      axios.get(`trips?page=${this.state.page + 1}&per=${PER_PAGE}`).then((res) => {
        this.setState(this.applyUpdateResult(res.data))
      }).catch((error) => {
        this.setState({isLoading: false});
        if (!error.response) return;
        alert(error.response.data.errors)
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
        {this.state.isLoading && <div class="loader">i18n.trips.loading</div>}
      </section>
    );
  }
}
