
import { h } from 'preact'
import DeliveryItem from './item.js';

export default function Category(props) {
  const { items, categoryId, cart, vendor, icon, updateCart } = props

  return (
    <div class="category__scroll" id={"navigation_" + categoryId}>
      <div class="wrap category__container">
        {items.map((item, index) => (
          <div class="delivery-item" id={"item_" + index}>
            <DeliveryItem
              currentVendorId={vendor.id}
              icon={icon}
              item={item}
              quantity={cart.items[item.id]?.quantity}
              updateCart={updateCart} />
          </div>
        ))}
      </div>
    </div>
  )
}
