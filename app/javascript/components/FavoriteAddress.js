import axios from 'axios'

export default class FavoriteAddress{
  static create = (attrs) => {
    let data = new FormData()
    const params = ['name', 'location']
    params.map((p) => {
      data.append(p, attrs[p])
    })
    return axios({method: 'POST', url: '/api/favorite_addresses', data: data, headers: {'Auth-Token': localStorage.token}})
  }

  static fetch = () => {
    localStorage.removeItem('ready')
    return axios({method: 'GET', url: '/api/favorite_addresses', headers: {'Auth-Token': localStorage.token}})
  }
}