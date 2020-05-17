import { h, Component } from 'preact'
import i18n from '../pwa/i18n.js'

import Settings from './tabs/settings.js'
import Bonuses from './tabs/bonuses.js'
import Statistics from './tabs/statistics.js'

export default class Tabs extends Component {
  onScroll = (e) => {
    const target = e.target
    const tabs = document.querySelectorAll('.tab__header')
    const scrollPercent = target.scrollLeft / target.offsetWidth * 100
    const scrollCoefficient = scrollPercent % 33
    let activeHeader = Number.isInteger(scrollCoefficient) ? tabs[scrollCoefficient] : null
    if (activeHeader) this.setActiveClass(activeHeader)
    this.activeTab.style.transform = `translateX(${scrollPercent}%)`
  }

  onClick = (e) => {
    const target = e.target
    const scrollCoefficient = target.offsetLeft / this.tabsContainer.offsetWidth
    this.tabsContent.scrollTo({left: this.tabsContent.offsetWidth * 3 * scrollCoefficient})
    this.setActiveClass(target)
  }

  setActiveClass = (target) => {
    const tabs = document.querySelectorAll('.tab__header')
    for(const tab of tabs) { if(tab.classList.contains('active')) tab.classList.remove('active') }
    target.classList.add('active')
  }

  render() {
    return (
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
        <div class="tabs__content" ref={el => this.tabsContent = el} onScroll={this.onScroll}>
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
    )
  }
}
