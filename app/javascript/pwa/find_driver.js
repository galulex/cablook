import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import SearchLogo from './images/search_logo.svg'
import './css/find_driver.css'

export default class FindDriver extends Component {
  constructor(props){
    super(props)
  }

  render() {
    return(
      <div class='find_driver'>
        <section>
          <div class='address-block'>
            <address>вул. Рози Люксембург, 202</address>
            <address>Active Bridge, Маршала Красовського, 8</address>
          </div>
          <SearchLogo class='search_logo'/>
          <form class='form'>
            <button class='cancel' type='button'>{i18n.find_driver.cancel}</button>
          </form>
        </section>
      </div>
    )
  }
}