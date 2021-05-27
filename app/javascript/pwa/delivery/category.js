
import { h } from 'preact'
import DeliveryItem from './item.js';

export default function Category(props) {
  let { items, categoryId, cart, addToCart, removeFromCart, vendor, inCart, icon } = props

  return (
    <div class="category__scroll" id={"navigation_" + categoryId}>
      <div class="wrap category__container">
        {items.map((item, index) => (
          <div class="delivery-item" id={"item_" + index}>
            <DeliveryItem
              inCart={inCart}
              quantity={cart.items[item.id]?.quantity}
              vendorId={vendor.id}
              currentVendor={cart.vendor_id}
              item={item}
              addToCart={addToCart}
              removeFromCart={removeFromCart}
              icon={icon} />
          </div>
        ))}
      </div>
    </div>
  )
}
