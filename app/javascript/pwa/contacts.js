import { h, render, Component } from 'preact';

export default class Contacts extends Component {
  render(){
    return (
      <main id='app'>
        <section>
          <header>Contacts</header>
          <h1>Contacts</h1>
          <ul>
            <li>
              <a href='mailto:contact@cablook.taxi'>contact@cablook.taxi</a>
            </li>
            <li>
              <a href='tel:+380932225665'>+380932225665</a>
            </li>
            <li>
              <a href='tg://resolve?domain=cablookk'>Telegram</a>
            </li>
            <li>
              <a href='viber://chat/?number=%2B380932225665'>Viber</a>
            </li>
          </ul>
          <h1>Телефон только для справок. Заказы по телефону не принимаются! Время работы службы технической поддержки с 9:00 до 18:00, пн-пт</h1>
        </section>
      </main>
    )
  }
}
