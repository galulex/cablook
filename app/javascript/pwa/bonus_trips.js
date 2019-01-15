import { h, render, Component } from 'preact';
import L from 'lodash'
import { Statuses, Status } from './constants/statuses'
import axios from 'axios';

export default class Bonus extends Component {
  constructor(props) {
    super(props)
    this.state = {
      bonus_trips: [],
      parent_bonus: [],
      referralCode: localStorage.referralCode,
      friend_code: ''
    }
  }

  componentDidMount() {
    let component = this
    axios.get('referrals').then((res) => {
      component.setState({bonus_trips: res.data.bonus_trips, parent_bonus: res.data.parent_bonus})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  render() {
    const groupByStatus = L.groupBy(this.state.bonus_trips, 'status')
    const bonusTrips = Object.keys(groupByStatus).map(el => ({ status: el, count: groupByStatus[el].length }))
    return (
      <main id='app'>
        <section>
          <header>Bonus</header>
          { this.renderFriendCodeField() }
          <h1> Ваш реферальный код </h1>
          {
            document.queryCommandSupported('copy') &&
            <div>
              <input
                ref={(textarea) => this.textArea = textarea}
                value= {this.state.referralCode}
                readOnly
              />
              <button onClick={this.copyToClipboard}>Скопировать</button>
              <ul>
                { bonusTrips.map((bonus, i) => {
                  return(
                    <li>
                      <u>{Statuses[bonus.status]}</u>
                      <span>........................</span>
                      <b>{bonus.count}</b>
                    </li>
                  )
                })}
              </ul>
            </div>
          }
        </section>
      </main>
    );
  };

  renderFriendCodeField = () =>{
    if (this.state.parent_bonus.length == 0) {
      return(
        <form onSubmit={this.applyFriendCode}>
          <input id='friend_code' onInput={this.updateCode}/>
          <button type='submit'>Применить код друга</button>
        </form>
      )
    }
  }

  copyToClipboard = (e) => {
    this.textArea.select();
    document.execCommand('copy');
    e.target.focus();
  };

  updateCode = (e) => {
    this.setState({friend_code: e.target.value})
  }

  applyFriendCode = (e) => {
    e.preventDefault()
    const params = { referral_code: this.state.friend_code }
    let component = this
    console.log(this.state)
    axios.post('referrals', params).then((res) => {
      alert('OK')
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }
}
