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
            <div>{ localStorage.email }</div>
            { localStorage.phone }
          </Link>
          <Link activeClassName='active' href='/'><Home/>{i18n.drawer.home}</Link>
          <Link activeClassName='active' href='/trips'><Trip/>{i18n.drawer.trips}</Link>
          <Link activeClassName='active' href='/cards'><Card/>{i18n.drawer.cards}</Link>
          <Link activeClassName='active' href='/contacts'><Contact/>{i18n.drawer.contacts}</Link>
          <Link activeClassName='active' href='/statistics'><Statistics/>{i18n.drawer.statistics}</Link>
          <Link activeClassName='active' href='/delivery'><Vendors/>{i18n.drawer.vendors}</Link>
          <Link activeClassName='active' href='' onClick={this.props.logOut}><LogOut/>{i18n.drawer.logout}</Link>
        </div>
      </aside>
    );
  }
}
