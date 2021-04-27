import { h } from 'preact'
import '../css/delivery_preview.css'
import UAH from '../images/ukraine-hryvna.svg'

export default function CartItem(props) {
  let { item, itemId, addToCart, removeFromCart } = props

  return (
    <div class='item-preview'>
      <div class='row'>
        <div class='col-6'>
          <b class='name'>{item.item_name}</b>
        </div>
        <div class='col-2 text-center'>
          <span class='price'>
            {item.total_price}<UAH height='16px' width='16px' />
          </span>
        </div>
        <div class='col-2'>
          <div>
            <button class='button plus-button' onClick={() => addToCart({ ...item, id: itemId })}>+</button>
            <div class='circle'>
              <span class='number'>{item.quantity}</span>
            </div>
            <button class='button minus-button' onClick={() => removeFromCart({ ...item, id: itemId })}>-</button>
          </div>
        </div>
      </div>
    </div>
  )
}
