import { h, render, Component } from 'preact'
import { Link } from 'preact-router/match';
import axios from 'axios'
import i18n from './i18n.js'
import './css/vendors.css'
import VendorPreview from './vendor_preview.js'
import CurrentDeliveryTrip from './current_delivery_trip.js'
import Cart from './delivery/cart.js';
import ShoppingCart from './images/Shopping_cart.svg'

export default class Vendors extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showLoader: true,
      vendors: []
    }
  }

  componentDidMount() {
    let { fetchUser } = this.props;

    fetchUser()
    this.getVendors()
  }

  getVendors = () => {
    axios.get('vendors').then((res) => {
      this.setState({ vendors: res.data, showLoader: false })
    }).catch((error) => { if (error.response) alert(error.response.data.errors) });
  }

  render() {
    let { vendors } = this.state
    let { deliveryTrip, setCurrentTrip, showBurger } = this.props
    const cart = new Cart()

    if (deliveryTrip?.id) { return <CurrentDeliveryTrip delivery_trip={deliveryTrip} /> }
    return (
      <div class='general__holder'>
        <header>
          {i18n.vendors_page.header}
          <Link href={'/delivery/shopping_cart'}>
            {cart.isEmpty() && <span class='orange-dot' />}
            <ShoppingCart class='cart' fill='#132d50' />
          </Link>
        </header>
        <section class='vendors'>
          <ul>
            {vendors.map(vendor => (
              <VendorPreview
                key={vendor.id}
                vendor={vendor}
                updateLoaderState={this.updateLoaderState}
                setCurrentTrip={setCurrentTrip}
                showBurger={showBurger}
              />)
            )
            }
          </ul>
        </section>
      </div>
    )
  }
}
