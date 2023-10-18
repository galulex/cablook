import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Phone from './images/green_phone.js';
import Logo from './images/logo_light.js';
import Lock from './images/lock.js';
import SearchLogo from './images/search_logo.svg'

import './css/session.css';
import { firebaseApp, RecaptchaVerifier, signInWithPhoneNumber, getToken, getMessaging, actionCodeSettings, sendSignInLinkToEmail, isSignInWithEmailLink, signInWithEmailLink, firebaseAuth } from './firebase.js';

const NUMBER_CODE = '+380'

export default class Session extends Component {
  constructor(props) {
    super(props)
    this.state = {
      email: '',
      number: '',
      code: '',
      isCodeSent: false,
      disabled: false,
      isEmailLogin: false,
      emailSent: false,
      emailLinkLoginning: false,
      inProggress: false
    }
  }

  componentDidMount() {
    this.authenticateUserByEmailLink()
    this.focusOnInput()
    window.addEventListener('click', this.handleClickRecaptcha, { passive: true })
  }

  componentWillUnmount() {
    window.removeEventListener('click', this.handleClickRecaptcha, { passive: true })
  }

  componentDidUpdate() {
    this.focusOnInput()
  }

  focusOnInput = () => {
    if (this.emailInput) return this.emailInput.focus()

    this.numberInput ? this.numberInput.focus() : this.codeInput?.focus()
  }

  handleClickRecaptcha = (e) => {
    const recaptcha = document.querySelector('iframe[title*="recaptcha"]')
    if (recaptcha && recaptcha.parentElement.previousSibling == e.target) this.setDisabled(false)
  }

  renderButtons = () => {
    const { disabled } = this.state

    return (
      <div>
        <button class='button green' disabled={disabled} type='submit' ref={submitForm => this.submitForm = submitForm}>{i18n.session.number}</button>
        <button class='button switch' onClick={() => this.setState({ isEmailLogin: !this.state.isEmailLogin })}>{this.state.isEmailLogin ? i18n.session.login_by_phone : i18n.session.login_by_email}</button>
        <p><i>{i18n.session.policy} <a href='/privacy-policy' target='_blank'>{i18n.session.policy_link}</a></i></p>
      </div>
    )
  }

  renderNumber = () => {
    return (
      <form onSubmit={this.signInWithPhoneNumber}>
        <div class='number_input'>
          <label for='number'><Phone class='phone' />{NUMBER_CODE}</label>
          <input class='number__input' id='number' title={9 + i18n.session.digits} pattern='[0-9]*'
            maxlength='9' minlength='9'
            placeholder='__  ___  __ __' type='tel'
            autocomplete='off' required autoFocus
            onInput={this.updateNumber}
            ref={(input) => this.numberInput = input} />
        </div>
        {this.renderButtons()}
      </form>
    )
  }

  renderEmailAuth = () => {
    return (
      <form onSubmit={this.signInWithEmail}>
        <div class='email_input'>
          {this.state.emailSent ? i18n.session.email_sent :
            <div>
              <input class='email__input' id='email'
                placeholder={i18n.session.enter_email} type='email' autocomplete='email' required autoFocus
                pattern="[^@]+@[^@]+\.[a-zA-Z]{2,6}"
                onInput={this.updateEmail}
                ref={(input) => this.emailInput = input} />
              {this.renderButtons()}
            </div>
          }
        </div>
      </form>
    )
  }

  renderCode = () => {
    const { disabled, code, number } = this.state

    return (
      <form onSubmit={this.createSession}>
        <p class='code-send'><i>{i18n.session.code_sent + number}</i></p>
        <label for='code'>{i18n.session.code}</label>
        <div>
          <Lock class='lock' />
          <input id='code' title={6 + i18n.session.digits} pattern='[0-9]+' placeholder='___ ___'
            maxlength='6' minlength='6' required type='text' inputmode='numeric'
            value={code} autocomplete='one-time-code' autoFocus
            onInput={this.updateCode} ref={input => this.codeInput = input} />
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
    this.setState({ disabled: bool })
  }

  updateNumber = (e) => {
    this.setState({ number: NUMBER_CODE + e.target.value }, () => this.autoSubmitForm(e))
  }

  updateEmail = (e) => {
    this.setState({ email: e.target.value })
  }

  updateCode = (e) => {
    this.setState({ code: e.target.value }, () => this.autoSubmitForm(e))
  }

  resetNumber = () => {
    this.setState({ code: '', number: '', isCodeSent: false })
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

    window.recaptchaVerifier = new RecaptchaVerifier('recaptcha_container', { size: 'invisible' }, firebaseAuth)

    signInWithPhoneNumber(firebaseAuth, number, recaptchaVerifier)
      .then((confirmationResult) => {
        this.setState({ isCodeSent: true, disabled: false })
        window.confirmationResult = confirmationResult
      }).catch((error) => {
        this.setDisabled(false)
        this.resetCaptcha()
        alert(i18n.session.phone_number_error)
      });
  }

  autoSubmitForm = (e) => {
    if ('reportValidity' in document.createElement('form') && e.target.checkValidity()) this.submitForm.click()
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
    this.handleNotificationsPermissions()
  }

  handleNotificationsPermissions = () => {
    Notification.requestPermission().then(permission => {
      if (permission !== 'granted') { console.log('Unable to get permission to notify.'); return }
      navigator.serviceWorker.ready.then(registration => {
        const messaging = getMessaging(firebaseApp)
        getToken(messaging, { serviceWorkerRegistration: registration }).then(token => {
          const platform = navigator.platform
          localStorage.setItem('fcm_token', token)
          localStorage.setItem('device', platform)
          this.props.sendTokenToServer(token, platform)
        })
      })
        .catch(error => {
          console.log('Unable to register service worker,', error)
        })
    })
  }

  sendRequest = (verification_token) => {
    const { number } = this.state

    let params = { phone_number: number, auth_token: verification_token, locale: this.props.language }
    let platform = localStorage.getItem('device')
    let token = localStorage.getItem('fcm_token')

    if (platform) params.device = { platform: platform, token: token }

    axios.post('session', params).then((res) => {
      this.props.login(res.data)
    }).catch((error) => {
      this.setDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  signInWithEmail = (e) => {
    e.preventDefault()

    if (!this.emailInput.checkValidity()) return
    this.setState({ disabled: true })

    const { email } = this.state

    sendSignInLinkToEmail(firebaseAuth, email, actionCodeSettings)
      .then(() => {
        this.setState({ disabled: false, email: '', emailSent: true })
        window.localStorage.setItem('emailForSignIn', email)
      })
      .catch((error) => {
        this.setState({ disabled: false, inProggress: false })
        console.log(error)
      })
  }

  authenticateUserByEmailLink = () => {
    if (isSignInWithEmailLink(firebaseAuth, window.location.href)) {
      this.setState({ emailLinkLoginning: true, inProggress: true })
      let email = window.localStorage.getItem('emailForSignIn')

      signInWithEmailLink(firebaseAuth, email, window.location.href)
        .then(({ user }) => {
          window.localStorage.removeItem('emailForSignIn')
          axios.post('session', { email: user.email })
            .then(({ data }) => {
              this.props.login(data)
              window.history.pushState(null, null, '/')
              this.handleNotificationsPermissions()
            })
            .catch((e) => {
              this.setState({ inProggress: false })
              console.log(e)
            })
        })
        .catch((error) => {
          this.setState({ inProggress: false })
          console.log(error)
        })
    }
  }

  backToLogin = () => {
    this.setState({ emailLinkLoginning: false })
    window.history.pushState(null, null, '/')
  }

  render() {
    return (
      <section>
        {this.state.inProggress ?
          <div className="loaderWrapper">
            <SearchLogo className="search_logo" />
          </div>
          :
          <div class='logo__container'>
            <Logo class='logo' />
            <div><b>CAB</b>LOOK</div>
          </div>
        }
        {this.state.emailLinkLoginning ?
          <div>
            {!this.state.inProggress &&
              <div class='email__sent'>
                {i18n.session.email_error}
                <button class='button' onClick={this.backToLogin}>{i18n.session.back_to_login}</button>
              </div>
            }
          </div>
          :
          <div>
            <div ref={ref => this.recaptchaWrapperRef = ref}> <div id='recaptcha_container'></div> </div>
            {(this.state.isEmailLogin) ? this.renderEmailAuth() : this.state.isCodeSent ? this.renderCode() : this.renderNumber()}
          </div>
        }
      </section>
    )
  }
}
