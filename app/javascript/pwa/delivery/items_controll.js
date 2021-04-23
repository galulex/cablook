class ItemsControll {
  add(item, vendor_id, cart) {
    let qty = cart.items[item.id] ? cart.items[item.id].quantity + 1 : 1
    let item_price = item.price
    cart.items[item.id] = {
      quantity: qty,
      item_price,
      total_price: item_price * qty,
      item_name: item.name,
    }
    cart.vendor_id = vendor_id
    localStorage.setItem('cart', JSON.stringify(cart));
    return qty
    // this.props.updateCart(cart)
    // if (!this.state.in_cart) this.setState({ in_cart: true })
    // this.setState({ item_count: cart.items[item.id].quantity })
  }

  remove(item, cart) {
    let current_item = cart.items[item.id]
    current_item['quantity'] > 1 ? this.decreaseItemQuantity(current_item) : delete (cart['items'][item.id])
    localStorage.setItem('cart', JSON.stringify(cart))
    // if (Object.keys(cart.items).length !== 0) {
    // } else {
    //   localStorage.removeItem('cart')
    //   this.props.updateCart({})
    // }
  }

  decreaseItemQuantity(item) {
    item['quantity']--
    item['total_price'] = item['total_price'] - item['item_price']
  }
}

export default new ItemsControll()
