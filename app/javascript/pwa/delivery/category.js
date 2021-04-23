
import { h } from 'preact'
// import DeliveryItem from './delivery_item.js';
import DeliveryItem from './delivery_item.js';
// import '../../css/category.css'


export default function Category(props) {
  let { items, categoryId, cart, addToCart, removeFromCart, vendor, quantity, inCart } = props

  return (
    <div class="wrap" id={"navigation_" + categoryId}>
      {items.map((item, index) => (
        <div class="test" id={"item_" + index}>
          <DeliveryItem inCart={inCart} quantity={cart.items[item.id]?.quantity} vendorId={vendor.id} item={item} addToCart={addToCart} removeFromCart={removeFromCart} />
        </div>
      ))}
    </div>
  )
}

  // updateCart = (cart) => {
  //   this.props.updateCart(cart)
  // }

  // addToCart = () => {
  //   // let { item, vendor_id } = this.props
  //   let cart = localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : { items: {} }
  //   console.log(cart, 'PARSED CART')
  //   console.log(this.state, 'STATE')
  //   console.log(this.props, 'PROPS')
  //   // this.validateVendor(vendor_id, cart)
  //   cart.items[item.id] = cart.items[item.id] || { quantity: 0 }
  //   let qty = cart.items[item.id].quantity + parseInt(this.state.quantity)
  //   let item_price = item.price
  //   cart.items[item.id] = {
  //     quantity: qty,
  //     item_price,
  //     total_price: item_price * qty,
  //     item_name: item.name,
  //   }
  //   cart.vendor_id = vendor_id
  //   localStorage.setItem('cart', JSON.stringify(cart));
  //   this.props.updateCart(cart)
  //   if (!this.state.in_cart) this.setState({ in_cart: true })
  //   this.setState({ item_count: cart.items[item.id].quantity })
  // }

  // removeFromCart = () => {
  //   console.log('removed')
  // }

  // validateVendor = (vendor_id, cart) => {
  //   if (cart.vendor_id && cart.vendor_id !== vendor_id) {
  //     if (window.confirm(i18n.item_preview.new_restaurant)) {
  //       localStorage.removeItem('cart')
  //       this.props.updateCart({})
  //       cart = { items: {} }
  //     } else {
  //       return;
  //     }
  //   }
  // }

  // function removeFromCart() {
  //   let { item } = this.props
  //   let cart = JSON.parse(localStorage.getItem('cart'))
  //   let current_item = cart.items[item.id]

  //   if (current_item['quantity'] > 1) {
  //     current_item['quantity']--
  //     current_item['total_price'] = current_item['total_price'] - current_item['item_price']
  //   } else {
  //     delete (cart['items'][item.id])
  //     this.setState({ in_cart: false })
  //   }

  //   if (Object.keys(cart.items).length !== 0) {
  //     localStorage.setItem('cart', JSON.stringify(cart))
  //     this.props.updateCart(cart)
  //     if (this.state.in_cart) this.setState({ item_count: current_item.quantity })
  //   } else {
  //     localStorage.removeItem('cart')
  //     this.props.updateCart({})
  //   }
  // }

