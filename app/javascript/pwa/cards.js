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
    let { cards } = this.props
    let cardList = (<div><h1 class='nocards'>{i18n.cards.no_cards}</h1><CardsIcon class='nocards'/></div>)
      if (cards.length > 0) {
        cardList = (
          <ul class='cards'>
            { cards.map(card => {
              if (card.user_id === this.props.currentUserID) return(
                <li>
                  <Card card={card} />
                  <button class='x-card' type='button' onClick={() => this.delete(card.id)}><Close fill='#a925ad'/></button>
                  { cards.length > 1 && <div class='default'>
                    <input
                      id={`default_card_${card.id}`}
                      class='checkbox-switcher'
                      name='card[default]'
                      onChange={(e) => { this.update(card.id) }}
                      checked={card.default}
                      type='radio'
                      value='1'
                    />
                    <label for={`default_card_${card.id}`} class='label-switcher'></label>&nbsp;
                    <label for={`default_card_${card.id}`} class='label-header'>{i18n.cards.main}</label>
                  </div>}
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
    let cards = this.props.cards

    axios.post('cards', data).then((res) => {
      cards.push(res.data)
      this.props.updateCards(cards)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
    this.setState({showWidget: false})
  }

  update = (id) => {
    axios.patch(`cards/${id}`).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  delete = (id) => {
    if (!confirm(i18n.are_you_sure)) return;

    axios.delete(`cards/${id}`).then((res) => {
      this.props.updateCards(res.data.cards)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
