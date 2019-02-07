import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Star from './images/star.svg'
import Back from './images/arrow-left.svg'
import './css/feedback.css'

export default class Feedback extends Component {
  constructor(props){
    super(props)
  }

  componentDidMount() {
    history.pushState(null, 'Leave Feedback','/pwa')
    window.addEventListener('popstate', this.handleBack, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.handleBack, true)
    }
  }

  handleBack = (event) => {
    this.props.updateTrip(null)
    event.stopPropagation()
  };

  create = () => {
    this.props.updateTrip(null)
  }

  renderStart = (i) => {
    return [
      <label class='star' for={`start_${i}`}/>,
      <input id={`start_${i}`} type='radio' value={i} name='rate' checked/>
    ]
  }

  render() {
    return(
      <div class='find_driver'>
        <section>
          <header>{i18n.confirm_trip.header}</header>
          <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
          <h1>Feedback form</h1>
          { [1,2,3,4,5].map(i => this.renderStart(i) ) }
          <button class='button fixed warning' type='button' onClick={this.create}>{i18n.feedback.ok}</button>
        </section>
      </div>
    )
  }
}
