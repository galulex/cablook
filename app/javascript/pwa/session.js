import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Phone from './images/green_phone.svg';
import Logo from './images/logo_light.svg';
import Lock from './images/lock.svg';
import City from './images/city.svg';
import Nissan from './images/nissan.svg';
import './css/session.css';
import { firebaseAuth } from './firebase.js';

const NUMBER_CODE = '+380'

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

  renderNumber = () => {
    const { disabled } = this.state

    return(
      <form onSubmit={this.signInWithPhoneNumber}>
        <div class='number_input'>
          <label for='number'><Phone class='phone'/>{NUMBER_CODE}</label>
          <input id='number' title='7 digits' pattern='[0-9]*'
                 maxlength='9' minlength='9'
                 placeholder='_ _  _ _ _  _ _ _ _' type='tel'
                 autocomplete='off' required autoFocus
                 onInput={this.updateNumber}
                 ref={(input) => this.numberInput = input}/>
        </div>
        <button class='button' disabled={disabled} type='submit'>{i18n.session.number}</button>
        <p><i>{i18n.session.policy} <a href='/privacy-policy' target='_blank'>{i18n.session.policy_link}</a></i></p>
      </form>
    )
  }

  renderCode = () => {
    const { disabled } = this.state

    return(
      <form onSubmit={this.createSession}>
        <Lock class='lock'/>
        <label for='code'>{i18n.session.code}</label>
        <input id='code' title='6 digits' pattern='\d*' placeholder='_ _ _ _ _ _'
               maxlength='6' minlength='6' required type='tel'
               value={this.state.code} autocomplete='off' autoFocus
               onInput={this.updateCode} ref={input => this.codeInput = input}/>
        <button class='button change' disabled={disabled} type='button' onClick={this.resetNumber}>{i18n.session.change}</button>
        <button class='button' type='submit' disabled={disabled}>{i18n.session.code_button}</button>
        <p><a href='javascript:void(0);' onClick={this.sendCode}>{i18n.session.resend_code}</a></p>
      </form>
    )
  }

  updateNumber = (e) => {
    this.setState({number: NUMBER_CODE + e.target.value})
  }

  updateCode = (e) => {
    this.setState({code: e.target.value})
  }

  resetNumber = () => {
    this.setState({code: '', number: '', isCodeSent: false})
  }

  resetCaptcha = () => {
    if (!window.recaptchaVerifier) return;
    window.recaptchaVerifier.clear()
    this.recaptchaWrapperRef.innerHTML = `<div id='recaptcha_container'></div>`
  }

  signInWithPhoneNumber = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity()) return

    this.setState({disabled: true})
    this.sendCode()
  }

  sendCode = () => {
    this.resetCaptcha()

    const { number } = this.state
    window.recaptchaVerifier = new firebaseAuth.RecaptchaVerifier('recaptcha_container', { size: 'invisible'});

    firebaseAuth().signInWithPhoneNumber(number, recaptchaVerifier)
      .then((confirmationResult) => {
        this.setState({isCodeSent: true, disabled: false})
        window.confirmationResult = confirmationResult;
      }).catch((error) => {
        console.log(error)
        this.setState({disabled: false})
        this.resetCaptcha()
        alert(i18n.session.phone_number_error)
      });
  }

  createSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;

    const { code } = this.state

    this.setState({disabled: true})

    confirmationResult.confirm(code).then((result) => {
      this.sendRequest(result.user.uid)
    }).catch((error) => {
      this.setState({disabled: false})
      alert(i18n.session.code_error)
    });
  }

  sendRequest = (verification_token) => {
    const { number } = this.state

    let params = { phone_number: number, firebase: true, auth_token: verification_token }
    let platform = localStorage.getItem('device')
    let token  = localStorage.getItem('fcm_token')

    if (platform) params.device = { platform: platform, token: token }

    axios.post('session', params).then((res) => {
      this.props.login(res.data)
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }

  render() {
    return (
      <section>
        <Logo class='logo'/>
        <div><b>CAB</b>LOOK</div>
        <div ref={ref => this.recaptchaWrapperRef = ref}> <div id='recaptcha_container'></div> </div>
        { this.state.isCodeSent ? this.renderCode() : this.renderNumber() }
        <City class='city'/>
      </section>
    )
  }
}
