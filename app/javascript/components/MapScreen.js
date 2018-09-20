import React, { Component } from 'react'
import UI from './UI'
import Trip from './Trip'

export default class MapScreen extends Component {
  constructor(props){
    super(props)
  }

  componentDidMount = () => {
    window.addEventListener('load', this.handleLoad())
  }

  handleSubmit = (event) => {
    event.preventDefault()
    Trip.create(this)
  }

  handleLoad = () => {
    if (this.props.bonuses.some((e) => e.status == 1)) UI.showBonus()
  }

  handleClick = (event) => {
    event.preventDefault()
    Trip.destroy(this)
  }

  pay = () => {
    const that = this
    const wayforpay = new Wayforpay();  
    wayforpay.run((new WFP),
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          that.props.createCard(response)
        }, 1000)
      },
      response =>{
        alert(response)
      },
      response =>{
        setTimeout(function(){
          wayforpay.closeit()
          that.props.createCard(response)
        }, 1000)
      }
    );
  }

  render (){
    return (
      <form onSubmit={this.handleSubmit} className='form'>
        <div className='form__fieldset' data-action=''>
          <div className='form__user-number'>
            <img className='map-img' id='trip_path' src={this.props.path}/>
            <br/>Вартість: <b id='trip_cost'>{trip.cost}грн</b>
            <br/>Відстань: <b id='trip_distance'>{(trip.distance/1000).toFixed(1)}км</b>
          </div>
          <br/>
          <div className='card-section'>
            <label htmlFor='card'>Оберіть картку</label> 
            <div className='select'>
              <select id='card' name='trip[card_id]' onChange={(e) => UI.selectCard(e, this)}>
                {this.props.cards.map((el) => UI.renderCard(el))}
                <option value=''>Додати картку</option>
              </select>
            </div>
          </div>
          <br/>
          <div className='bonus-section' hidden={true}>
            <button className='button' id='bonus' name='trip[bonus]' onClick={(e) => trip.bonus = e.target.value} type='submit' value='true'>Використати бонусну поїздку</button>
          </div>
          <button className='button' id='go' type='submit'>Поїхали</button>
          <button className='button yellow-button' onClick={this.handleClick} type='button'>Відмінити</button>
        </div>
      </form>
    )
  }
}