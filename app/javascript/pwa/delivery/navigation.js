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

    navigationContainer.childNodes.forEach(e => e.classList.remove('active'))
    currentNavTab.classList.add('active')
    document.querySelector("[data-navigation='active']").style.left = `${activePosition}px`
  }

  let scrollTo = (e) => {
    tabsContent.scroll({ top: document.getElementById(e.target.dataset.scroll).offsetTop - 70, behavior: 'smooth' })
    e.stopPropagation()
  }

  return (
    <nav-delivery class='delivery'>
      <div class='tabs__container navigation' data-navigation='container'>
        <div class='tab__active' data-navigation='active'></div>
        {Object.keys(vendorItems).map((category, index) => { return vendorCategory(vendorItems, category, index, scrollTo) })}
      </div>
    </nav-delivery>
  )
}

function vendorCategory(vendorItems, category, index, scrollTo) {
  return (
    <div className={'category__item' + (index == 0 ? ' active' : '')}>
      <button data-scroll={'navigation_' + index} class='dev-btn' onClick={scrollTo}>
        <CategoryIcon icon={vendorItems[category].icon} />
        {category}
      </button>
      <span class='split-line vertical' style='height: 50%;' />
    </div>
  )
}
