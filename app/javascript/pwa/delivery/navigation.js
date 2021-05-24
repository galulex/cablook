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
    let scrollPercent = (tabsContent.scrollTop / tabsContent.scrollHeight) * 100
    let gradientBg = `linear-gradient(90deg, transparent ${scrollPercent}%, #19a160 ${scrollPercent}%, #19a160 calc(${scrollPercent}% + 300px), transparent ${scrollPercent + 8}%)`

    document.querySelector("[data-categories='wrap']").style.background = gradientBg
  }

  let scrollTo = (e, index) => {
    tabsContent.scroll({ top: document.getElementById('navigation_' + index).offsetTop - 70, behavior: 'smooth' })
    e.stopPropagation()
  }

  return (
    <nav class='delivery'>
      <div class='tabs__container navigation' data-navigation='container'>
        <div class='categories' data-categories='wrap'>
          {Object.keys(vendorItems).map((category, index) => { return vendorCategory(vendorItems, category, index, scrollTo) })}
        </div>
      </div>
    </nav>
  )
}

function vendorCategory(vendorItems, category, index, scrollTo) {
  return (
    <div className={'category__item' + (index == 0 ? '' : '')}>
      <button data-scroll={'navigation_' + index} class='navigate-btn' onClick={(e) => scrollTo(e, index)}>
        <CategoryIcon icon={vendorItems[category].icon} />
        {category}
      </button>
    </div>
  )
}
