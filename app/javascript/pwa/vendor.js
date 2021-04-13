import { h, render, Component } from 'preact';
import axios from 'axios';
import { Link } from 'preact-router/match';
import { route } from 'preact-router'

import i18n from './i18n.js'
import './css/vendor.css'
import './css/vendors.css'
import Category from './category.js'
import ShoppingCart from './images/shopping-cart.svg'
import Back from './images/arrow-left.svg'
import Loader from './loader.js'
import ControlButtons from './control_buttons.js'

export default class Vendor extends Component {
  constructor(props) {
    super(props);

    this.state = {
      vendor_id: this.props.matches.id,
      vendor: { items: [] },
      cart: JSON.parse(localStorage.getItem('cart')) || {},
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
    this.navigation.childNodes.forEach(e => e.classList.remove( 'active' ))
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
      this.setState({ vendor: res.data, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      if (error.response.status === 418) route('/delivery', true)
    });
  }

  updateCart = (cart) => {
    this.setState({ cart })
  }

  updateLoaderState = (showLoader) => {
    this.setState({ showLoader })
  }

  handleBack = () => {
    this.props.showBurger()
    route('/delivery', true)
    history.back()
  }

  scrollTo = (e) => {
    this.tabsContent.scroll({top: document.getElementById(e.target.dataset.scroll).offsetTop - 70, behavior: 'smooth'})
    // document.getElementById(e.target.dataset.scroll).scroll
    // .scrollIntoView({behavior: 'smooth'})
    e.stopPropagation()
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
            onClick={(event) => this.handleBack()}>
            <Back />
          </button>
          <header style="z-index: 100">
            {i18n.vendor_preview.menu}
            <Link href={'/delivery/cart'}>
              {cart && cart.items && <span class='orange-dot' />}
              <ShoppingCart class='cart' fill='#132d50' />
            </Link>
          </header>
          <main1>
            <section class={showLoader ? 'vendor-page hide' : 'vendor-page'} ref={el => this.tabsContent = el}>
              {Object.keys(vendor.items).map((category, index) => {
                if (category !== 'Гарячі Вина' && vendor.items[category].length > 0) return (
                  <Category
                    key={index}
                    categoryId={index}
                    category={category}
                    items={vendor.items[category]}
                    vendor={vendor}
                    updateCart={this.updateCart} />
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
                <button
                  className={index == 0 && 'active'}
                  data-scroll={'navigation_' + index}
                  onClick={this.scrollTo}>
                  {category}
                </button>
              )
            })}
          </div>
        </nav-delivery>
      </div>
    )
  }
}
