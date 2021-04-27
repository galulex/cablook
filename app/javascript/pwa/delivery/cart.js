class Cart {
  format(cart, item, vendorId) {
    if (cart.vendor_id != vendorId) cart.items = {}
    let qty = cart.items[item.id] ? cart.items[item.id].quantity + 1 : 1
    let item_price = item.price || item.item_price
    cart.items[item.id] = {
      quantity: qty,
      item_price,
      total_price: item_price * qty,
      item_name: item.name || item.item_name,
    }
    cart.vendor_id = vendorId
    return cart
  }

  decreaseItemQuantity(item) {
    item['quantity']--
    item['total_price'] = item['total_price'] - item['item_price']
    return item
  }
}

export default new Cart()
