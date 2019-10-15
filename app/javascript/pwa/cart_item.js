import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import './css/item_preview.css'

export default class CartItem extends Component {
  constructor(props) {
    super(props);
    this.state = {
      quantity: 1,
      in_cart: false,
      item: {
        name: this.props.item_name,
        quantity: this.props.item.quantity,
        item_price: this.props.item.item_price,
        total_price: this.props.item.total_price,
        id: this.props.item.id
      }
    }
  }

  componentDidMount() {
    this.findItemInCart()
  }

  findItemInCart = () => {
    const { item_name, id } = this.props

    if (localStorage.getItem('cart') === null) return;

    const cart = JSON.parse(localStorage.getItem('cart'))

    this.setState({ in_cart: !!cart['items'][id] })
  }

  addToCart = () => {
    const { item, item_name, vendor, id } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))

    cart['items'][id] = cart['items'][id]
    const qty = cart['items'][id]['quantity'] + parseInt(this.state.quantity)
    const item_price = item.item_price

    cart['items'][id] = {
      quantity: qty,
      item_price: item_price,
      total_price: item_price * qty
    }

    this.setState({item: { quantity: qty, total_price: item_price * qty }})
    localStorage.setItem('cart', JSON.stringify(cart));
    this.props.calculateTotalPrice()
  }

  removeFromCart = () => {
    const { item, item_name, id } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))
    let current_item = JSON.parse(localStorage.getItem('cart')).items[id]

    if (current_item['quantity'] > 1) {
      current_item['quantity']--
      current_item['total_price'] = current_item['total_price'] - current_item['item_price']

      cart['items'][id] = current_item
    } else {
      if (window.confirm(i18n.cart_item.last_item)) {
        delete(cart['items'][id])
      } else {
        return;
      }
    }

    this.setState({item: { quantity: current_item['quantity'],
                           total_price: current_item['total_price'] }})
    localStorage.setItem('cart', JSON.stringify(cart))
    this.props.calculateTotalPrice()
    if (Object.keys(cart.items).length !== 0) {
      this.setState({item: { quantity: current_item['quantity'],
                             total_price: current_item['total_price'] }})
      localStorage.setItem('cart', JSON.stringify(cart))
      this.props.calculateTotalPrice()
    } else {
      localStorage.removeItem('cart')
    }
  }

  removeAllCurrentItem = () => {
    const { item, item_name, id } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))
    let current_item = JSON.parse(localStorage.getItem('cart')).items[id]

    if (window.confirm(i18n.cart_item.remove_current_item)) {
      delete(cart['items'][id])
    } else {
      return;
    }

    this.setState({item: { quantity: current_item['quantity'],
                           total_price: current_item['total_price'] }})
    localStorage.setItem('cart', JSON.stringify(cart))
    this.props.calculateTotalPrice()
    if (Object.keys(cart.items).length === 0) localStorage.removeItem('cart')
  }

  render() {
    const { item_name, id } = this.props
    const { in_cart } = this.state
    const item = JSON.parse(localStorage.getItem('cart')).items[id]

    return (
      <div class='item-preview'>
        <div class='row'>
          <div class='col-4'>
            <b class='name'>{item.item_name + ' (' + item.item_price + 'грн.)'}</b>
          </div>
          <div class='col-2 text-center'>
            <b class='name'>{item.quantity} шт.</b>
          </div>
          <div class='col-2 text-center'>
            <span class='price'>{item.total_price} грн.</span>
          </div>
          <div class='col-2'>
            <div>
              <button class='button plus-button' onClick={this.addToCart}>{ '+' }</button>
              <button class='button minus-button' onClick={this.removeFromCart}>{ '-' }</button>
            </div>
          </div>
          <button class='remove-item' onClick={this.removeAllCurrentItem}>×</button>
        </div>
      </div>
    )
  }
}
