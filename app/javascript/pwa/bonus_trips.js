import { h, render, Component } from 'preact';
import L from 'lodash'
import axios from 'axios';
import i18n from './i18n.js'
import Copy from './images/copy.svg'
import './css/bonus.css'

export default class Bonus extends Component {
  constructor(props) {
    super(props)
    this.state = {
      bonus_trips: this.props.bonus_trips(),
      parent_bonus: this.props.parent_bonus(),
      referralCode: localStorage.referral,
      disabled: false,
      copied: false
    }
  }

  componentWillReceiveProps() {
    this.setState({bonus_trips: this.props.bonus_trips(), parent_bonus: this.props.parent_bonus()})
  }

  render() {
    const groupByStatus = L.groupBy(this.state.bonus_trips, 'status')
    const bonusTrips = Object.keys(groupByStatus).map(el => ({ status: el, count: groupByStatus[el].length }))
    return (
      <section>
        <header>{i18n.bonuses.header}</header>
        <div class='referral-code'>
          <label for='referral'>{i18n.bonuses.your_code}</label>
          <input id='referral' ref={(textarea) => this.textArea = textarea} value= {this.state.referralCode} readOnly />
          <button disabled={this.state.copied} type='button' onClick={this.copy}>
            <Copy fill='#312d50'/>
          </button>
        </div>
        <br/>
        <details>
          <summary>{i18n.bonuses.how}</summary>
          <p>
            {i18n.bonuses.details}
            <br/>
            {i18n.bonuses.notice}
          </p>
        </details>
        <ul class='bonus-trips-list'>
          { bonusTrips.map((bonus, i) => {
            return(
              <li class={`bonus-${bonus.status}`}>
                <em>{i18n.bonuses.statuses[bonus.status]}</em>
                <span>{bonus.count}</span>
              </li>
            )
          })}
        </ul>
        { (this.state.parent_bonus.length == 0) && <button type='button' disabled={this.state.disabled} onClick={this.apply} class='button fixed'>{i18n.bonuses.apply_code}</button> }
      </section>
    );
  };

  copy = (e) => {
    this.textArea.setSelectionRange(0, 9999);
    this.textArea.focus()
    document.execCommand('copy');
    if (navigator.vibrate) navigator.vibrate(200)
    this.setState({copied: true})
  };

  apply = () => {
    var code = prompt(i18n.bonuses.apply_code, '');
    if (code === '' || code === null) return
    this.setState({disabled: true})
    axios.post('referrals', {referral_code: code}).then((res) => {
      this.setState({disabled: false, parent_bonus: [true]})
      alert(i18n.bonuses.success)
    }).catch((error) => {
      this.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }
}
