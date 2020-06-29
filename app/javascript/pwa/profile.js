import { h, Component } from 'preact'

import i18n from './i18n.js'

import Settings from './tabs/settings.js'
import Bonuses from './tabs/bonuses.js'
import Statistics from './tabs/statistics.js'

import './css/profile.css'

let scrollEndTimeout, scrollPercent, start

export default class FavoriteAddresses extends Component {
  componentDidMount() {
    this.tabsContent.addEventListener('scroll', this.onScroll, { passive: true })
  }

  componentWillUnmount() {
    this.tabsContent.removeEventListener('scroll', this.onScroll, { passive: true })
    this.resetTabs()
  }

  resetTabs = () => {
    this.activeTab.style.left = '0'
    this.setActiveClass(this.tabsContainer.children[0])
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
    scrollPercent = (this.tabsContent.scrollLeft / this.tabsContent.scrollWidth) * 100
    switch(true) {
      case (scrollPercent <= 0):
        scrollPercent = 0
        break
      case (scrollPercent >= 66):
        scrollPercent = 66
        break
      default:
        break
    }
    this.activeTab.style.left = `${scrollPercent}%`
    clearTimeout(scrollEndTimeout)
    this.setActiveClass(this.getActiveTab(scrollPercent, this.tabsContainer.children))
    if(window.ios) { window.requestAnimationFrame(this.animate); return }
    scrollEndTimeout = setTimeout(() => {
      this.activeTab.style.left = `${scrollPercent}%`
    }, 10)
  }

  animate = (timestamp) => {
    if (start === undefined) {
      start = timestamp
    }
    const elapsed = timestamp - start
    this.activeTab.style.left = `${Math.min(0.1 * elapsed, scrollPercent)}%`
    if (elapsed < 300) {
      window.requestAnimationFrame(this.animate)
    }
  }

  onClick = (e) => {
    const target = e.target
    const scrollCoefficient = target.offsetLeft / this.tabsContainer.offsetWidth
    this.tabsContent.scrollTo({left: this.tabsContent.scrollWidth * scrollCoefficient, behavior: 'smooth'})
  }

  setActiveClass = (target) => {
    if (target.classList.contains('active')) return
    for(const tab of this.tabsContainer.children) { if(tab.classList.contains('active')) tab.classList.remove('active') }
    target.classList.add('active')
  }

  render() {
    return (
      <div class='profile__container'>
        <header class='main'>{i18n.profile_page.header}</header>
        <section class='profile'>
          <div class='tabs'>
            <div class="tabs__holder">
              <div class='tab__active' ref={el => this.activeTab = el}></div>
              <div class='tabs__container' ref={el => this.tabsContainer = el}>
                {
                  Object.keys(i18n.profile_page.tabs).map((key, index) => {
                    return(
                      <button
                        class={`tab__header ${index === 0 ? 'active' : ''}`}
                        onClick={this.onClick}>
                          {i18n.profile_page.tabs[key]}
                      </button>
                    )
                  })
                }
              </div>
            </div>
            <div class="tabs__content" ref={el => this.tabsContent = el} >
              <div class='tab-content'>
                <Settings
                  setLanguage={this.props.setLanguage}
                  favorite_addresses={() => this.props.favorite_addresses()}
                  updateFavoriteAddresses={this.props.updateFavoriteAddresses}
                  notification_settings={this.props.notification_settings}
                  updateNotificationSettings={this.props.updateNotificationSettings}
                  geocode={this.props.geocode}
                  language={this.props.language}
                  isGeocoding={this.props.isGeocoding}
                  setGeocoding={this.props.setGeocoding}
                  setAddress={this.props.setAddress}
                  showBurger={this.props.showBurger}
                  toggleHeader={this.props.toggleHeader}
                />
              </div>
              <div class='tab-content'>
                <Bonuses
                  bonus_trips={this.props.bonus_trips}
                  parent_bonus={this.props.parent_bonus}
                />
              </div>
              <div class='tab-content'>
                <Statistics />
              </div>
            </div>
          </div>
        </section>
      </div>
    )
  }
}
