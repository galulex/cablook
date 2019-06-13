import { h, render, Component } from 'preact';
import axios from 'axios';
import { Router } from 'preact-router';

import i18n from './i18n.js';
import './css/vendors.css'
import VendorPreview from './vendor_preview.js'
import Vendor from './vendor.js'
import Loader from './loader.js'

export default class Vendors extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showLoader: true,
      vendors: []
    }
  }

  componentDidMount() {
    this.getVendors()
  }

  getVendors = () => {
    axios.get('vendors').then((res) => {
      this.setState({ vendors: res.data, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    });
  }

  render() {
    const { vendors, showLoader } = this.state

    return (
      <section class='vendors'>
        {showLoader && <Loader/>}
        <header>
          {i18n.vendors_page.header}
        </header>
        <div class='vendors-content'>
          <ul>
            { vendors.map(vendor => (<VendorPreview key={vendor.id} vendor={vendor}/>)) }
          </ul>
        </div>
      </section>
    )
  }
}

