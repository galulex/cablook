import { h, render, Component } from 'preact'
import axios from 'axios'
import { Router } from 'preact-router'
import { FINISHED, CANCELED, CANCELED_BY_DRIVER, DECLINED } from './constants.js'
import i18n from './i18n.js'
import './css/vendors.css'
import VendorPreview from './vendor_preview.js'
import Vendor from './vendor.js'
import Loader from './loader.js'
import CurrentDeliveryTrip from './current_delivery_trip.js'

export default class Vendors extends Component {
  constructor(props) {
    super(props);

    this.state = {
      delivery_trip: JSON.parse(localStorage.getItem('delivery_trip')),
      showLoader: true,
      vendors: []
    }
  }

  componentDidMount() {
    this.getDeliveryTrip()
    this.getVendors()
  }

  getVendors = () => {
    axios.get('vendors').then((res) => {
      this.setState({ vendors: res.data, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    });
  }

  getDeliveryTrip = () => {
    const { delivery_trip } = this.state

    if (delivery_trip && delivery_trip.id && ![null, 10].includes(delivery_trip.status)) this.getDeliveryTripRequest()
  }

  getDeliveryTripRequest = () => {
    const { delivery_trip } = this.state

    if (!delivery_trip.id) return;
    axios.get(`trips/${delivery_trip.id}`).then((res) => {
      this.updateDeliveryTrip(res.data)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateDeliveryTrip = (delivery_trip) => {
    localStorage.setItem('delivery_trip', JSON.stringify(delivery_trip))
    this.setState({delivery_trip, showLoader: false})
  }

  updateLoaderState = (showLoader) => {
    this.setState({showLoader})
  }

  render() {
    const { vendors, showLoader, delivery_trip } = this.state

    if (!delivery_trip || !delivery_trip.id || [FINISHED,CANCELED,CANCELED_BY_DRIVER,DECLINED,null].includes(delivery_trip.status)) {
      localStorage.removeItem('delivery_trip')
      return (
        <div>
          <header>{i18n.vendors_page.header}</header>
          <section class='vendors'>
            {showLoader && <Loader/>}
            <ul>
              { vendors.map(vendor => (<VendorPreview key={vendor.id} vendor={vendor} updateLoaderState={this.updateLoaderState}/>)) }
            </ul>
          </section>
        </div>
      )
    } else {
      return (
        <CurrentDeliveryTrip delivery_trip={delivery_trip}/>
      )
    }
  }
}
