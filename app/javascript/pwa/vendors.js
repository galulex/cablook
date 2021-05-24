import { h, render, Component } from 'preact'
import axios from 'axios'
import i18n from './i18n.js'
import './css/vendors.css'
import VendorPreview from './vendor_preview.js'
import CurrentDeliveryTrip from './current_delivery_trip.js'

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
    let { delivery_trip } = this.props

    if (delivery_trip?.id) { return <CurrentDeliveryTrip delivery_trip={delivery_trip} /> }
    return (
      <div class='general__holder'>
        <header>{i18n.vendors_page.header}</header>
        <section class='vendors'>
          <ul>
            {vendors.map(vendor => (
              <VendorPreview
                key={vendor.id}
                vendor={vendor}
                updateLoaderState={this.updateLoaderState}
                setCurrentTrip={this.props.setCurrentTrip}
                showBurger={this.props.showBurger}
              />)
            )
            }
          </ul>
        </section>
      </div>
    )
  }
}
