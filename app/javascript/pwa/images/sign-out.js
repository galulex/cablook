import { h, Component } from "preact"

export default class Food extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow)",
      class: this.props.class
    }

    return (
    <svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="0 0 28.074 28.074">
      <g fill="#312D50">
        <path filter={style.filter} d="M15.401 25.522H2.813V2.567h12.588v8.406h2.425V0H.489v28.074h17.337v-6.235h-2.425v3.683z"/>
        <path filter={style.filter} d="M27.404 15.938c-.6-.596-6.307-6.123-6.307-6.123s-.76-.765-.76.247v2.632H8.427s-.362-.013-.362.457v6.46c0 .66.432.544.432.544H20.518v2.849c0 .832.724.066.724.066l6.111-6.283s.487-.413.051-.849z"/>
      </g>
    </svg>
    )
  }
}
