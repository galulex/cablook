import { h, Component } from 'preact'

import Tab from './tab.js'

export default class Tabs extends Component {
  onScroll = (e) => {
    this.activeTab.style.transform = 'translateX(' + (e.target.scrollLeft / e.target.offsetWidth * 100) + '%)'
  }

  onClick = (e) => {
    let scrollCoefficient = e.target.offsetLeft / this.tabsContainer.offsetWidth
    this.tabsContent.scrollTo({left: this.tabsContent.offsetWidth * 3 * scrollCoefficient})
  }

  render() {
    return (
      <div class='tabs'>
        <div class="tabs__holder">
          <div class='tab__active' ref={el => this.activeTab = el}></div>
          <div class='tabs__container' ref={el => this.tabsContainer = el}>
            <button class="tab__header" onClick={this.onClick}>Settings</button>
            <button class="tab__header" onClick={this.onClick}>Bonuses</button>
            <button class="tab__header" onClick={this.onClick}>Statistics</button>
          </div>
        </div>
        <div class="tabs__content" ref={el => this.tabsContent = el} onScroll={this.onScroll}>
          <div class='tab__content' id='settings'>

          </div>
          <div class='tab__content' id='bonuses'>

          </div>
          <div class='tab__content' id='statistics'>

          </div>
        </div>
      </div>
    )
  }
}
