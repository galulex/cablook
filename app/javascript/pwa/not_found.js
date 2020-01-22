import { h, render, Component } from 'preact'

import i18n from './i18n.js'
import './css/not_found.css'
import NotFoundText from './images/404/404.svg'
import Blot from './images/404/Blot.svg'

export default class NotFound extends Component {
  render() {
    return (
      <div class='not-found-page'>
        <header></header>
        <NotFoundText class='not-found-text'/>
        <Blot class='blot'/>
      </div>
    )
  }
}

