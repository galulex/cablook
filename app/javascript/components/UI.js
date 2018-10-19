import React from 'react'
import Localization from '../localization/Localization'

export default class UI{
  static form = () => {
    return document.getElementsByClassName('form')
  }
  
  static addCards = (cards) => {
    let select = document.getElementById('card')
    select.innerHTML = '';
    cards.each((card) => {
      select.parentNode.parentNode.hidden = false
      var option = document.createElement('option')
      option.value = cards[card].id
      option.text = `${([Localization.ui.personal_card, Localization.ui.bussines_card])[cards[card].property]} (${cards[card].pan}) - ${cards[card].type}`
      select.add(option)
    })
    select.innerHTML += `<option value=''>${Localization.ui.add_card}</option>`;
  }

  static addPoint = () => {
    let destination = document.getElementById('destination_address')
    let button = document.getElementById('add_point')
    let point = destination.parentElement.cloneNode(true)
    point.id = Date.now().toString()
    point.querySelector('input').value = ''
    point.querySelector('input').removeAttribute('data-point')
    point.addEventListener('click', this.removePoint(point), false)
    button.parentElement.insertBefore(point, button)
  }

  static removePoint = (point) => {
    point.parentElement.parentNode.removeChild(point.parentElement)
  }

  static waypoints = () => {
    return document.getElementsByName('waypoints')
  }

  static number = () => {
    return document.getElementById('number').value
  }

  static destroyTrip = () => {
    document.getElementById('loader').classList.remove('hidden')
    document.getElementById('nissan').classList.remove('gone')
  }

  static renderCard = (card) => {
    return (<option value={card.id} key={card.id}>{
      card.property === 0 ? `${Localization.ui.personal_card}` : `${Localization.ui.bussines_card}`
    } {card.pan} - {card.type} </option>)
  }

  static showBonus = () => {
    let input = document.getElementById('bonus')
    input.parentNode.hidden = false
  }

  static selectCard = (event, that) => {
    if(event.currentTarget.value == ''){
      that.pay()
      event.currentTarget.selectedIndex = 0
      trip.card_id = event.currentTarget.value
    }
    trip.card_id = event.currentTarget.value
  }

  static number = () => {
    return '+380' +  document.getElementById('number').value
  }
}