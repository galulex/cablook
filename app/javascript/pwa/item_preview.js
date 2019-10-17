import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import './css/item_preview.css'

export default class ItemPreview extends Component {
  constructor(props) {
    super(props);
    this.state = {
      quantity: 1,
      in_cart: false,
      item_count: 0
    }
  }

  componentDidMount() {
    this.findItemInCard()
  }

  findItemInCard = () => {
    const { item, category } = this.props
    const cart = JSON.parse(localStorage.getItem('cart'))
    if (!cart) return;
    this.setState({ in_cart: !!cart.items[item.id] })
    if (this.state.in_cart) this.setState({ item_count: cart.items[item.id].quantity })
  }

  addToCart = () => {
    const { item, vendor, category } = this.props

    let cart = localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : { items: {} }

    if (cart.vendor && cart.vendor !== vendor.name) {
      if (window.confirm(i18n.item_preview.new_restaurant)) {
        localStorage.removeItem('cart')
        this.props.updateCart({})
        cart = { items: {} }
      } else {
        return;
      }
    }

    cart.items[item.id] = cart.items[item.id] || { quantity: 0 }
    const qty = cart.items[item.id].quantity + parseInt(this.state.quantity)
    const item_price = item.price

    cart.items[item.id] = {
      quantity: qty,
      item_price: item_price,
      total_price: item_price * qty,
      item_name: item.name,
      item_category: category
    }
    cart.vendor = vendor.name
    cart.vendor_name_slug = vendor.name_slug
    cart.vendor_location = vendor.location
    cart.vendor_address = vendor.address
    cart.vendor_open_at = vendor.open_time
    cart.vendor_close_at = vendor.close_time
    cart.vendor_phone_number = vendor.phone_number

    localStorage.setItem('cart', JSON.stringify(cart));
    this.props.updateCart(cart)
    if (!this.state.in_cart) {
      this.setState({ in_cart: true })
    }
    this.setState({ item_count: cart.items[item.id].quantity })
  }

  removeFromCart = () => {
    const { item, category } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))
    let current_item = cart.items[item.id]

    if (current_item['quantity'] > 1) {
      current_item['quantity']--
      current_item['total_price'] = current_item['total_price'] - current_item['item_price']

      cart['items'][item.id] = current_item
    } else {
      delete(cart['items'][item.id])
      this.setState({ in_cart: false })
    }

    if (Object.keys(cart.items).length !== 0) {
      localStorage.setItem('cart', JSON.stringify(cart))
      this.props.updateCart(cart)
      if (this.state.in_cart) this.setState({ item_count: cart.items[item.id].quantity })
    } else {
      localStorage.removeItem('cart')
      this.props.updateCart({})
    }
  }

  render() {
    const { item } = this.props
    const { in_cart, item_count } = this.state

    return (
      <div class='item-preview'>
        <div class='row'>
          <div class='col-6'>
            <b class='name'>{item.name}</b>
            <br/>
            <span class='description'>{item.description}</span>
          </div>
          <div class='col-2 text-center'>
            <span class='price'>{item.price} {i18n.item_preview.uah}</span>
          </div>
          <div class='col-2'>
            { !in_cart &&
                <button class='button add-to-cart-button' onClick={this.addToCart}>{i18n.item_preview.add_to_cart}</button>
            }
            { in_cart &&
              <div>
                <button class='button plus-button' onClick={this.addToCart}>{ '+' }</button>
                <div class='circle'>
                  <span class='number'>
                    { item_count }
                  </span>
                </div>
                <button class='button minus-button' onClick={this.removeFromCart}>{ '-' }</button>
              </div>
            }
          </div>
        </div>
      </div>
    )
  }
}
