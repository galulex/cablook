import { h, Component } from "preact"

export default class Clock extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow-large)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="0 0 200 200">
        <path class="st0" filter={style.filter} d="M100 0C44.8 0 0 44.8 0 100s44.8 100 100 100 100-44.8 100-100S155.2 0 100 0zm0 182.4c-45.5 0-82.4-37-82.4-82.4s37-82.4 82.4-82.4 82.4 37 82.4 82.4-37 82.4-82.4 82.4z"/>
        <path class="st0" filter={style.filter} d="M100 29.3C61 29.3 29.3 61 29.3 100S61 170.7 100 170.7s70.7-31.7 70.7-70.7S139 29.3 100 29.3zm5.9 73.1l-39.3 39.3-8.3-8.3 35.8-35.8V46.9h11.7v55.5z"/>
      </svg>
    )
  }
}
