import { h, render, Component } from 'preact';

import i18n from './i18n.js'
import Telegram from './images/telegram.svg'
import Viber from './images/viber.svg'
import Phone from './images/phone.svg'
import Email from './images/email.svg'
import './css/contacts.css'

export default class Contacts extends Component {
  render(){
    return (
      <section>
        <header>{i18n.contacts.header}</header>
        <ul class='contacts'>
          <li>
            <a href='mailto:contact@cablook.taxi'>
              <Email/>
              contact@cablook.taxi
            </a>
          </li>
          <li>
            <a href='tel:+380932225665'>
              <Phone/>
              +380932225665
            </a>
          </li>
          <li>
            <a href='tg://resolve?domain=cablookk'>
              <Telegram/>
              Telegram
            </a>
          </li>
          <li>
            <a href='viber://chat/?number=%2B380932225665'>
              <Viber/>
              Viber
            </a>
          </li>
        </ul>
        <h1 class='notice'>{i18n.contacts.message}</h1>
      </section>
    )
  }
}
