import { h, Component } from "preact"

export default class Card extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow-large)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="-41 164.9 512 512">
        <path fill="#19A160" filter={style.filter} d="M215 164.9c-141.4 0-256 114.6-256 256s114.6 256 256 256 256-114.6 256-256-114.6-256-256-256zm25.5 398.2h-51V365.3h51v197.8zm-3.3-230.8c-6.2 6.2-13.6 9.3-22.3 9.3-8.4 0-15.8-3.1-22-9.3-6.2-6.2-9.3-13.5-9.3-22 0-8.4 3.1-15.8 9.3-22.2 6.2-6.3 13.5-9.5 22-9.5 8.7 0 16.2 3.2 22.3 9.5 6.2 6.3 9.3 13.7 9.3 22.2s-3.2 15.8-9.3 22z"/>
      </svg>
    )
  }
}
