import { h } from 'preact'
import { useEffect } from 'preact/hooks'
import CategoryIcon from './category_icons.js'

export default function DeliveryNavigation(props) {
  let { tabsContent, vendorItems } = props

  useEffect(() => {
    tabsContent.addEventListener('scroll', onScroll, { passive: true })

    return () => { tabsContent.removeEventListener('scroll', onScroll, { passive: true }) }
  })

  let onScroll = () => {
    let navigationContainer = document.querySelector("[data-navigation='container']")
    let scrollPercent = (tabsContent.scrollTop / tabsContent.scrollHeight) * 100
    let activePosition = navigationContainer.scrollWidth / 100 * scrollPercent
    let positionCurrentContainer = tabsContent.scrollTop / tabsContent.offsetHeight
    let currentNavTab = navigationContainer.childNodes[(positionCurrentContainer + 1).toFixed()]
    let tabActive = document.querySelector("[data-navigation='active']")

    navigationContainer.scroll({ left: activePosition, behavior: 'smooth' })
    // if (!isInViewport(tabActive)) {
    // if (this.state.iosVersion && this.state.iosVersion > 12) {
    // tabActive.style.left = `${activePosition}px`
    tabActive.style.transform = `translate(${activePosition}px, 0)`
    navigationContainer.childNodes.forEach(e => e.classList.remove('active'))
    currentNavTab.classList.add('active')
  }

  let scrollTo = (e, index) => {
    tabsContent.scroll({ top: document.getElementById('navigation_' + index).offsetTop - 70 })
    e.stopPropagation()
  }

  return (
    <nav-delivery class='delivery'>
      <div class='tabs__container navigation' data-navigation='container'>
        <div class='tab__active' data-navigation='active' style='z-index: 10'></div>
        {Object.keys(vendorItems).map((category, index) => { return vendorCategory(vendorItems, category, index, scrollTo) })}
      </div>
    </nav-delivery>
  )
}

function vendorCategory(vendorItems, category, index, scrollTo) {
  return (
    <div className={'category__item' + (index == 0 ? ' active' : '')} style="z-index: 100">
      <button data-scroll={'navigation_' + index} class='dev-btn' onClick={(e) => scrollTo(e, index)}>
        <CategoryIcon icon={vendorItems[category].icon} />
        {category}
      </button>
      <span class='split-line vertical' style='height: 50%;' />
    </div>
  )
}
