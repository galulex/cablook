import { h, render, Component } from 'preact'
import axios from 'axios'

import Close from './images/times-circle.svg'
import i18n from './i18n.js'
import AddressInput from '../pwa/trips/address-input.js'
import './css/profile.css'
import Bonus from '../pwa/bonus_trips.js'
import Tabs from './tabs.js'

export default class FavoriteAddresses extends Component {
  componentDidMount() {
    this.tabsContent.addEventListener('scroll', this.onScroll, {passive: true});
  }

  componentDidUnmount() {
    this.tabsContent.removeEventListener('scroll', this.onScroll, {passive: true});
  }

  getActiveTab = (scrollPercent, tabs) => {
    let activeTab
    if (scrollPercent >= 50) {
      activeTab = tabs[2]
    } else if (scrollPercent >= 17) {
      activeTab = tabs[1]
    } else {
      activeTab = tabs[0]
    }
    return activeTab
  }

  onScroll = (e) => {
    const tabs = document.querySelectorAll('.tab__header')
    const scrollPercent = (this.tabsContent.scrollLeft / this.tabsContent.scrollWidth) * 100
    this.activeTab.style.left= `${scrollPercent}%`
    this.setActiveClass(this.getActiveTab(scrollPercent, tabs))
  }

  onClick = (e) => {
    const target = e.target
    const scrollCoefficient = target.offsetLeft / this.tabsContainer.offsetWidth
    this.tabsContent.scrollTo({left: this.tabsContent.scrollWidth * scrollCoefficient, behavior: 'smooth'})
  }

  setActiveClass = (target) => {
    if (target.classList.contains('active')) return
    const tabs = document.querySelectorAll('.tab__header')
    for(const tab of tabs) { if(tab.classList.contains('active')) tab.classList.remove('active') }
    target.classList.add('active')
  }

  render() {
    return (
      <div>
        <header>{i18n.profile_page.header}</header>
        <section class='profile'>
          <Tabs />
        </section>
      </div>
    )
  }
}
