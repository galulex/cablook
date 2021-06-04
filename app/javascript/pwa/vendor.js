import { h, render, Component } from 'preact';
import axios from 'axios';
import { Link } from 'preact-router/match';
import { route } from 'preact-router'

import './css/vendor.css'
import './css/delivery_navigation.css'
import i18n from './i18n.js'
import Category from './delivery/category.js'
import ShoppingCart from './images/Shopping_cart.svg'
import Back from './images/arrow-left.svg'
import Loader from './loader.js'
import ControlButtons from './control_buttons.js'
import Cart from './delivery/cart.js';
import DeliveryNavigation from './delivery/navigation.js';

export default class Vendor extends Component {
  constructor(props) {
    super(props);

    this.state = {
      vendor_id: this.props.matches.id,
      vendor: { items: [] },
      showLoader: true
    }
  }

  componentDidMount() {
    this.props.showBurger(false)
    this.getVendorInfoAndItems()
  }

  componentDidUpdate() {
    if (this.props.delivery_trip?.id) route('/delivery', true)
  }

  componentWillUnmount() {
    this.props.showBurger(true)
  }

  getVendorInfoAndItems = () => {
    axios.get(`vendors/${this.state.vendor_id}`).then((res) => {
      this.setState({ vendor: res.data, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      if (error.response.status === 418) route('/delivery', true)
    });
  }

  updateCart = () => {
    this.setState({ cart: new Cart() })
  }

  handleBack = () => {
    this.props.showBurger()
    route('/delivery', true)
    history.back()
  }

  render() {
    const { vendor, showLoader } = this.state
    const cart = new Cart()

    return (
      <div class='general__holder delivery__holder'>
        <div>
          {showLoader && <Loader />}
          <button
            type='button'
            class='button burger white-opacity'
            onClick={() => this.handleBack()}>
            <Back />
          </button>
          <header style="z-index: 100">
            {i18n.vendor_preview.menu}
            <Link href={'/delivery/shopping_cart'}>
              {cart.isEmpty() && <span class='orange-dot' />}
              <ShoppingCart class='cart' fill='#132d50' />
            </Link>
          </header>
          <main class='delivery'>
            <section class={showLoader ? 'vendor-page hide' : 'vendor-page'} ref={el => this.tabsContent = el}>
              {Object.keys(vendor.items).map((category, index) => {
                if (vendor.items[category].items.length > 0) return (
                  <Category
                    cart={cart}
                    cart_items={cart.items}
                    category={category}
                    categoryId={index}
                    icon={vendor.items[category].icon}
                    items={vendor.items[category].items}
                    key={index}
                    removeFromCart={this.removeFromCart}
                    updateCart={this.updateCart}
                    vendor={vendor} />
                )
              })}
            </section>
          </main>
          <ControlButtons section={this.tabsContent} />
        </div>
        {this.tabsContent && <DeliveryNavigation tabsContent={this.tabsContent} vendorItems={vendor.items} />}
      </div>
    )
  }
}
