
import { h } from 'preact'
import DeliveryItem from './item.js';

export default function Category(props) {
  let { items, categoryId, cart, addToCart, removeFromCart, vendor, quantity, inCart } = props

  return (
    <div class="wrap" id={"navigation_" + categoryId}>
      {items.map((item, index) => (
        <div class="test" id={"item_" + index}>
          <DeliveryItem
            inCart={inCart}
            quantity={itemQuantity(item, cart)}
            vendorId={vendor.id}
            currentVendor={cart.vendor_id}
            item={item}
            addToCart={addToCart}
            removeFromCart={removeFromCart} />
        </div>
      ))}
    </div>
  )
}

function itemQuantity(item, cart) {
  if (Object.keys(cart.items).length > 0) return cart.items[item.id]?.quantity
}
