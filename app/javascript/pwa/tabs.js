import { h, Component } from 'preact'
import i18n from '../pwa/i18n.js'

import Settings from './tabs/settings.js'

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
    console.log(i18n.profile_page.tabs)
    return (
      <div class='tabs'>
        <div class="tabs__holder">
          <div class='tab__active' ref={el => this.activeTab = el}></div>
          <div class='tabs__container' ref={el => this.tabsContainer = el}>
            {
              // Object(i18n.profile_page.tabs).forEach(key => {
              //   console.log(key)
              // })
            }
            <button class="tab__header active" onClick={this.onClick}>Settings</button>
            <button class="tab__header" onClick={this.onClick}>Bonuses</button>
            <button class="tab__header" onClick={this.onClick}>Statistics</button>
          </div>
        </div>
        <div class="tabs__content" ref={el => this.tabsContent = el} onScroll={this.onScroll}>
          <div class='tab__content'>
            <Settings setLanguage={this.props.setLanguage}/>
          </div>
          <div class='tab__content'>

          </div>
          <div class='tab__content'>

          </div>
        </div>
      </div>
    )
  }
}
