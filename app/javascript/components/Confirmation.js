import React, { Component } from 'react'
import Session from './Session'

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
      <form  className='confirmation' id='form' action='/' onSubmit={this.handleSubmit}>
        <div className='form__fieldset' disabled={this.props.disabled}>
          <input data-message='Неправильний код' id='verification' max='9999' min='1000' name='token' pattern='.{4}' placeholder='1234' required type='number' autoFocus />
          <label htmlFor='verification'>Введiть код з СМС</label>
          <button className='button' id='submit_code' type='submit'>Далі</button>
          <button className='button yellow-button' onClick={this.changeNumber} type='button'>Змiнити номер</button>
        </div>
      </form>
    )
  }
}