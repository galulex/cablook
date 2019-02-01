import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Phone from './images/green_phone.svg';
import Logo from './images/logo_light.svg';
import Lock from './images/lock.svg';
import City from './images/city.svg';
import Road from './images/road.svg';
import Nissan from './images/nissan.svg';
import './css/session.css';

export default class Session extends Component {
  constructor(props) {
    super(props)
    this.state = {
      number: '',
      code: '',
      isCodeSent: false
    }
  }

  componentDidUpdate() {
    if (this.state.isCodeSent == true) {
      this.codeInput.focus();
    }
  }

  render() {
    return (
      <main id='app' class='login'>
        <section>
          <Logo class='logo'/>
          <div><b>CAB</b>LOOK</div>
          { this.state.isCodeSent
            ? this.renderCode()
            : this.renderNumber()
          }
        </section>
      <div class='city_road'>
        <City class='city'/>
        <Nissan class='nissan'/>
        <Road class='road'/>
      </div>
      </main>
    )
}

  renderNumber = () => {
    return(
      <form onSubmit={this.createSession}>
        <div class='number_input'>
          <label for='number'><Phone class='phone'/>+380</label>
          <input id='number' title='7 digits' pattern='[0-9]*' maxlength='9' minlength='9' placeholder='_ _  _ _ _  _ _ _ _' required type='tel' autocomplete='off' autoFocus onInput={this.updateNumber}/>
        </div>
        <button type='submit'>{i18n.session.number}</button>
        <p><i>{i18n.session.policy} <a href='#'>{i18n.session.policy_link}</a></i></p>
      </form>
    )
  }

  renderCode = () => {
    return(
      <form onSubmit={this.updateSession}>
        <Lock class='lock'/>
        <label for='code'>{i18n.session.code}</label>
        <input id='code' title='4 digits' pattern='\d*' placeholder='_ _ _ _' maxlength='4' minlength='4' required type='tel' value={this.state.code} autocomplete='off' autoFocus onInput={this.updateCode} ref={input => this.codeInput = input}/>
        <button class='change' type='button' onClick={this.resetNumber}>{i18n.session.change}</button>
        <button type='submit'>{i18n.session.code_button}</button>
      </form>
    )
  }

  updateNumber = (e) => {
    this.setState({number: '+380' + e.target.value})
  }

  updateCode = (e) => {
    this.setState({code: e.target.value})
  }

  resetNumber = () => {
    this.setState({code: '', number: '', isCodeSent: false})
  }

  createSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    const params = { phone_number: this.state.number }
    let component = this

    axios.post('session', params).then((res) => {
      component.setState({isCodeSent: true})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  updateSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    const params = { phone_number: this.state.number, token: this.state.code }
    let component = this

    axios.patch('session', params).then((res) => {
      component.props.login(res.data)
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }
}
