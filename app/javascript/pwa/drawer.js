import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js'
import Home from './images/leaf_icon.js'
import Trip from './images/vehicle-wheel.js'
import Profile from './images/profile.js'
import Card from './images/credit-cards-payment.js'
import Contact from './images/manual.js'
import Statistics from './images/statistics.js'
import Vendors from './images/food.js'
import LogOut from './images/sign-out.js'
import './css/drawer.css'

export default class Drawer extends Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {
    this.props.triggerDrawer(false)
  }

  render() {
    return (
      <aside>
        <div class='nav-wrapper'>
          <Link class='nav-header' href='/profile'>
            <Profile/>
            <div>
              <span>{ localStorage.email }</span>
              <b>{ localStorage.phone }</b>
            </div>
          </Link>
          <Link activeClassName='active' href='/'><Home class="home-icon"/>{i18n.drawer.home}</Link>
          <Link activeClassName='active' href='/trips' class='nav-link'><Trip/>{i18n.drawer.trips}</Link>
          <Link activeClassName='active' href='/cards' class='nav-link'><Card/>{i18n.drawer.cards}</Link>
          <Link activeClassName='active' href='/contacts' class='nav-link'><Contact/>{i18n.drawer.contacts}</Link>
          <Link activeClassName='active' href='/statistics' class='nav-link'><Statistics/>{i18n.drawer.statistics}</Link>
          <Link activeClassName='active' href='/delivery' class='nav-link'><Vendors/>{i18n.drawer.vendors}</Link>
          <Link activeClassName='active' href='' class='nav-link' onClick={this.props.logOut}><LogOut/>{i18n.drawer.logout}</Link>
        </div>
      </aside>
    );
  }
}
