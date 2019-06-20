import { h, render, Component } from 'preact';
import axios from 'axios';
import { Link } from 'preact-router/match';
import { route } from 'preact-router'

import i18n from './i18n.js'
import './css/vendor.css'
import './css/vendors.css'
import Category from './category.js'
import VendorPreview from './vendor_preview.js'
import ShoppingCart from './images/shopping-cart.svg'
import Back from './images/arrow-left.svg'
import Loader from './loader.js'

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
    this.checkCurrentDeliveryTrip()
    this.getVendorInfoAndItems()
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
    });
  }

  updateCart = (cart) => {
    this.setState({ cart })
  }

  updateLoaderState = (showLoader) => {
    this.setState({showLoader})
  }

  render() {
    const { vendor, cart, showLoader } = this.state

    return (
      <section class='vendor-page'>
        {showLoader && <Loader/>}
        <button
            type='button'
            class='burger'
            onClick={(event) => window.history.back()}>
          <Back/>
        </button>
        <header>
          {i18n.vendor_preview.menu}
          <Link href={'/delivery/cart'}>
            { cart && cart.items &&
              <span class='orange-dot'/>
            }
            <ShoppingCart class='cart'/>
          </Link>
        </header>
        <VendorPreview
            key={vendor.id}
            vendor={vendor}
            hide_content={true}
            active={'active'}
            cart_with_items={cart && cart.items}
            updateLoaderState={this.updateLoaderState}/>
        {Object.keys(vendor.items).map((category, index) => {
          return(
            <Category
                key={index}
                category={category}
                items={vendor.items[category]}
                vendor={vendor}
                updateCart={this.updateCart}/>
          )
        })}
      </section>
    )
  }
}

