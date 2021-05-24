import { h } from 'preact'
import i18n from '../i18n';
import '../css/delivery_preview.css'
import CategoryIcon from './category_icons.js'

export default function DeliveryItem(props) {
  let { item, quantity, vendorId, currentVendor, icon } = props

  return (
    <div class='delivery-preview'>
      {previewImage(item, icon)}
      <div class='row item-container'>
        <div class='info'>
          <div class='name'>{item.name}</div>
          <span class='description'>{item.description}</span>
        </div>
        <div class='text-center'>
          <b class='price'>{`${item.price} ${i18n.item_preview.uah}`}</b>
        </div>
        <div class='add-btn'>
          {quantity && vendorId == currentVendor ? controlButtons(props) : addButton(props)}
        </div>
      </div>
    </div>
  )
}

function addButton(params) {
  let { item, addToCart, vendorId } = params

  return <button class='button green add-to-cart-button' onClick={() => addToCart(item, vendorId)}>+</button>
}

function controlButtons(params) {
  let { item, removeFromCart, addToCart, quantity, vendorId } = params

  return (
    <div>
      <button class='button plus-button' onClick={() => addToCart(item, vendorId)}>+</button>
      <div class='circle'>
        <span class='number'>{quantity}</span>
      </div>
      <button class='button minus-button' onClick={() => removeFromCart(item)}>-</button>
    </div>
  )
}

function previewImage(item, icon) {
  return item.image ? <img class='category-img' src={item.image} /> : <div class='category-icon'><CategoryIcon icon={icon} /></div>
}
