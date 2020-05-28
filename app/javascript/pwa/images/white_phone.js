import { h, Component } from "preact"

export default class Phone extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow-large)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
        <path filter={style.filter} d="M200 175s-21.4 23.3-38.4 24.9c-22.7 2.1-64-22-101.8-59.7C22.1 102.4-2 61.1.1 38.4 1.7 21.4 25 0 25 0l48.7 48.7-19.5 19.4 77.7 77.7 19.4-19.4L200 175z"/>
      </svg>
    )
  }
}




