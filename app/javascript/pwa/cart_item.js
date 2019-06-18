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
        total_price: this.props.item.total_price
      }
    }
  }

  componentDidMount() {
    this.findItemInCart()
  }

  findItemInCart = () => {
    const { item_name } = this.props

    if (localStorage.getItem('cart') === null) return;

    const cart = JSON.parse(localStorage.getItem('cart'))

    this.setState({ in_cart: !!cart['items'][item_name] })
  }

  addToCart = () => {
    const { item, item_name, vendor } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))

    cart['items'][item_name] = cart['items'][item_name]
    const qty = cart['items'][item_name]['quantity'] + parseInt(this.state.quantity)
    const item_price = item.item_price

    cart['items'][item_name] = {
      quantity: qty,
      item_price: item_price,
      total_price: item_price * qty
    }

    this.setState({item: { quantity: qty, total_price: item_price * qty }})
    localStorage.setItem('cart', JSON.stringify(cart));
    this.props.calculateTotalPrice()
  }

  removeFromCart = () => {
    const { item, item_name } = this.props

    let cart = JSON.parse(localStorage.getItem('cart'))
    let current_item = JSON.parse(localStorage.getItem('cart')).items[item_name]

    if (current_item['quantity'] > 1) {
      current_item['quantity']--
      current_item['total_price'] = current_item['total_price'] - current_item['item_price']

      cart['items'][item_name] = current_item
    } else {
      if (window.confirm(i18n.cart_item.last_item)) {
        delete(cart['items'][item_name])
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

  render() {
    const { item_name } = this.props
    const { in_cart } = this.state
    const item = JSON.parse(localStorage.getItem('cart')).items[item_name]

    return (
      <div class='item-preview'>
        <div class='row'>
          <div class='col-4'>
            <b class='name'>{item_name + ' (' + item.item_price + 'грн.)'}</b>
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
        </div>
      </div>
    )
  }
}
