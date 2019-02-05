import { h, render, Component } from 'preact';
import L from 'lodash'
import { Statuses } from './constants/statuses'
import axios from 'axios';
import './css/bonus.css'

export default class Bonus extends Component {
  constructor(props) {
    super(props)
    this.state = {
      bonus_trips: [],
      parent_bonus: [],
      referralCode: localStorage.referral,
      friend_code: ''
    }
  }

  componentDidMount() {
    axios.get('referrals').then((res) => {
      this.setState({bonus_trips: res.data.bonus_trips, parent_bonus: res.data.parent_bonus})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  render() {
    const groupByStatus = L.groupBy(this.state.bonus_trips, 'status')
    const bonusTrips = Object.keys(groupByStatus).map(el => ({ status: el, count: groupByStatus[el].length }))
    return (
      <section>
        <header>Bonus</header>
        { this.renderFriendCodeField() }
        <h1> Ваш реферальный код </h1>
        {
          document.queryCommandSupported('copy') &&
          <div>
            <div class='referral-code'>
              <input
                ref={(textarea) => this.textArea = textarea}
                value= {this.state.referralCode}
                readOnly
              />
              <button onClick={this.copyToClipboard} class='purple-btn'>Скопировать</button>
            </div>
            <ul class='bonus-trips-list'>
              { bonusTrips.map((bonus, i) => {
                return(
                  <li>
                    <em>{Statuses[bonus.status]}</em>
                    <span>{bonus.count}</span>
                  </li>
                )
              })}
            </ul>
          </div>
        }
      </section>
    );
  };

  renderFriendCodeField = () =>{
    if (this.state.parent_bonus.length == 0) {
      return(
        <form onSubmit={this.applyFriendCode} class='referral-code'>
          <input id='friend_code' onInput={this.updateCode}/>
          <button type='submit' class='purple-btn'>Применить код друга</button>
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
    axios.post('referrals', params).then((res) => {
      alert('OK')
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }
}
