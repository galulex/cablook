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

  componentDidMount() {
    this.focusOnInput()
    document.documentElement.style.setProperty('--body-bg', '#132d50');
    window.addEventListener('click', this.handleClickRecaptcha)
  }

  componentWillUnmount() {
    document.documentElement.style.setProperty('--body-bg', '#19a160');
  }

  componentDidUpdate() {
    this.focusOnInput()
  }

  focusOnInput = () => {
    this.numberInput ? this.numberInput.focus() : this.codeInput.focus()
  }

  handleClickRecaptcha = (e) => {
    const recaptcha = document.querySelector('iframe[title*="recaptcha"]')
    if (recaptcha && recaptcha.parentElement.previousSibling == e.target) this.setDisabled(false)
  }

  renderNumber = () => {
    const { disabled } = this.state

    return(
      <form onSubmit={this.signInWithPhoneNumber}>
        <div class='number_input'>
          <label for='number'><Phone class='phone'/>{NUMBER_CODE}</label>
          <input id='number' title={9 + i18n.session.digits} pattern='[0-9]*'
                 maxlength='9' minlength='9'
                 placeholder='_ _  _ _ _  _ _ _ _' type='tel'
                 autocomplete='off' required autoFocus
                 onInput={this.updateNumber}
                 ref={(input) => this.numberInput = input}/>
        </div>
        <button class='button' disabled={disabled} type='submit' ref={submitForm => this.submitForm = submitForm}>{i18n.session.number}</button>
        <p><i>{i18n.session.policy} <a href='/privacy-policy' target='_blank'>{i18n.session.policy_link}</a></i></p>
      </form>
    )
  }

  renderCode = () => {
    const { disabled, code, number } = this.state

    return(
      <form onSubmit={this.createSession}>
        <p>{i18n.session.code_sent + number}</p>
        <label for='code'>{i18n.session.code}</label>
        <div>
          <Lock class='lock'/>
          <input id='code' title={6 + i18n.session.digits} pattern='\d*' placeholder='_ _ _ _ _ _'
                 maxlength='6' minlength='6' required type='tel'
                 value={code} autocomplete='one-time-code' autoFocus
                 onInput={this.updateCode} ref={input => this.codeInput = input}/>
        </div>
        <button class='button' type='submit' disabled={disabled} ref={submitForm => this.submitForm = submitForm}>{i18n.session.code_button}</button>
        <div class='buttons__container'>
          <button class='button resend' disabled={disabled} onClick={this.resendCode} type='button'>{i18n.session.resend_code}</button>
          <button class='button resend' disabled={disabled} type='button' onClick={this.resetNumber}>{i18n.session.change}</button>
        </div>
      </form>
    )
  }

  setDisabled = (bool) => {
    this.setState({disabled: bool})
  }

  updateNumber = (e) => {
    this.setState({number: NUMBER_CODE + e.target.value})
    this.autoSubmitForm(e)
  }

  updateCode = (e) => {
    this.setState({code: e.target.value})
    this.autoSubmitForm(e)
  }

  resetNumber = () => {
    this.setState({code: '', number: '', isCodeSent: false})
  }

  resetCaptcha = () => {
    if (!window.recaptchaVerifier) return;
    window.recaptchaVerifier.render().then((widgetId) => {
      grecaptcha.reset(widgetId);
    })
    this.recaptchaWrapperRef.innerHTML = `<div id='recaptcha_container'></div>`
  }

  signInWithPhoneNumber = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity()) return

    this.sendCode()
  }

  resendCode = () => {
    if (confirm(i18n.session.confirm_resend_code)) this.sendCode()
  }

  sendCode = () => {
    const { number } = this.state

    this.resetCaptcha()
    this.setDisabled(true)

    window.recaptchaVerifier = new firebaseAuth.RecaptchaVerifier('recaptcha_container', { size: 'invisible' })

    firebaseAuth().signInWithPhoneNumber(number, recaptchaVerifier)
      .then((confirmationResult) => {
        this.setState({isCodeSent: true, disabled: false})
        window.confirmationResult = confirmationResult
      }).catch((error) => {
        this.setDisabled(false)
        this.resetCaptcha()
        alert(i18n.session.phone_number_error)
      });
  }

  autoSubmitForm = (e) => {
    if (e.target.checkValidity()) this.submitForm.click()
  }

  createSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;

    const { code } = this.state

    this.setDisabled(true)

    confirmationResult.confirm(code).then((result) => {
      this.sendRequest(result.user.uid)
    }).catch((error) => {
      this.setDisabled(false)
      alert(i18n.session.code_error)
    });
  }

  sendRequest = (verification_token) => {
    const { number } = this.state

    let params = { phone_number: number, auth_token: verification_token }
    let platform = localStorage.getItem('device')
    let token  = localStorage.getItem('fcm_token')

    if (platform) params.device = { platform: platform, token: token }

    axios.post('session', params).then((res) => {
      this.props.login(res.data)
    }).catch((error) => {
      this.setDisabled(false)
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
