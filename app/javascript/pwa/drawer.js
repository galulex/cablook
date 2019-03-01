import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js'
import Home from './images/car.svg'
import Trip from './images/vehicle-wheel.svg'
import Profile from './images/profile.svg'
import Bonus from './images/bonus.svg'
import Card from './images/credit-cards-payment.svg'
import Contact from './images/manual.svg'
import Statistics from './images/statistics.svg'
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

  componentWillReceiveProps(props) {
    (props.active) ? this.open() : this.close();
  }

  render() {
    return (
      <aside class={this.state.class} onClick={this.click} onTouchMove={this.touchMove} onTouchStart={this.touchStart} onTouchEnd={this.touchEnd} style={`transform: translate3d(${this.state.x}px, 0, 0); transition: transform 0.${this.state.transition}s`}>
        <style>
          {`aside:before { opacity: ${(1 - (Math.abs(this.state.x)/300)).toFixed(2)}; transition: opacity 0.${this.state.transition}s, width 0s 0.${this.state.delay}s; }`}
        </style>
        <div class='nav-wrapper'onTouchMove={this.touchMove}>
          <div class='nav-header'>
            { localStorage.email }
            <br/>
            { localStorage.phone }
          </div>
          <Link activeClassName='active' href='/' onClick={this.close}><Home/>{i18n.drawer.home}</Link>
          <Link activeClassName='active' href='/trips' onClick={this.close}><Trip/>{i18n.drawer.trips}</Link>
          <Link activeClassName='active' href='/profile' onClick={this.close}><Profile/>{i18n.drawer.profile}</Link>
          <Link activeClassName='active' href='/bonus_trips' onClick={this.close}>
            <Bonus/>
            {i18n.drawer.bonuses}
            { this.props.bonuses() > 0 && <span>{this.props.bonuses()}</span>}
          </Link>
          <Link activeClassName='active' href='/cards' onClick={this.close}><Card/>{i18n.drawer.cards}</Link>
          <Link activeClassName='active' href='/contacts' onClick={this.close}><Contact/>{i18n.drawer.contacts}</Link>
          <Link activeClassName='active' href='/statistics' onClick={this.close}><Statistics/>{i18n.drawer.statistic}</Link>
          <Link activeClassName='active' href='' onClick={this.props.logOut}><LogOut/>{i18n.drawer.logout}</Link>
          <select class={this.props.language} onChange={this.props.setLanguage}>
            {this.state.locales.map(el => {
              return(<option value={el} selected={el == this.props.language}>{el}</option>)
            })}
          </select>
        </div>
      </aside>
    );
  }

  close = () => {
    this.setState({transition: 3, x: -300, left: -300, class: '', delay: 3})
  }

  open = () => {
    this.setState({transition: 3, x: 0, left: 0, class: 'active', delay: 0})
  }

  click = (e) => {
    if (e.pageX > 300) this.props.triggerDrawer(false)
  }

  touchMove = (e) => {
    let distance = this.state.start - e.touches[0].pageX
    let x = this.state.left - distance
    x = (x < -300) ? -300 : x
    x = (x > 0) ? 0 : x
    this.setState({transition: 0, x: x, class: 'active'})
  }

  touchStart = (e) => {
    this.setState({start: e.touches[0].pageX, delay: 0})
  }

  touchEnd = (e) => {
    let distance = this.state.start - e.changedTouches[0].pageX
    if (distance === 0) return;
    this.props.triggerDrawer(distance < 20)
  }
}
