import { h, render, Component } from 'preact';
import axios from 'axios';
import { Link } from 'preact-router/match';

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
    this.getVendorInfoAndItems()
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

  render() {
    const { vendor, cart, showLoader } = this.state

    return (
      <section class='vendor-page'>
        {showLoader && <Loader/>}
        <button
            type='button'
            class='burger'
            onClick={(event) => window.history.back()}>
          <Back fill='#132d50'/>
        </button>
        <header>
          <Link href={'/delivery/cart'}>
            { cart && cart.items &&
              <span class='orange-dot'/>
            }
            <ShoppingCart class='cart'/>
          </Link>
        </header>
        <ul>
          <VendorPreview
              key={vendor.id}
              vendor={vendor}
              hide_content={true}
              active={'active'} />
        </ul>
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

