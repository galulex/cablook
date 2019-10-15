import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js';
import ItemPreview from './item_preview.js';
import './css/category.css'

export default class Category extends Component {
  updateCart = (cart) => {
    this.props.updateCart(cart)
  }

  render() {
    const { category, vendor } = this.props
    const result = []
    const map = new Map()
    for (const item of vendor.items[category]) {
      if(!map.has(item.name)){
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
      <details>
        <summary class='vendor-category'>{category}</summary>
        <div class='content'>
          {result.map((item, index) => {
            return (
              <ItemPreview
                  category={category}
                  item={item}
                  key={index}
                  updateCart={this.updateCart}
                  vendor={vendor}
                  hide_content={false}
                  active={''}/>
            )
          })}
        </div>
      </details>
    )
  }
}
