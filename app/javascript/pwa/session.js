import { h, render, Component } from 'preact';
import axios from 'axios';

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
          <Logo />
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
