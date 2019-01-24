import { h, render, Component } from 'preact';
import './css/contacts.css'

import Telegram from './images/telegram.svg'
import Viber from './images/viber.svg'
import Phone from './images/phone.svg'
import Email from './images/email.svg'

export default class Contacts extends Component {
  render(){
    return (
      <section>
        <header>Contacts</header>
        <h1>Contacts</h1>
        <ul class='contacts'>
          <li>
            <a href='mailto:contact@cablook.taxi'>
              <Email/>
              <label>contact@cablook.taxi</label>
            </a>
          </li>
          <li>
            <a href='tel:+380932225665'>
              <Phone/>
              <label>+380932225665</label>
            </a>
          </li>
          <li>
            <a href='tg://resolve?domain=cablookk'>
              <Telegram/>
              <label>Telegram</label>
            </a>
          </li>
          <li>
            <a href='viber://chat/?number=%2B380932225665'>
              <Viber/>
              <label>Viber</label>
            </a>
          </li>
        </ul>
        <h1 style={{color: 'red'}}>Телефон только для справок. Заказы по телефону не принимаются! Время работы службы технической поддержки с 9:00 до 18:00, пн-пт</h1>
      </section>
    )
  }
}
