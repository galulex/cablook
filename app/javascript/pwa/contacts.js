import { h, render, Component } from 'preact';

import i18n from './i18n.js'
import Telegram from './images/telegram.js'
import Viber from './images/viber.svg'
import Phone from './images/phone.svg'
import Email from './images/email.svg'
import './css/contacts.css'

const MAILTO = 'mailto:contact@cablook.taxi'
const NUMBER = '+380932225665'
const TEL = 'tel:' + NUMBER
const TELEGRAM_IOS = 'https://telegram.me/@cablookk'
const TELEGRAM = 'tg://resolve?domain=cablookk'
const VIBER = 'viber://chat/?number=%2B380932225665'

export default class Contacts extends Component {
  render(){
    return (
      <div>
        <header>{i18n.contacts.header}</header>
        <section>
          <ul class='contacts tab-content__container'>
            <li>
              <a href={MAILTO}>
                <Email/>
                contact@cablook.taxi
              </a>
            </li>
            <li>
              <a href={TEL}>
                <Phone/>
                {NUMBER}
              </a>
            </li>
            <li>
              <a href={window.ios ? TELEGRAM_IOS : TELEGRAM}>
                <Telegram/>
                @cablookk
              </a>
            </li>
            <li>
              <a href={VIBER}>
                <Viber/>
                {NUMBER}
              </a>
            </li>
          </ul>
          <div class='tab-content__container inset-shadow'>
            <h3 class='notice'>{i18n.contacts.message}</h3>
          </div>
        </section>
      </div>
    )
  }
}
