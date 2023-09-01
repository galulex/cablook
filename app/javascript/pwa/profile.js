import { h, Component } from 'preact'

import i18n from './i18n.js'

import Settings from './tabs/settings.js'
import Bonuses from './tabs/bonuses.js'
import Statistics from './tabs/statistics.js'

import './css/profile.css'

let scrollEndTimeout, scrollPercent, start

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props)
    this.state = {
      iosVersion: null,
      tabs: ['settings', 'statistics']
    }
  }

  componentDidMount() {
    this.tabsContent.addEventListener('scroll', this.onScroll, { passive: true })
    this.setState({iosVersion: this.getIOSVersion()})
  }

  componentWillUnmount() {
    this.tabsContent.removeEventListener('scroll', this.onScroll, { passive: true })
    this.resetTabs()
  }

  getIOSVersion = () => {
    if (/iP(hone|od|ad)/.test(navigator.platform)) {
      var v = (navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/);
      return parseInt(v[1], 10)
    } else {
      return null
    }
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
    if (window.ios) {
      if (this.state.iosVersion && this.state.iosVersion > 12) {
        this.activeTab.animate({left: `${scrollPercent}%`}, { duration: 300 })
      } else {
        window.requestAnimationFrame(this.animate); return
      }
    }
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

  showBonusTab = () => (this.props.cashbackAmount > 0 || this.props.bonus_trips().length > 0) 
  tabList = () => this.showBonusTab() ? [...this.state.tabs, 'bonuses'] : this.state.tabs

  render() {
    return (
      <div class='profile__container general__holder'>
        <header class='main'>{i18n.profile_page.header}</header>
        <section class='profile'>
          <div class='tabs'>
            <div class="tabs__holder">
              <div class='tab__active' style={{ width: this.showBonusTab() ? '33%' : '50%' }} ref={el => this.activeTab = el}></div>
              <div class='tabs__container' ref={el => this.tabsContainer = el} >
                {
                  this.tabList().map((key, index) => {
                    return(
                      <button
                        class={`tab__header ${index === 0 ? 'active' : ''}`}
                        style={{ width: this.showBonusTab() ? '33%' : '50%' }}
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
                  language={this.props.language}
                  isGeocoding={this.props.isGeocoding}
                  setGeocoding={this.props.setGeocoding}
                  setAddress={this.props.setAddress}
                  showBurger={this.props.showBurger}
                  removeData={this.props.removeData}
                />
              </div>
              <div class='tab-content'>
                <Statistics />
              </div>
              {this.showBonusTab() && 
                <div class='tab-content'>
                  <Bonuses
                    bonus_trips={this.props.bonus_trips}
                    parent_bonus={this.props.parent_bonus}
                    cashbackAmount={this.props.cashbackAmount}
                  />
                </div>
              }
            </div>
          </div>
        </section>
      </div>
    )
  }
}
