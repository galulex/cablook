import { h, render, Component } from 'preact';
import md5 from 'crypto-js/hmac-md5';
import axios from 'axios';

import i18n from './i18n.js';

export default class Widget extends Component {
  constructor(props) {
    super(props)
    this.state = {
    }
  }

  componentDidMount() {
    this.loadWidget()
    window.addEventListener("message", (event) => {
      if (event.data === 'WfpWidgetEventClose') {
        location.reload()
      }
    })
  }

  loadWidget = () => {
    if (document.getElementById('widget-wfp-script') === null) {
      let script = document.createElement('script');
      script.setAttribute('id', 'widget-wfp-script');
      script.onload = this.new
      script.setAttribute('src', 'https://secure.wayforpay.com/server/pay-widget.js');
      document.body.appendChild(script);
    } else {
      this.new()
    }
  }

  render() {
    return (<div></div>)
  }

  new = () => {
    const component = this
    const wayforpay = new Wayforpay();
    this.setState({disabled: true})
    wayforpay.run((this.WFP()),
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          component.props.createCard(response)
        }, 1000)
      },
      response =>{
        component.setState({disabled: false})
      },
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          component.props.createCard(response)
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
}
