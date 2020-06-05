import { h, Component } from "preact"

export default class Plus extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow-large)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="0 0 200 200">
        <path filter={style.filter} fill="#19a160" d="M123 123.1h76.8V77H123V.2H76.9V77H0v46.1h76.9V200H123z"/>
      </svg>
    )
  }
}
