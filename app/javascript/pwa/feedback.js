import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js';
import Back from './images/arrow-left.svg'
import Driver from './images/feedback_driver.svg'
import Currency from './images/ukraine-hryvna.svg'
import Star from './images/star.svg'
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
    if (window.ios) return;
    history.length > 2 ? null : history.pushState(null, null, '/') 
    window.addEventListener('popstate', this.props.handleBack, {once: true, passive: true})
  }

  componentWillUnmount() {
    this.feedbackForm.reset()
    window.removeEventListener('popstate', this.props.handleBack, {once: true, passive: true});
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
    params.trip_id = this.props.trip.id == undefined ? this.props.lastTripId : this.props.trip.id
    axios.post(`trips/${params.trip_id}/feedbacks`, {feedback: params, tip: params.tips}).then((res) => {
      if (this.props.isFeedbackVisible) {
        this.returnRate()
      } else {
        window.ios ? this.props.handleBack() : window.history.back()
      }
    }).catch((error) => {
      this.submitDisabled(false)
      if (error.response) alert(error.response.data.errors)
    })
  }

  setRate = (e) => {
    this.setState({
      feedback: {...this.state.feedback, rate: parseInt(e.target.value)}
    })
  }

  setDescription = (e) => {
    let state = this.state.feedback
    state.description = e.target.value
    this.setState(state)
  }

  setTips = (e) => {
    this.setState({
      feedback: {...this.state.feedback, tips: parseInt(e.target.value)}
    })
  }

  returnRate = () => {
    this.props.getRate(this.state.feedback.rate)
    this.props.handleBack()
  }

  renderStar = (i) => {
    return [
      <label class='star' for={`star_${i}`}><Star class='star-icon'/></label>,
      <input id={`star_${i}`} type='radio' value={i} name='rate' onChange={this.setRate} defaultChecked={this.state.feedback.rate == i}/>
    ]
  }

  renderTips = (i) => {
    return [
      <input id={`tip_${i}`} type='radio' value={i} name='tip' onChange={this.setTips} defaultChecked={this.state.feedback.tips == i}/>,
      <label class='tip button white-opacity' for={`tip_${i}`}><span>{i}</span></label>
    ]
  }

  render() {
    return(
      <div class='feedback__holder'>
        <header>{i18n.feedback.header}</header>
        <button type='button' class='button burger white-opacity' onClick={this.props.handleBack}><Back/></button>
        <section class='feedback'>
          <div class='feedback__container'>
            <form ref={form => this.feedbackForm = form}>
              <textarea spellcheck='false' rows='1' placeholder={i18n.current_trip.comment} onInput={this.setDescription}/>
              <div class='stars-container'>
                {[1,2,3,4,5].map(i => this.renderStar(i))}
              </div>
              <Driver class='driver'/>
              <h4>{i18n.feedback.tips}</h4>
              <div class='tips-container'>
                {[0,5,10,20,50].map(i => this.renderTips(i))}
              </div>
              <button class='button white-opacity' type='button' disabled={this.state.submitDisabled} onClick={this.create}>{i18n.feedback.ok}</button>
            </form>
          </div>
        </section>
      </div>
    )
  }
}
