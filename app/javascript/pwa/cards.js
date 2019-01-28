import { h, render, Component } from 'preact';
import md5 from 'crypto-js/hmac-md5';
import axios from 'axios';

import i18n from './i18n.js';
import './css/cards.css'
import CardsIcon from './images/credit-cards-payment.svg'
import Visa from './images/visa.svg'
import MasterCard from './images/mastercard.svg'

export default class Cards extends Component {
  constructor(props) {
    super(props)
    this.state = {
      cards: []
    }
  }

  componentDidMount() {
    let component = this
    this.loadWidget()
    axios.get('cards').then((res) => {
      component.setState({cards: res.data.cards})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  loadWidget = () => {
    if (document.getElementById('widget-wfp-script') === null) {
      let script = document.createElement('script');
      script.setAttribute('id', 'widget-wfp-script');
      script.setAttribute('src', 'https://secure.wayforpay.com/server/pay-widget.js');
      document.body.appendChild(script);
    }
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
            return(
              <li>
                { this.renderCardType(card.type) }
                <span>{card.pan}</span>
                <button class='x-card' type='button' onClick={() => this.delete(card.id, i)}>×</button>
              </li>
            )
          })}
        </ul>
      )
    }
    return (
      <section>
        <header>Cards</header>
        { cardList }
        <button class='add-card' type='button' onClick={this.new}>+ {i18n.cards.add}</button>
      </section>
    )
  }

  new = () => {
    const component = this
    const wayforpay = new Wayforpay();
    wayforpay.run((this.WFP()),
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          component.create(response)
        }, 1000)
      },
      response =>{
        alert(response)
      },
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          component.create(response)
        }, 1000)
      }
    );
  }

  WFP = () => {
    let date = Date.now()
    let orderReference = md5(date.toString(), localStorage.token).toString()
    this.straightWidget = true
    this.merchantAccount = window._MERCHANT
    this.merchantDomainName = 'cablook.taxi'
    this.merchantTransactionType = 'AUTH'
    this.holdTimeout = 60
    this.authorizationType = 'SimpleSignature'
    this.orderReference = orderReference
    this.serviceUrl = `https://${window.location.hostname}/api/cards/update`
    this.orderDate = date
    this.amount = '1'
    this.currency = 'UAH'
    this.productName = 'Удержание за добавление карты'
    this.productPrice = '1'
    this.transactionType = 'VERIFY'
    this.clientPhone = localStorage.phone
    this.clientEmail = localStorage.email
    this.productCount = '1'
    this.paymentSystem = 'card'
    this.merchantSignature = md5(`${this.merchantAccount};${this.merchantDomainName};${orderReference};${date};${this.amount};${this.currency};${this.productName};1;1`, window._TOKEN).toString()
    return this
  }

  create = (data) => {
    const component = this
    let cards = this.state.cards

    axios.post('cards', data).then((res) => {
      cards.push(res.data)
      component.setState({cards: cards})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }

  delete = (id, index) => {
    if (!confirm('Are you sure?')) return;
    let component = this
    let cards = this.state.cards

    axios.delete(`cards/${id}`).then((card) => {
      cards.splice(index, 1)
      component.setState({cards: cards})
    }).catch((error) => {
      if (!error.response) return;
      alert(error.response.data.errors)
    })
  }
}
