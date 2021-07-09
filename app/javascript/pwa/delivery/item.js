import { h } from 'preact'
import i18n from '../i18n';
import '../css/delivery_preview.css'
import CategoryIcon from './category_icons.js'
import Cart from './cart.js'

export default function DeliveryItem(props) {
  const { item, category, currentVendorId, updateCart, icon, quantity } = props
  const cart = new Cart()

  return (
    <div class='delivery-preview'>
      {previewImage(item.image, icon)}
      <div class='row item-container'>
        <div class='info'>
          <div class='name'>{item.name}</div>
          <span class='description'>{item.description}</span>
        </div>
        <div class='text-center'>
          <b class='price'>{`${item.price} ${i18n.item_preview.uah}`}</b>
        </div>
        <div class='add-btn'>
          {quantity && cart.vendorId == currentVendorId ? controlButtons({...props, cart}) : <button class='button green add-to-cart-button' onClick={() => cart.addItem({...item, category}, currentVendorId, updateCart)}>+</button>}
        </div>
      </div>
    </div>
  )
}

function controlButtons(params) {
  let { item, quantity, category, currentVendorId, cart, updateCart } = params

  return (
    <div>
      <button class='button plus-button' onClick={() => cart.addItem({...item, category}, currentVendorId, updateCart)}>+</button>
      <div class='circle'>
        <span class='number'>{quantity}</span>
      </div>
      <button class='button minus-button' onClick={() => cart.removeItem(item, updateCart)}>-</button>
    </div>
  )
}

function previewImage(image, icon) {
  return image ? <img class='category-img' src={image} /> : <div class='category-icon'><CategoryIcon icon={icon} /></div>
}
