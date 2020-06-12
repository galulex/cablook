import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Widget from './widget.js';
import './css/cards.css'
import CardsIcon from './images/credit-cards-payment.js'
import MasterCardLight from './images/MC_light.js'
import MasterCardDark from './images/MC_dark.js'
import VisaDark from './images/VISA_dark.js'
import VisaLight from './images/VISA_light.js'
import Close from './images/close.js'

export default class Cards extends Component {
  constructor(props) {
    super(props)
    this.state = {
      cards: this.props.cards(),
      disabled: false,
      showWidget: false
    }
  }

  showWidget = (val) => {
    this.setState({showWidget: val})
  }

  componentWillReceiveProps() {
    this.setState({cards: this.props.cards()})
  }

  renderCardType = (type, pan) => {
    if (localStorage.getItem('dark')) {
      if (type === 'Visa') {
        return(<VisaDark pan={pan.split('****')} class='card dark'/>)
      } else {
        return(<MasterCardDark pan={pan.split('****')} class='card dark'/>)
      }
    } else {
      if (type === 'Visa') {
        return (<VisaLight pan={pan.split('****')} class='card light'/>)
      } else {
        return (<MasterCardLight pan={pan.split('****')} class='card light'/>)
      }
    }
  }

  render() {
    let cardList = (<div><h1 class='nocards'>{i18n.cards.no_cards}</h1><CardsIcon class='nocards'/></div>)
      if (this.state.cards.length > 0) {
        cardList = (
          <ul class='cards'>
            { this.state.cards.map((card, i) => {
              if (card.user_id === this.props.currentUserID()) return(
                <li>
                  { this.renderCardType(card.type, card.pan) }
                  <button class='x-card' type='button' onClick={() => this.delete(card.id, i)}><Close fill='#a925ad'/></button>
                </li>
              )
            })}
          </ul>
        )
      }
    return (
      <div>
        <header>Cards</header>
        <section class='cards'>
          { cardList }
          <button class='button green fixed' disabled={this.state.showWidget} type='button' onClick={() => this.showWidget(true)}>+ {i18n.cards.add}</button>
          { this.state.showWidget && <Widget createCard={this.create} showWidget={this.showWidget} /> }
        </section>
      </div>
    )
  }

  create = (data) => {
    this.props.create(data)
    this.setState({showWidget: false})
  }

  delete = (id, index) => {
    if (!confirm(i18n.are_you_sure)) return;
    let cards = this.state.cards

    axios.delete(`cards/${id}`).then((card) => {
      cards.splice(index, 1)
      this.setState({cards: cards})
      this.props.updateCards(cards)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
