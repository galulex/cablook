import { h, Component } from 'preact'
import axios from 'axios'
import i18n from '../i18n.js'
import Copy from '../images/copy.svg'
import '../css/bonus.css'

export default class Bonuses extends Component {
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
    const groupByStatus = this.state.bonus_trips.reduce((a, b) => { (a[b['status']] = a[b['status']] || []).push(b); return a; }, {})
    const bonusTrips = Object.keys(groupByStatus).map(el => ({ status: el, count: groupByStatus[el].length }))
    return (
      <div class='tab-content__holder'>
        <div class='tab-content__container referral-code'>
          <div class='tab-content__header'>{i18n.bonuses.your_code}</div>
          <span class='divider'></span>
          <div class='referral-code__holder'>
            <input id='referral' ref={(textarea) => this.textArea = textarea} value= {this.state.referralCode} readOnly />
            <button disabled={this.state.copied} type='button' onClick={this.copy}>
              <Copy fill='#312d50'/>
            </button>
          </div>
        </div>
        <div class='tab-content__container'>
          <div class='tab-content__header'>{i18n.bonuses.your_bonuses}</div>
          <ul class='bonus-trips-list tab-content__container-items'>
            { bonusTrips.map((bonus, i) => {
              return(
                <li class={`bonus-${bonus.status} tab-content__container-item`}>
                  <div>{i18n.bonuses.statuses[bonus.status]}</div>
                  <div class='bonus-badge'>
                    <span class='bonus-badge__text'>{bonus.count}</span>
                  </div>
                </li>
              )
            })}
          </ul>
        </div>
        <div class='tab-content__container how-works'>
          <div class='tab-content__header'>{i18n.bonuses.how}</div>
          <p>{i18n.bonuses.details}</p>
          <p>{i18n.bonuses.notice}</p>
        </div>
        { (this.state.parent_bonus.length == 0) && <button type='button' disabled={this.state.disabled} onClick={this.apply} class='button friend-code'>{i18n.bonuses.apply_code}</button> }
      </div>
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
