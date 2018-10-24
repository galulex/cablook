import axios from 'axios'
import UI from './UI';

export default class Session {
  static create = () => {
    let data = new FormData()
    data.append('phone_number', UI.number())
    return axios.post('api/session', data)
  }

  static update = () => {
    let token = document.getElementById('verification').value
    let data = new FormData()
    data.append('phone_number', localStorage.phone)
    data.append('token', token)
    return axios.patch('api/session', data)
  }

  static destroy = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('phone')
    localStorage.removeItem('ready')
    localStorage.removeItem('referralCode')
  }
}
