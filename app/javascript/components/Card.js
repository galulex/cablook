import axios from 'axios'

export default class Card{
  static create = (attrs) => {
    let data = new FormData()
    const params = ['cardPan', 'cardType', 'recToken', 'currency', 'email']
    params.map((p) => {
      data.append(p, attrs[p])
    })
    return axios({method: 'POST', url: '/api/cards', data: data, headers: {'Auth-Token': localStorage.token}})
  }
  
  static fetch = () => {
    localStorage.removeItem('ready')
    return axios({method: 'GET', url: '/api/cards', headers: {'Auth-Token': localStorage.token}})
  }
}