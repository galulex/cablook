import { h, render, Component } from 'preact';

import DeliveryItem from './delivery_item.js';
import './css/category.css'

export default class Category extends Component {
  updateCart = (cart) => {
    this.props.updateCart(cart)
  }

  scrollTo = (index, category) => (e) => {
    console.log(index)
    document.getElementById("item_" + category + index).scrollIntoView()
    e.stopPropagation()
  }

  render() {
    const { category, vendor, categoryId } = this.props
    const result = []
    const map = new Map()
    for (const item of vendor.items[category]) {
      if (!map.has(item.name)) {
        map.set(item.name, true)
        result.push({
          name: item.name,
          price: item.price,
          description: item.description,
          id: item.id
        })
      }
    }

    return (
      <div class="wrap" id={"navigation_" + categoryId}>
        {result.map((item, index) => (
          <div class="test" id={"item_" + index}>
            <img src="https://www.mcdonalds.co.za/media/products/2-cheeseburger-meal/2-Cheese-Burger-Large-Meal.png" />
            <DeliveryItem item={item} updateCart={this.updateCart} vendor_id={vendor.id} />
          </div>
        ))}
      </div>
    )
  }
}
