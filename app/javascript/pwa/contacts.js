import { h, render, Component } from 'preact';

import i18n from './i18n.js'
import Telegram from './images/telegram.svg'
import Viber from './images/viber.svg'
import Phone from './images/phone.svg'
import Email from './images/email.svg'
import './css/contacts.css'

const MAILTO = 'mailto:contact@cablook.taxi'
const NUMBER = '+380932225665'
const TEL = 'tel:' + NUMBER
const TELEGRAM = 'tg://resolve?domain=cablookk'
const VIBER = 'viber://chat/?number=%2B380932225665'

export default class Contacts extends Component {
  openUrl = (url) => {
    window.location.href = url
  }

  render(){
    return (
      <section>
        <header>{i18n.contacts.header}</header>
        <ul class='contacts'>
          <li>
            <button onClick={this.openUrl.bind(this, MAILTO)}>
              <Email/>
              contact@cablook.taxi
            </button>
          </li>
          <li>
            <button onClick={this.openUrl.bind(this, TEL)}>
              <Phone/>
              {NUMBER}
            </button>
          </li>
          <li>
            <button onClick={this.openUrl.bind(this, TELEGRAM)}>
              <Telegram/>
              Telegram
            </button>
          </li>
          <li>
            <button onClick={this.openUrl.bind(this, VIBER)}>
              <Viber/>
              Viber
            </button>
          </li>
        </ul>
        <h1 class='notice'>{i18n.contacts.message}</h1>
      </section>
    )
  }
}
