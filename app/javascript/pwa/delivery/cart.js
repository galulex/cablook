import i18n from '../i18n.js'

class Cart {
  constructor() {
    this.items = JSON.parse(localStorage.getItem('cart'))?.items || {}
    this.vendorId = JSON.parse(localStorage.getItem('cart'))?.vendorId
  }

  addItem(item, vendorId, updateCart) {
    if (this.validateVendor(vendorId)) { return }

    const quantity = this.items[item.id] ? this.items[item.id].quantity + 1 : 1
    const item_price = item.price || item.item_price
    this.items[item.id] = {
      quantity,
      item_price,
      category: item.category,
      total_price: item_price * quantity,
      name: item.name || item.item_name,
    }
    this.vendorId = vendorId
    localStorage.setItem('cart', JSON.stringify(this))
    updateCart()

    return quantity
  }

  removeItem(item, updateCart) {
    const cartItem = this.items[item.id]
    cartItem.quantity--
    cartItem.total_price = cartItem.total_price - cartItem.item_price
    if (cartItem.quantity == 0) delete this.items[item.id]
    if (Object.keys(this.items).length === 0) delete this.vendorId
    localStorage.setItem('cart', JSON.stringify(this))
    updateCart()

    return cartItem.quantity
  }

  validateVendor(vendorId) {
    if (!this.vendorId) { return }

    if (vendorId !== this.vendorId) {
      if (!window.confirm(i18n.item_preview.new_restaurant)) return true
      localStorage.removeItem('cart')
      this.items = {}
    }
  }

  clearItem(itemId) {
    if (!window.confirm(i18n.cart_item.last_item)) return
    delete (this.items[itemId])
    localStorage.setItem('cart', JSON.stringify(this))
    return 0
  }

  isEmpty() { return Object.keys(this.items).length > 0 }
}

export default Cart
