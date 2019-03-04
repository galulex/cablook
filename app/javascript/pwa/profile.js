import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import Close from './images/times-circle.svg'

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props)
      this.state = {
      favorite_addresses: this.props.favorite_addresses || [],
      id: null,
      name: null,
      location: null,
      user_id: null
    }
  }

  ComponentWillMount() {
  }

  componentDidMount() {
    axios.get(`/favorite_addresses`, { headers: {'Auth-Token': localStorage.token} })
      .then(res => {
        this.setState(this.applyUpdateResult(res.data));
      })
  }

  applyUpdateResult = (result) => (prevState) => ({
    favorite_addresses: [...prevState.favorite_addresses, ...result.favorite_addresses]
  });

  render() {
    let favoriteAddressesList = (<div><h4 class='nocards'>{i18n.profile_page.no_addresses}</h4></div>)
    if (this.state.favorite_addresses.length > 0) {
      favoriteAddressesList = (
        <ul class='cards'>
          { this.state.favorite_addresses.map((address, i) => {
            return(
              <li>
                <span>{address.name}</span>
                <button class='x-card' type='button' onClick={() => this.delete(address.id, i)}><Close fill='#a925ad'/></button>
              </li>
            )
          })}
        </ul>
      )
    }
    return (
      <section>
        <header>{i18n.profile_page.header}</header>
          <h2>{i18n.profile_page.favorite_addresses}</h2>
          { favoriteAddressesList }
        <div>
          <button>Add new</button>
        </div>
      </section>
    )
  }

  delete = (id, index) => {
    if (!confirm('Are you sure?')) return;
    let favorite_addresses = this.state.favorite_addresses

    axios.delete(`favorite_addresses/${id}`).then((address) => {
      favorite_addresses.splice(index, 1)
      this.setState({favorite_addresses: favorite_addresses})
      this.props.updateFavoriteAddresses(favorite_addresses)
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
