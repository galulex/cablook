import { h, render, Component } from 'preact';
import axios from 'axios';

import i18n from './i18n.js'
import Close from './images/times-circle.svg'

export default class FavoriteAddresses extends Component {
  constructor(props) {
    super(props)
      this.state = {
      showing: false,
      favorite_addresses: [],
      id: null,
      name: null,
      location: null,
      user_id: null
    }
    this.handleChange = this.handleChange.bind(this);
  }

  componentDidMount() {
    axios.get(`/favorite_addresses`)
      .then(res => {
        this.setState({favorite_addresses: res.data});
      })
  }

  handleChange(e) {
    this.setState({ [e.target.name] : e.target.value });
  }

  render() {
    const { showing } = this.state;
    let favoriteAddressesList = (<div><h4 class='nocards'>{i18n.profile_page.no_addresses}</h4></div>)
    
    let newForm = (
      <div id="newFavoriteAddressForm">
        <form>
          Name: <input type="text" name="name" value={this.state.name} onChange={this.handleChange.bind(this)} />
          Location: <input type="text" name="location" value={this.state.location} onChange={this.handleChange.bind(this)} />
          <button type="reset" onClick={() => this.create(this.state.name, this.state.location)}>+</button>
        </form>
      </div>
    )

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
          { showing ? newForm : null }
          <button class='button fixed' type='button' onClick={() => this.setState({ showing: !showing })}>+ {i18n.profile_page.add_address}</button>
      </section>
    )
  }

  create = (name, location) => {
    axios.post('/favorite_addresses', {
      name: name,
      location: location
    })
    .then(function (response) {
      console.log(response);
    })
    .catch(function (error) {
      console.log(error);
    });
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
