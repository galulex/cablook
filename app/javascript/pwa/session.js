import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Phone from './images/green_phone.svg';
import Logo from './images/logo_light.svg';
import Lock from './images/lock.svg';
import City from './images/city.svg';
import Nissan from './images/nissan.svg';
import './css/session.css';

export default class Session extends Component {
  constructor(props) {
    super(props)
    this.state = {
      number: '',
      code: '',
      isCodeSent: false,
      disabled: false
    }
  }

  componentDidUpdate() {
    if (this.state.isCodeSent) {
      this.codeInput.focus();
    }
  }

  componentDidMount() {
    document.documentElement.style.setProperty('--body-bg', '#132d50');
  }

  componentWillUnmount() {
    document.documentElement.style.setProperty('--body-bg', '#19a160');
  }

  render() {
    return (
      <section>
        <Logo class='logo'/>
        <div><b>CAB</b>LOOK</div>
        { this.state.isCodeSent
            ? this.renderCode()
            : this.renderNumber()
        }
        <City class='city'/>
      </section>
    )
  }

  renderNumber = () => {
    return(
      <form onSubmit={this.createSession}>
        <div class='number_input'>
          <label for='number'><Phone class='phone'/>+380</label>
          <input id='number' title='7 digits' pattern='[0-9]*' maxlength='9' minlength='9' placeholder='_ _  _ _ _  _ _ _ _' required type='tel' autocomplete='off' autoFocus onInput={this.updateNumber}/>
        </div>
        <button class='button' disabled={this.state.disabled} type='submit'>{i18n.session.number}</button>
        <p><i>{i18n.session.policy} <a href='/privacy-policy' target='_blank'>{i18n.session.policy_link}</a></i></p>
      </form>
    )
  }

  renderCode = () => {
    return(
      <form onSubmit={this.updateSession}>
        <Lock class='lock'/>
        <label for='code'>{i18n.session.code}</label>
        <input id='code' title='4 digits' pattern='\d*' placeholder='_ _ _ _' maxlength='4' minlength='4' required type='tel' value={this.state.code} autocomplete='off' autoFocus onInput={this.updateCode} ref={input => this.codeInput = input}/>
        <button class='button change' disabled={this.state.disabled} type='button' onClick={this.resetNumber}>{i18n.session.change}</button>
        <button class='button' type='submit' disabled={this.state.disabled}>{i18n.session.code_button}</button>
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
    let params = { phone_number: this.state.number }
    let platform = localStorage.getItem('device')
    let token  = localStorage.getItem('fcm_token')
    
    if (platform) params.device = { platform: platform, token: token }

    e.preventDefault()
    if (!e.target.checkValidity) return;
    this.setState({disabled: true})
    axios.post('session', params).then((res) => {
      this.setState({isCodeSent: true, disabled: false})
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    const params = { phone_number: this.state.number, token: this.state.code }

    this.setState({disabled: true})
    axios.patch('session', params).then((res) => {
      this.props.login(res.data)
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }
}
