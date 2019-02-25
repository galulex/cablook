import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from '../pwa/i18n.js';
import '../pwa/css/session.css';

export default class Session extends Component {
  constructor(props) {
    super(props)
    this.state = {
      username: '',
      password: '',
      car: null,
      cars: [],
      isValid: false,
      disabled: false
    }
  }

  fetchCars = () => {
    axios.get('cars').then((res) => {
      this.setState({cars: res.data.cars})
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    return (
      <section>
        <div><b>CAB</b>LOOK</div>
        { this.state.isValid
            ? this.renderCar()
            : this.renderForm()
        }
      </section>
    )
  }

  renderForm = () => {
    return(
      <form onSubmit={this.create}>
        <div>
          <input id='username' placeholder='username' required type='text' autoFocus onInput={this.updateField}/>
        </div>
        <div>
          <input id='password' placeholder='Password' required type='password' onInput={this.updateField}/>
        </div>
        <button class='button' disabled={this.state.disabled} type='submit'>{i18n.session.number}</button>
      </form>
    )
  }

  renderCar = () => {
    return(
      <form onSubmit={this.update}>
        <select id='car' required onChange={this.updateField}>
          <option value=''>Select Car</option>
          { this.state.cars.map(car => { return(<option value={car.id}>{car.number}</option>) }) }
        </select>
        <button class='button' type='submit' disabled={this.state.disabled}>OK</button>
      </form>
    )
  }

  updateField = (e) => {
    let state = this.state
    state[e.target.id] = e.target.value
    this.setState(state)
  }

  create = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    this.setState({disabled: true})
    axios.post('sessions', { driver: { username: this.state.username, password: this.state.password }}).then((res) => {
      axios.defaults.headers.common['Auth-Token'] = res.data.auth_token;
      this.setState({isValid: true, disabled: false, cars: res.data.cars})
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }

  update = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    this.setState({disabled: true})
    let car_id = parseInt(this.state.car)
    axios.patch('assign_car', {driver: { car_id: car_id }}).then((res) => {
      let car = this.state.cars.filter(car => { return car.id === car_id })[0]
      let driver = res.data.driver
      driver['car'] = car
      this.props.login(driver)
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }
}
