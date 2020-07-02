import { h, Component } from "preact"

export default class Chevron extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="0 0 120.2 200">
        <path filter={style.filter} fill="#19a160" d="M20.2 200L0 179.8 79.8 100 0 20.2 20.2 0l100 100z"/>
      </svg>
    )
  }
}
