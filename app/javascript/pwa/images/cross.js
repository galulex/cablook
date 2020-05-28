

import { h, Component } from "preact"

export default class Cross extends Component {
	render () {
		const style = {
			filter: "url(#inset-shadow-large)",
			class: this.props.class
		}

		return (
			<svg xmlns="http://www.w3.org/2000/svg" class={style.class} viewBox="0 0 200 200">
				<path filter={style.filter} fill="#CC0D32" d="M100 137.5l62.5 62.5 37.5-37.5-62.5-62.5L200 37.5 162.5 0 100 62.5 37.5 0 0 37.5 62.5 100 0 162.5 37.5 200z"/>
			</svg>
		)
	}
}
