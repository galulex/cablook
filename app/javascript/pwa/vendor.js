import { h, render, Component } from 'preact';
import axios from 'axios';
import { Link } from 'preact-router/match';
import { route } from 'preact-router'

import i18n from './i18n.js'
import './css/vendor.css'
import './css/vendors.css'
import './css/category.css'
import './css/delivery_navigation.css'
import Category from './delivery/category.js'
import ShoppingCart from './images/shopping-cart.svg'
import Back from './images/arrow-left.svg'
import Loader from './loader.js'
import ControlButtons from './control_buttons.js'
import Cart from './delivery/cart.js';
import DeliveryNavigation from './delivery/navigation.js'
import CategoryIcon from './delivery/category_icons.js'

export default class Vendor extends Component {
  constructor(props) {
    super(props);

    this.state = {
      vendor_id: this.props.matches.id,
      vendor: { items: [] },
      cart: JSON.parse(localStorage.getItem('cart')) || { items: {} },
      showLoader: true
    }
  }

  componentDidMount() {
    this.props.showBurger(false)
    this.checkCurrentDeliveryTrip()
    this.getVendorInfoAndItems()
    this.tabsContent.addEventListener('scroll', this.onScroll, { passive: true })
  }

  componentWillUnmount() {
    this.tabsContent.removeEventListener('scroll', this.onScroll, { passive: true })
    this.props.showBurger(true)
  }

  onScroll = () => {
    let scrollPercent = (this.tabsContent.scrollTop / this.tabsContent.scrollHeight) * 100
    let activePosition = this.navigation.scrollWidth / 100 * scrollPercent
    let positionCurrentContainer = this.tabsContent.scrollTop / this.tabsContent.offsetHeight
    let currentNavTab = this.navigation.childNodes[(positionCurrentContainer + 1).toFixed()]
    this.navigation.childNodes.forEach(e => e.classList.remove('active'))
    currentNavTab.classList.add('active')

    this.activeTab.style.left = `${activePosition}px`
  }

  checkCurrentDeliveryTrip = () => {
    const delivery_trip = JSON.parse(localStorage.getItem('delivery_trip'))

    if (delivery_trip && delivery_trip.id) route('/delivery', true)
  }

  getVendorInfoAndItems = () => {
    const { vendor_id } = this.state

    axios.get(`vendors/${vendor_id}`).then((res) => {
      // console.log(res.data)
      this.setState({ vendor: res.data, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      if (error.response.status === 418) route('/delivery', true)
    });
  }

  handleBack = () => {
    this.props.showBurger()
    route('/delivery', true)
    history.back()
  }

  scrollTo = (e) => {
    this.tabsContent.scroll({ top: document.getElementById(e.target.dataset.scroll).offsetTop - 70, behavior: 'smooth' })
    e.stopPropagation()
  }

  addToCart = (item, vendorId) => {
    if (this.validateVendor(vendorId)) return
    this.setState({ cart: Cart.format(this.state.cart, item, vendorId) })
    localStorage.setItem('cart', JSON.stringify(this.state.cart))
  }

  removeFromCart = (item) => {
    let current_item = this.state.cart.items[item.id]
    current_item['quantity'] > 1 ? Cart.decreaseItemQuantity(current_item) : delete (this.state.cart['items'][item.id])
    this.setState(this.state)
    localStorage.setItem('cart', JSON.stringify(this.state.cart))
  }

  validateVendor = (vendorId) => {
    let currentVendor = this.state.cart.vendor_id

    if (currentVendor && currentVendor != vendorId) {
      if (!window.confirm(i18n.item_preview.new_restaurant)) return true
      this.setState({ cart: { items: {} } })
      localStorage.removeItem('cart')
    }
  }

  render() {
    const { vendor, cart, showLoader } = this.state

    return (
      <div class='general__holder' style="flex-direction: column">
        <div>
          {showLoader && <Loader />}
          <button
            type='button'
            class='button burger white-opacity'
            onClick={(e) => this.handleBack()}>
            <Back />
          </button>
          <header style="z-index: 100">
            {i18n.vendor_preview.menu}
            <Link href={'/delivery/shopping_cart'}>
              {Object.keys(cart.items).length > 0 && <span class='orange-dot' />}
              <ShoppingCart class='cart' fill='#132d50' />
            </Link>
          </header>
          <main1>
            <section class={showLoader ? 'vendor-page hide' : 'vendor-page'} style='padding: 0' ref={el => this.tabsContent = el}>
              {Object.keys(vendor.items).map((category, index) => {
                if (category !== 'Гарячі Вина' && vendor.items[category].items.length > 0) return (
                  <Category
                    key={index}
                    categoryId={index}
                    category={category}
                    items={vendor.items[category].items}
                    vendor={vendor}
                    cart={cart}
                    cart_items={cart.items}
                    addToCart={this.addToCart}
                    removeFromCart={this.removeFromCart}
                    icon={vendor.items[category].icon} />
                )
              })}
            </section>
          </main1>
          <ControlButtons section={this.tabsContent} />
        </div>
        <nav-delivery class='delivery'>
          <div class='tabs__container asd' style='width: 90vw;' ref={el => this.navigation = el}>
            <div class='tab__active' ref={el => this.activeTab = el}></div>
            {Object.keys(vendor.items).map((category, index) => {
              return (
                <div className={'bar ' + (index == 0 ? 'active' : '')}>
                  <button data-scroll={'navigation_' + index} onClick={this.scrollTo} class='dev-btn'>
                    <CategoryIcon icon={vendor.items[category].icon} />
                    {category}
                  </button>
                  <span class='split-line' style='border-left: 1px solid #ccc; height: 50%;' />
                </div>
              )
            })}
          </div>
        </nav-delivery>
      </div>
    )
  }
}
