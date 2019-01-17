import { h, render, Component } from 'preact';

export default class TripCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showDetails: false
    }
  }

  showDetails = () => {
    if (this.state.showDetails) return;
    this.setState({showDetails: true})
  };

  closeDetails = (e) => {
    e.stopPropagation();
    this.setState({showDetails: false})
  };

  renderDetails = () => {
    const { trip } = this.props;
    const style = {
      width: "100%",
      position: "fixed",
      height: "100%",
      background: "#ccc",
      left: "0",
      top: "0",
      zIndex: "10001"
    };

    const backStyle = {
      background: "#19A160",
      height: "100%",
      position: "absolute",
      left: "0",
      top: "0",
      padding: "1rem"
    };

    const button = {
      background: "#19A160",
      padding: "1rem",
      display: "inline-block",
      width: "44%",
      color: "white",
      textAlign: "center"
    };

    return (
      <div class="trip-details" style={style}>
        <header>
          Trip Details
          <span onClick={this.closeDetails} style={backStyle}>&lArr;</span>
        </header>
        <section>
          <img src="https://www.fillmurray.com/460/300" alt="map"/>
          <div class="buttons">
            <span style={{...button, marginRight: "10%"}}>Repeat Trip</span>
            <span style={button}>Reverse Trip</span>
          </div>
          <div>{`${trip.cost} UAH`}</div>
          <div>{`Status - ${trip.human_status}`}</div>
          <address>{trip.departure_address}</address>
          <address>{trip.destination_address}</address>
          <time>{trip.formatted_date}</time>
        </section>
      </div>
    )
  };

  render() {
    const { trip } = this.props;
    return (
      <li class="trip-card" onClick={this.showDetails}>
        <address>{trip.departure_address}</address>
        <address>{trip.destination_address}</address>
        <p>{[`${trip.cost} UAH`, trip.formatted_date, trip.human_status].join(", ")}</p>
        {this.state.showDetails && this.renderDetails()}
      </li>
    );
  }
}
