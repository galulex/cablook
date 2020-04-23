import { h, Component } from "preact"

export default class Logo extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="-84 -78.7 512 512" class={style.class}>
        <path fill="#19A160" filter={style.filter} d="M428 369.4S373.2 429 329.8 433c-58.2 5.4-163.9-56.2-260.6-152.9C-27.5 183.5-89 77.7-83.7 19.6c4-43.5 63.6-98.2 63.6-98.2L104.5 46 54.8 95.7l198.9 198.9 49.7-49.7L428 369.4z"/>
      </svg>
    )
  }
}


