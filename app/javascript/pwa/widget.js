import { h, render, Component } from 'preact';
import { PAYMENT_SYSTEM } from '../pwa/constants.js';
import axios from 'axios';

import i18n from './i18n.js';

export default class Widget extends Component {
  constructor(props) {
    super(props)
    this.state = {
      paymentSystem: this.props.paymentSystem
    }
  }

  componentDidMount() {
    this.loadWidget()
    const component = this
    window.addEventListener("message", (event) => {
      if (event.data === 'WfpWidgetEventClose') {
        this.props.showWidget(false)
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

  create = (data) => {
    axios.post('cards', data).then((res) => {
      this.props.updateCards(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
    this.props.showWidget(false)
  }

  new = () => {
    const component = this
    const wayforpay = new Wayforpay();
    this.setState({disabled: true})

    axios.get('cards/new').then((res) => {
    if (this.state.paymentSystem === PAYMENT_SYSTEM.wayforpay) {
      wayforpay.run((res.data),
        response =>{
          setTimeout(function(){
            wayforpay.closeit()
            component.create(response)
            localStorage.setItem('email', response.email)
          }, 1000)
        },
        response =>{
          component.setState({disabled: false})
        }
      )
    } else {
    window.location.href = res.data
  }}).catch((error) => {
      component.setState({disabled: false})
      if (error.response) alert(error.response.data.errors)
    })
  }
}
