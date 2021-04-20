import { h, render, Component } from 'preact';

import i18n from './i18n.js';
import './css/item_preview.css'

export default class DeliveryItem extends Component {
  constructor(props) {
    super(props);
    this.state = {
      quantity: 1,
      in_cart: false,
      item_count: 0
    }
  }

  componentDidMount() {
    this.findItem()
  }

  findItem = () => {
    let { item } = this.props
    let cart = JSON.parse(localStorage.getItem('cart'))

    if (!cart) return;
    if (!!cart.items[item.id]) this.setState({ item_count: cart.items[item.id].quantity, in_cart: true })
  }

  addToCart = () => {
    let { item, vendor_id } = this.props
    let cart = localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : { items: {} }
    this.validateVendor(vendor_id, cart)
    cart.items[item.id] = cart.items[item.id] || { quantity: 0 }
    let qty = cart.items[item.id].quantity + parseInt(this.state.quantity)
    let item_price = item.price
    cart.items[item.id] = {
      quantity: qty,
      item_price,
      total_price: item_price * qty,
      item_name: item.name,
    }
    cart.vendor_id = vendor_id
    localStorage.setItem('cart', JSON.stringify(cart));
    this.props.updateCart(cart)
    if (!this.state.in_cart) this.setState({ in_cart: true })
    this.setState({ item_count: cart.items[item.id].quantity })
  }

  removeFromCart = () => {
    let { item } = this.props
    let cart = JSON.parse(localStorage.getItem('cart'))
    let current_item = cart.items[item.id]

    if (current_item['quantity'] > 1) {
      current_item['quantity']--
      current_item['total_price'] = current_item['total_price'] - current_item['item_price']
    } else {
      delete (cart['items'][item.id])
      this.setState({ in_cart: false })
    }

    if (Object.keys(cart.items).length !== 0) {
      localStorage.setItem('cart', JSON.stringify(cart))
      this.props.updateCart(cart)
      if (this.state.in_cart) this.setState({ item_count: current_item.quantity })
    } else {
      localStorage.removeItem('cart')
      this.props.updateCart({})
    }
  }

  validateVendor = (vendor_id, cart) => {
    if (cart.vendor_id && cart.vendor_id !== vendor_id) {
      if (window.confirm(i18n.item_preview.new_restaurant)) {
        localStorage.removeItem('cart')
        this.props.updateCart({})
        cart = { items: {} }
      } else {
        return;
      }
    }
  }

  controlButtons = () => {
    return (
      <div>
        <button class='button plus-button' onClick={this.addToCart}>+</button>
        <div class='circle'>
          <span class='number'>{this.state.item_count}</span>
        </div>
        <button class='button minus-button' onClick={this.removeFromCart}>-</button>
      </div>
    )
  }

  render() {
    let { item } = this.props

    return (
      <div class='item-preview'>
        <div class='row'>
          <div class='col-6'>
            <b class='name'>{item.name}</b>
            <br />
            <span class='description'>{item.description}</span>
          </div>
          <div class='col-2 text-center'>
            <span class='price'>{item.price} {i18n.item_preview.uah}</span>
          </div>
          <div class='col-2'>
            {this.state.in_cart ? this.controlButtons() : <button class='button green add-to-cart-button' onClick={this.addToCart}>+</button>}
          </div>
        </div>
      </div>
    )
  }
}
