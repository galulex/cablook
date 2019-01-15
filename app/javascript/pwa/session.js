import { h, render, Component } from 'preact';
import Logo from './images/logo.svg';

export default class Session extends Component {
  constructor(props) {
    super(props)
    this.state = {
      number: '',
      code: '',
      isCodeSent: false
    }
  }

  render() {
    return (
      <main id='app' class='login'>
        <section>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 174 128">
            <path d="M153.3 73.2l-.2-.1-24.8-12.8-1.6 2.1c-.4.3-2.9 2.3-9.5 3.6-5.1 1-13.6-.6-27.7-26.4C86 33.3 82 27.3 77.4 21.8c.4 3.2.4 6.7.1 10.1-.6 5.9-3.1 14.4-6.4 23.3a46 46 0 0 1 5.9 7.3c4.1 5.9 7.8 12.9 10.3 17.4l.7 1.3c2.5 4.6 6.6 7.6 12 8.6 2.3.4 4.7.5 7.1.2l47.4-3.9.8-.6c1.7-1.3 1.9-3.8 1.9-5.5 0-4-3.5-6.5-3.9-6.8z" fill="#ffffff"/>
            <path d="M69.9 18.3C68.6 14.8 64.3 5 51.9 5s-16.7 9.8-18 13.3-2.1 9.6-1.6 15.4c1.4 15.8 19.6 54.4 19.6 54.4s18.2-38.6 19.6-54.4c.5-5.8-.3-11.9-1.6-15.4z" fill="#00b05d"/>
            <path d="M39.5 85.4h1.9l6 12.8-32-5.9 2-6.8.2-.1h21.9m40.2 0l.3.4 1 1.1 6 5.8.1.2-.1.2-12.2 10.1-19.5-3.6 6.6-14.1h1.7l16.1-.1m.4-3l-16.5.2H60c-4.6 10.2-8.3 17.6-8.3 17.6s-3.7-7.5-8.3-17.7H17.6c-1.4 0-2.7.9-3.1 2.3l-2.9 10 63.9 11.7 13.3-11c1.5-1.3 1.6-3.6.2-4.9l-6-5.8c-1-1.2-1.5-2.4-2.9-2.4zm17.5 15.7c.6 0 1.1.2 1.4.7l17.8 21.4H70.7l25.7-21.6c.3-.3.8-.5 1.2-.5m0-3c-1.1 0-2.2.4-3.1 1.1l-32 26.9h60.8l-21.9-26.3a5.2 5.2 0 0 0-3.8-1.7zm-85 7.4l4.6.8v16.8H7.8l-.1-.1v-.2l4.9-17.3M10.4 99l-5.7 20.1c-.3 1-.1 2 .5 2.8s1.5 1.3 2.5 1.3h12.4v-22.3L10.4 99zm17.2 6.2l36.8 6.7-9.8 8.2h-27v-14.9m-3-3.6v21.5h31.1l15.5-13-46.6-8.5zM137.5 96l-19.4 6.9-4.6-5.2 24-1.7m17.2-4.2l-47.4 3.3 9.8 11.3 37.7-13.5c.8-.2.6-1.1-.1-1.1zm1 8.2l9.4 20.1h-34.3l-6.2-7.8 31.1-12.3m1.5-3.8L119.6 111l9.7 12.1h38.8c.5.1 1.1-.3 1.1-.9l-.1-.6-11.9-25.4z" fill="#ffffff"/>
          </svg>
          <h1><b>CAB</b>LOOK</h1>
          { this.state.isCodeSent
            ? this.renderCode()
            : this.renderNumber()
          }
        </section>
      </main>
    )
}

  renderNumber = () => {
    return(
      <form onSubmit={this.createSession}>
        <label for='number'>+380</label>
        <input id='number' title='7 digits' pattern='[0-9]*' maxlength='9' minlength='9' placeholder='932225665' required type='tel' autoFocus onInput={this.updateNumber}/>
        <button type='submit'>OK</button>
      </form>
    )
  }

  renderCode = () => {
    return(
      <form onSubmit={this.updateSession}>
        <label for='code'>Enter SMS code</label>
        <input id='code' title='4 digits' pattern='\d*' placeholder='1234' maxlength='4' minlength='4' required type='tel' value={this.state.code} autoFocus onInput={this.updateCode}/>
        <button type='button' onClick={this.resetNumber}>Change phone number</button>
        <button type='submit'>OK</button>
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
    console.log(this.state)
  }

  createSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    const params = { phone_number: this.state.number }
    let component = this
    console.log(this.state)
    fetch('/api/session', {
      method: 'post',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify(params)
    }).then((response) => {
       if (response.status !== 201) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
      }
      response.json().then(function(data) {
        component.setState({isCodeSent: true})
      });
    });
  }

  updateSession = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    const params = { phone_number: this.state.number, token: this.state.code }
    let component = this
    console.log(this.state)
    fetch('/api/session', {
      method: 'PATCH',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify(params)
    }).then((response) => {
       if (response.status !== 200) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
       }
      response.json().then(function(data) {
        localStorage.setItem('referralCode', data.referral_code)
        localStorage.setItem('email', data.email)
        localStorage.setItem('phone_number', data.phone_number)
        component.props.login(data.auth_token)
      });
    });
  }

}
