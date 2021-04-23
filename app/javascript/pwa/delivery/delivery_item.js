import { h } from 'preact'
import i18n from '../i18n';
import '../css/delivery_preview.css'

export default function DeliveryItem(props) {
  let { item, quantity, addToCart, vendorId, inCart } = props

  return (
    <div class='delivery-preview' style='display: flex; flex-direction: column;'>
      <img src="https://www.mcdonalds.co.za/media/products/2-cheeseburger-meal/2-Cheese-Burger-Large-Meal.png" />
      <div class='row'>
        <div class='col-6'>
          <b class='name'>{item.name}</b>
          <span class='description'>{item.description}</span>
        </div>
        <div class='col-2 text-center' style='display: flex'>
          <hr />
          <span class='price'>{item.price} {i18n.item_preview.uah}</span>
          <hr />
        </div>
        <div class='col-2'>
          {quantity > 0 ? controlButtons(props) : <button class='button green add-to-cart-button' onClick={() => addToCart(item, vendorId)}>+</button>}
        </div>
      </div>
    </div>
  )
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
