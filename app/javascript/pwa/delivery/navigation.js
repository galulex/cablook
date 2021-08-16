import { h } from 'preact'
import { useEffect } from 'preact/hooks'
import CategoryIcon from './category_icons.js'

export default function DeliveryNavigation(props) {
  let { tabsContent, vendorItems } = props
  let scrollEndTimeout


  useEffect(() => {
    tabsContent.addEventListener('scroll', onScroll, { passive: true })

    return () => { tabsContent.removeEventListener('scroll', onScroll, { passive: true }) }
  })

  let onScroll = () => {
    let navContainer = document.querySelector("[data-navigation='container']")
    let scrollPercent = (tabsContent.scrollTop / tabsContent.scrollHeight) * 100
    let wrap = document.querySelector("[data-categories='wrap']")
    let gradientBg = `linear-gradient(90deg, transparent ${scrollPercent}%, #19a160 ${scrollPercent}%, #19a160 calc(${scrollPercent}% + ${wrap.firstElementChild.offsetWidth}px), transparent ${scrollPercent + 8}%)`

    wrap.style.background = gradientBg
    clearTimeout(scrollEndTimeout)
    scrollEndTimeout = setTimeout(() => {
      navContainer.scroll({left: navContainer.scrollWidth / 100 * scrollPercent , behavior: 'smooth'})
    }, 100)
  }

  let scrollTo = (e, index) => {
    tabsContent.scroll({ top: document.getElementById('navigation_' + index).offsetTop - 70, behavior: 'smooth' })
    e.stopPropagation()
  }

  return (
    <nav class='delivery' data-navigation='container'>
      <div class='categories' data-categories='wrap'>
        {Object.keys(vendorItems).map((category, index) => { return vendorCategory(vendorItems, category, index, scrollTo) })}
      </div>
    </nav>
  )
}

function vendorCategory(vendorItems, category, index, scrollTo) {
  return (
    <button data-scroll={'navigation_' + index} class='navigate-btn' onClick={(e) => scrollTo(e, index)}>
      <CategoryIcon icon={vendorItems[category].icon} />
      {category}
    </button>
  )
}
