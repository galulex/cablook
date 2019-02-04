import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';

export default class Feedback extends Component {
  constructor(props){
    super(props)
  }

  componentDidMount() {
  }

  create = () => {
    this.props.updateTrip(null)
  }

  render() {
    return(
      <div class='find_driver'>
        <section>
          <h1>Feedback form</h1>
          <button class='button' type='button' onClick={this.create}>{i18n.feedback.ok}</button>
        </section>
      </div>
    )
  }
}
