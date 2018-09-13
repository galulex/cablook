import React, { Component } from 'react'

import Trip from './Trip'

export default class TripScreen extends Component {
  constructor(props){
    super(props)
  }

  render () {
    return (
      <form className='trip_form'>
        <div className='loader' id='loader'>
          <svg xmlns='http://www.w3.org/2000/svg' viewBox='-208.9 138.5 55.3 56.7' className='icon'>
            <ellipse cx='-181.3' cy='166.9' fill='none' stroke='#FFF' strokeMiterlimit='10' strokeWidth='3' rx='26.1' ry='26.8'></ellipse>
            <ellipse cx='-181.3' cy='167.1' fill='none' stroke='#FFF' strokeDasharray='11.4665,12.422' strokeLinecap='round' strokeMiterlimit='10' strokeWidth='3' rx='18.8' ry='19.2'></ellipse>
          </svg>
        <p>Одну хвилинку, підбираємо машинку</p>
        </div>
        <div className='state form__user-number' id='state'></div>
        <button className='button yellow-button' id='cancel' onClick={Trip.cancel} type='button'>Відмінити</button>
      </form>
    );
  }
}
