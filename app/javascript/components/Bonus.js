import axios from 'axios'

export default class Bonus {
  static fetch = () => {
    return axios({method: 'GET', url: '/api/bonus_trips', headers: {'Auth-Token': localStorage.token}})
  }
}