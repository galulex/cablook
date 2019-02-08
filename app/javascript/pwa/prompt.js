import { h, render, Component } from 'preact';
import { Link } from 'preact-router/match';

import i18n from './i18n.js'
import Upload from './images/upload.svg'
import AddThis from './images/addthis.svg'
import './css/prompt.css'

export default class Prompt extends Component {
  constructor(props) {
    super(props)
    this.state = {
      prompt: (['iPhone', 'iPad', 'iPod'].includes(navigator.platform) && ('standalone' in window.navigator && !window.navigator.standalone) && !localStorage.getItem('prompt'))
      // prompt: true
    }
  }

  render() {
    if (this.state.prompt) return(
      <div class='prompt' onClick={this.close}>
        { i18n.prompt.install }
        <Upload />
        { i18n.prompt.and }
        <AddThis class='addthis' />
        { i18n.prompt.add }
      </div>
    )
  }

  close = () => {
    this.setState({prompt: false})
    localStorage.setItem('prompt', true)
  }
}
