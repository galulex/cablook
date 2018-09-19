import React, { Component } from 'react'
import UI from './UI'
import Session from './Session'

export default class NumberForm extends Component {
  handleSubmit = (event) => {
    event.preventDefault()
    Session.create().then(response =>{
      localStorage.phone = response.data['phone_number']
      localStorage.token = response.data['auth_token']
      this.props.updateStep(2)
    }).catch(err => {
      alert(err.response.data.errors)
    })
  }

  render() {
    return (
      <form  className='form' id='form' onSubmit={this.handleSubmit}  action='/' >
        <div className='form__fieldset form__fieldset--short'>
          <label className='form__number-label' htmlFor='number'>+380</label>
          <input className='form__number' id='number' max='999999999' min='100000000' name='phone_number' placeholder='932225665' required type='number' autoFocus/>
          <label htmlFor='number'>Введіть номер</label>
          <button className='button' id='submit_phone' type='submit'>Далі</button>
        </div>  
      </form>
    )
  }
}