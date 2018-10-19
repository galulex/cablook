import React, { Component } from 'react'
import Session from './Session'
import Localization from '../localization/Localization'

export default class Confirmation extends Component {
  constructor(props){
    super(props)
  }

  handleSubmit = (event) => {
    event.preventDefault()
    Session.update().then(response =>{
      this.props.updateNumber(response.data['phone_number'])
      this.props.fetchCards()
      if (response.status == 200){
        localStorage.referralCode = response.data['referral_code']
        this.props.updateStep(3)
      }
    })
    .catch(error => { 
      alert(error.response.data.errors)
    })
  }

  changeNumber = () => {
    Session.destroy()
    this.props.updateStep(1)
  }

  render (){
    return (
      <form  className='form' id='form' action='/' onSubmit={this.handleSubmit}>
        <div className='form__fieldset' disabled={this.props.disabled}>
          <input data-message={Localization.confirmation.incorrect_code} id='verification' max='9999' min='1000' name='token' pattern='.{4}' placeholder='1234' required type='number' autoFocus />
          <label htmlFor='verification'>{Localization.confirmation.sms_code}</label>
          <button className='button' id='submit_code' type='submit'>{Localization.confirmation.submit}</button>
          <button className='button yellow-button' onClick={this.changeNumber} type='button'>{Localization.confirmation.change_number}</button>
        </div>
      </form>
    )
  }
}