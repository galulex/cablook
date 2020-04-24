import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Widget from './widget.js';
import './css/cards.css'
import CardsIcon from './images/credit-cards-payment.js'
import Visa from './images/visa.svg'
import MasterCard from './images/mastercard.svg'
import Close from './images/times-circle.svg'

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

  renderCardType = (type) => {
    if (type === 'Visa') {
      return(<Visa/>)
    } else {
      return(<MasterCard/>)
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
                { this.renderCardType(card.type) }
                <span>{card.pan}</span>
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
        <section>
          { cardList }
          <button class='button fixed' disabled={this.state.showWidget} type='button' onClick={() => this.showWidget(true)}>+ {i18n.cards.add}</button>
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
