import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Back from './images/arrow-left.svg'
import Driver from './images/feedback_driver.svg'
import './css/feedback.css'

export default class Feedback extends Component {
  constructor(props){
    super(props)
    this.state = {
      feedback: {
        rate: 5,
        tips: 0
      },
      submitDisabled: false
    }
  }

  componentDidMount() {
    history.pushState(null, 'Leave Feedback','/')
    window.addEventListener('popstate', this.props.handleBack, {once: true})
    window.onbeforeunload = (event) => {
      window.removeEventListener('popstate', this.props.handleBack, true)
    }
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.props.handleBack, true);
  }

  submitDisabled = (val) => {
    this.setState(state => {
      state.submitDisabled = val
      return state
    })
  }

  create = (e) => {
    let params = {...this.state.feedback}
    this.submitDisabled(true)
    params.trip_id = this.props.trip.id
    axios.post(`trips/${params.trip_id}/feedbacks`, {feedback: params, tip: params.tips}).then((res) => {
      this.props.isFeedbackVisible ? this.returnRate() : this.props.updateTrip()
    }).catch((error) => {
      this.submitDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  setRate = (e) => {
    let state = this.state.feedback
    state.rate = parseInt(e.target.value)
    this.setState(state)
  }

  setDescription = (e) => {
    let state = this.state.feedback
    state.description = e.target.value
    this.setState(state)
  }

  setTips = (e) => {
    let state = this.state.feedback
    state.tips = parseInt(e.target.value)
    this.setState(state)
  }

  returnRate = () => {
    this.props.getRate(this.state.feedback.rate)
    this.props.handleBack()
  }

  renderStar = (i) => {
    return [
      <label class='star' for={`star_${i}`}/>,
      <input id={`star_${i}`} type='radio' value={i} name='rate' onChange={event => this.setRate(event)} checked={this.state.feedback.rate == i}/>
    ]
  }

  renderTips = (i) => {
    return [
      <input id={`tip_${i}`} type='radio' value={i} name='tip' onChange={event => this.setTips(event)} checked={this.state.feedback.tips == i}/>,
      <label class='tip' for={`tip_${i}`}>{i}$</label>
    ]
  }

  render() {
    return(
      <div class='find_driver'>
        <section class='feedback'>
          <header>{i18n.feedback.header}</header>
          <button type='button' class='burger' onClick={() => window.history.back()}><Back fill='#132d50'/></button>
          <div class='star-container'>
            {[1,2,3,4,5].map(i => this.renderStar(i))}
          </div>
          <input type='text' class='comment' placeholder={i18n.current_trip.comment} onInput={this.setDescription}/>
          <Driver class='driver'/>
          <h4>{i18n.feedback.tips}</h4>
          <div class='tips-container'>
            {[0,3,5,10,20].map(i => this.renderTips(i))}
          </div>
          <button class='button fixed warning' type='button' disabled={this.state.submitDisabled} onClick={this.create}>{i18n.feedback.ok}</button>
        </section>
      </div>
    )
  }
}
