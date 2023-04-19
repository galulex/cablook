import { h } from 'preact'
import { Link } from 'preact-router/match'

import i18n from './i18n.js'
import Home from './images/leaf_icon.js'
import Trip from './images/vehicle-wheel.js'
import Profile from './images/profile.js'
import Card from './images/credit-cards-payment.js'
import Contact from './images/manual.js'
import Vendors from './images/food.js'
import LogOut from './images/sign-out.js'
import FamilyIcon from './images/family_icon.js'
import './css/drawer.css'

export default function Drawer(props) {
  const {  settings: { delivery: is_delivery_enabled } } = props

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
        <Link activeClassName='active' href='/' class='nav-link'><Home class="home-icon"/>{i18n.drawer.home}</Link>
        <Link activeClassName='active' href='/trips' class='nav-link'><Trip/>{i18n.drawer.trips}</Link>
        <Link activeClassName='active' href='/cards' class='nav-link'><Card/>{i18n.drawer.cards}</Link>
        <Link activeClassName='active' href='/contacts' class='nav-link'><Contact/>{i18n.drawer.contacts}</Link>
        {is_delivery_enabled && <Link activeClassName='active' href='/delivery' class='nav-link'><Vendors/>{i18n.drawer.vendors}</Link> }
        <Link activeClassName='active' href='/family' class='nav-link'><FamilyIcon/>{i18n.family_trip.header}</Link>
        <Link href='' class='nav-link' onClick={props.logOut}><LogOut/>{i18n.drawer.logout}</Link>
      </div>
    </aside>
  )
}
