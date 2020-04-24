import { h, Component } from "preact"

export default class Lock extends Component {
  render () {
    const style = {
      filter: "url(#inset-shadow)",
      class: this.props.class
    }

    return (
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 200" class={style.class}><path fill="#777" filter={style.filter} d="M150 75h-16.7V59.6C133.3 27.8 108.5 1 76.8 0c-33-1-60.1 25.6-60.1 58.3V75H0v125h150V75zm-62.5 87c.1 1.2-.2 2.4-1 3.2-.8.9-1.9 1.4-3.1 1.4H66.7c-1.2 0-2.3-.5-3.1-1.4-.8-.9-1.2-2.1-1-3.2l2.6-23.6c-4.3-3.1-6.8-8-6.8-13.4 0-9.2 7.5-16.7 16.7-16.7s16.7 7.5 16.7 16.7c0 5.4-2.6 10.3-6.8 13.4l2.5 23.6zm20.8-87H41.7V58.3C41.7 40 56.6 25 75 25s33.3 15 33.3 33.3V75z"/></svg>
    )
  }
}
