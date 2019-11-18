import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js'
import Home from './images/leaf_icon.svg'
import Trip from './images/vehicle-wheel.svg'
import Profile from './images/profile.svg'
import Card from './images/credit-cards-payment.svg'
import Contact from './images/manual.svg'
import Statistics from './images/statistics.svg'
import Vendors from './images/food.svg'
import LogOut from './images/sign-out.svg'
import './css/drawer.css'

export default class Drawer extends Component {
  constructor(props) {
    super(props)
    let x = (props.active) ? 0 : -300;
    this.state = {
      start: 0,
      left: x,
      x: x,
      transition: 0,
      delay: 0,
      class: '',
      locales: ['en', 'uk', 'ru']
    }
  }

  render() {
    return (
      <aside>
        <style>
          {`aside:before { opacity: ${(1 - (Math.abs(this.state.x)/300)).toFixed(2)}; transition: opacity 0.${this.state.transition}s, width 0s 0.${this.state.delay}s; }`}
        </style>
        <div class='nav-wrapper'>
          <Link class='nav-header' href='/profile' onClick={this.close}>
            <Profile/>
            <div>{ localStorage.email }</div>
            { localStorage.phone }
          </Link>
          <Link activeClassName='active' href='/' onClick={this.close}><Home/>{i18n.drawer.home}</Link>
          <Link activeClassName='active' href='/trips' onClick={this.close}><Trip/>{i18n.drawer.trips}</Link>
          <Link activeClassName='active' href='/cards' onClick={this.close}><Card/>{i18n.drawer.cards}</Link>
          <Link activeClassName='active' href='/contacts' onClick={this.close}><Contact/>{i18n.drawer.contacts}</Link>
          <Link activeClassName='active' href='/statistics' onClick={this.close}><Statistics/>{i18n.drawer.statistics}</Link>
          <Link activeClassName='active' href='/delivery' onClick={this.close}><Vendors/>{i18n.drawer.vendors}</Link>
          <Link activeClassName='active' href='' onClick={this.props.logOut}><LogOut/>{i18n.drawer.logout}</Link>
        </div>
      </aside>
    );
  }

  close = (e) => {
    this.props.triggerDrawer(false)
  }
}
