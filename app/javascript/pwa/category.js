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

    return (
      <details>
        <summary class='vendor-category'>{category}</summary>
        <div class='content'>
          {vendor.items[category].map((item, index) => {
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


