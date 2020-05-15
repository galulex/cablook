import { h, Component } from 'preact'

import i18n from './i18n.js'
import './css/profile.css'
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
          <Tabs
            favorite_addresses={() => this.props.favorite_addresses()}
            notification_settings={this.props.notification_settings}
            updateFavoriteAddresses={this.props.updateFavoriteAddresses}
            updateNotificationSettings={this.props.updateNotificationSettings}
            geocode={this.props.geocode}
            language={this.props.language}
            isGeocoding={this.props.isGeocoding}
            setGeocoding={this.props.setGeocoding}
            setAddress={this.setAddress}
            setLanguage={this.props.setLanguage}
            bonus_trips={this.props.bonus_trips}
            parent_bonus={this.props.parent_bonus}
          />
        </section>
      </div>
    )
  }
}
