import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import Home from './images/car.svg'
import Trip from './images/vehicle-wheel.svg'
import Bonus from './images/bonus.svg'
import Card from './images/credit-cards-payment.svg'
import Contact from './images/contacts.svg'
import LogOut from './images/sign-out.svg'

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
      class: ''
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
        <div>
          { localStorage.email }
          <br/>
          { localStorage.phone }
        </div>
        <Link activeClassName='active' href='/pwa' onClick={this.close}><Home/>Home</Link>
        <Link activeClassName='active' href='/pwa/trips' onClick={this.close}><Trip/>Trips</Link>
        <Link activeClassName='active' href='/pwa/bonus_trips' onClick={this.close}><Bonus/>Bonus</Link>
        <Link activeClassName='active' href='/pwa/cards' onClick={this.close}><Card/>Cards</Link>
        <Link activeClassName='active' href='/pwa/contacts' onClick={this.close}><Contact/>Contacts</Link>
        <Link activeClassName='active' href='' onClick={this.props.logOut}><LogOut/>Log Out</Link>
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
    e.preventDefault()
    if (e.pageX > 300) this.props.triggerDrawer(false)
  }

  touchMove = (e) => {
    e.preventDefault()
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
    if (distance == 0) return;
    this.props.triggerDrawer(distance < 0)
  }
}
