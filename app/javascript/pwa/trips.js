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
      upcoming: true
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
    upcoming: prevState.upcoming
  });

  handleScroll = () => {
    if (this.state.isLoading || !this.state.hasMore) return;
    if ((window.innerHeight + document.body.scrollTop >= (document.body.scrollHeight - 300)) && this.state.trips.length) {
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

  upcomingTab = (val) => {
    this.setState({upcoming: val});
  }

  render() {
    return (
      <section class='trips'>
        <header>{i18n.trips.header}</header>
        <nav>
          <label for='upcoming_trips' onClick={() => this.upcomingTab(true)} class={this.state.upcoming ? 'active': ''}>{i18n.trips.upcoming}</label>
          <label for='previous_trips' onClick={() => this.upcomingTab(false)} class={!this.state.upcoming ? 'active': ''}>{i18n.trips.past}</label>
        </nav>

        <input id='upcoming_trips' type='radio' name='trips' class='trips-radio' checked/>
        <div class='trips-content'>
          <ul>
            {this.state.trips.filter((e) => e.status < 4).map((trip) => <TripCard trip={trip} />)}
          </ul>
        </div>

        <input id='previous_trips' type='radio' name='trips' class='trips-radio' checked={!this.state.upcoming}/>
        <div class='trips-content'>
          <ul>
            {this.state.trips.filter((e) => e.status > 3).map((trip) => <TripCard trip={trip} />)}
          </ul>
        </div>

        {this.state.isLoading && <div class="loader">{i18n.trips.loading}</div>}
      </section>
    );
  }
}
