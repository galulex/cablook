import { h } from 'preact'
import i18n from '../i18n';
import '../css/delivery_preview.css'
import CategoryIcon from './category_icons.js'

export default function DeliveryItem(props) {
  let { item, quantity, vendorId, currentVendor, icon } = props

  return (
    <div class='delivery-preview' style='display: flex; flex-direction: column;'>
      {previewImage(item, icon)}
      <span class='split-line' />
      <div class='row' style='margin: 10px 0 10px 0;justify-content: space-between; font-size: 2vh; width: 40vh;'>
        <div style="width: 55%">
          <div class='name'>{item.name}</div>
          <span class='description'>{item.description}</span>
        </div>
        <div class='text-center' style='display: flex'>
          <span class='split-line' style='border-left: 1px solid #ccc;' />
          <b class='price' style='margin: 0 10px;'>{`${item.price} ${i18n.item_preview.uah}`}</b>
          <span class='split-line' style='border-left: 1px solid #ccc;' />
        </div>
        <div style="margin-left: auto;    width: 18%;">
          {quantity && vendorId == currentVendor ? controlButtons(props) : addButton(props)}
        </div>
      </div>
      <span class='split-line' />
    </div>
  )
}

function addButton(params) {
  let { item, addToCart, vendorId } = params

  return <button class='button green add-to-cart-button' onClick={() => addToCart(item, vendorId)} style='font-size: xxx-large; padding: unset;'>+</button>
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
  return item.image ? <img src={item.image} /> : <div class="foo"><CategoryIcon icon={icon} /></div>
}
