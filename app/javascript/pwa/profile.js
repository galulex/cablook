import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'

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
    axios.get(`/favorite_addresses`, { headers: {'Auth-Token': localStorage.token}})
      .then(res => {
        this.setState(this.applyUpdateResult(res.data));
      })
  }

  applyUpdateResult = (result) => (prevState) => ({
    favorite_addresses: [...prevState.favorite_addresses, ...result.favorite_addresses]
  });

  render() {
    let favoriteAddressesList = (<div><h4 class='noaddresses'>{i18n.profile_page.no_addresses}</h4></div>)
    if (this.state.favorite_addresses.length > 0) {
      favoriteAddressesList = (
        <ul class='favorite_addresses'>
          { this.state.favorite_addresses.map((address, i) => {
            return(
              <li>
                <span>{address.name}</span>
              </li>
            )
          })}
        </ul>
      )
    }
    return (
      <section>
        <header>{i18n.profile_page.header}</header>
          <h2>Your favorite addresses:</h2>
        { favoriteAddressesList }
      </section>
    )
  }
}
