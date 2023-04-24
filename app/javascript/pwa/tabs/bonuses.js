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
    const cashbackAmount = this.props.cashbackAmount

    return (
      <div class='tab-content__holder'>
        {cashbackAmount > 0 && 
          <div class='tab-content__container'>
            <div class='tab-content__header'>{i18n.bonuses.your_cashback}</div>
            <div class='tab-content__container-item'> 
              <div>{i18n.bonuses.residual}</div>
              <span class='value'>{cashbackAmount} {i18n.statistics.uah}</span>
            </div>
          </div>
        }
        {bonusTrips.length > 0 && 
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
        }
      </div>
    );
  };

  copy = (e) => {
    this.textArea.setSelectionRange(0, 9999);
    this.textArea.focus()
    document.execCommand('copy');
    if (navigator.vibrate) navigator.vibrate(200)
    this.setState({copied: true})
  }
}
