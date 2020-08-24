import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Widget from './widget.js';
import './css/cards.css'
import CardsIcon from './images/credit-cards-payment.js'
import Card from './images/card.js'
import Close from './images/close.js'

export default class Cards extends Component {
  constructor(props) {
    super(props)
    this.state = {
      disabled: false,
      showWidget: false
    }
  }

  showWidget = (val) => {
    this.setState({showWidget: val})
  }

  render() {
    let cardList = (<div><h1 class='nocards'>{i18n.cards.no_cards}</h1><CardsIcon class='nocards'/></div>)
      if (this.props.cards.length > 0) {
        cardList = (
          <ul class='cards'>
            { this.props.cards.map((card, i) => {
              if (card.user_id === this.props.currentUserID()) return(
                <li>
                  <Card card={card} class={window.dark ? 'card dark' : 'card light'}/>
                  <button class='x-card' type='button' onClick={() => this.delete(card.id, i)}><Close fill='#a925ad'/></button>
                </li>
              )
            })}
          </ul>
        )
      }
    return (
      <div class='general__holder'>
        <header>{i18n.drawer.cards}</header>
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
    let cards = this.props.cards

    axios.delete(`cards/${id}`).then((card) => {
      cards.splice(index, 1)
      this.setState({cards: cards})
      this.props.updateCards(cards)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
