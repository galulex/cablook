import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import ItemPreview from './item_preview.js';
import './css/category.css'
import Back from './images/arrow-left.svg'

export default class Category extends Component {
  updateCart = (cart) => {
    this.props.updateCart(cart)
  }

  scrollTo = (index) => (e) => {
    console.log(index)
    document.getElementById("item_" + index).scrollIntoView()
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
            <img src="https://www.mcdonalds.co.za/media/products/2-cheeseburger-meal/2-Cheese-Burger-Large-Meal.png" width="200" height="600" />
            <ItemPreview
              category={category}
              item={item}
              key={index}
              updateCart={this.updateCart}
              vendor={vendor}
              hide_content={false}
              active={''} />
            {index != 0 && <button type='button' class='button burger white-opacity' onClick={this.scrollTo(index - 1)}><Back /></button>}
            {index != (result.length - 1) && <button type='button' class='button burger white-opacity right-btn' onClick={this.scrollTo(index + 1)}><Back /></button>}
          </div>
        ))
        }
        <hr />
      </div >
    )
  }
}
