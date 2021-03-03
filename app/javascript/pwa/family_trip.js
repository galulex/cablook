import { h, render, Component } from 'preact';
import axios from 'axios';
import Close from './images/close.js'
import i18n from './i18n.js';
import compact from 'lodash/compact';
import './css/statistics.css'
import './css/inputs.css'
import Phone from './images/green_phone.js';

const NUMBER_CODE = '+380'

export default class FamilyTrip extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: false,
      showing: false,
      phoneNumbers: [],
      phoneNumber: '',
      disabled: false,
      card_id: '',
      card: { load: true }
    }
  }

  componentDidMount() {
    this.setState({ isLoading: true }, () => {
      axios.get('/business').then((res) => {
        this.setState({ 
          phoneNumbers: res.data.users.map(u => u.phone_number),
          card_id: res.data.card_id,
          card: res.data.card
        })
      }).catch((error) => {
        this.setState({isLoading: false});
      })
    })
  }

  render() {
    return (
      <div class='profile__container general__holder'>
        <header class='main'>{ i18n.family_trip.header }</header>
        <section>
          <div class="tabs">
            <div class="tabs__content" ref={el => this.tabsContent = el}>
              <div class="tab-content">
              <div class="tab-content__holder">
                { this.cardSelect() }
                <div class="tab-content__container">
                  <div class="tab-content__header">{ i18n.family_trip.member_list }</div>
                  <div class="tab-content__container-items">
                    { this.familyMemberList() }
                    { this.state.showing ? this.newForm() : this.newAddButton() }
                  </div>
                </div>
              </div>
              </div>
            </div>
          </div>
        </section>
      </div> 
    )
  }

  cardSelect = () => {
    return(
      <div class='tab-content__container'>
        <div class='tab-content__header'>{ i18n.family_trip.card }</div>
        <span class='divider'></span>
        <label for='period' class='select'>
          <select id='period' onChange={(e) => this.setCard(e)}>
            {this.props.cards.map(card => <option value={card.id} >{card.pan}</option>)}
          </select>
        </label>
      </div>
    )
  }

  setCard = (e) => {
    this.setState({ card_id: e.target.value }, () => {
      if (this.state.phoneNumbers.length > 0) this.update()
    })
  }

  familyMemberList = () => {
    if (this.state.phoneNumbers.length > 0) return(this.listPhones())
    
    return(<div><h5 class='nocards center'></h5>{i18n.family_trip.blank_list}</div>)
  }

  listPhones = () => {
    return(
      <ul class='tab-content__container-items places'>
        { this.state.phoneNumbers.map((number, i) => {
          return(
            <li class='tab-content__container-item'>
              <span class='address'>{number}</span>
              <button class='x-card' type='button' onClick={() => this.removePhoneNumber(i)}><Close /></button>
            </li>
          )
        })}
      </ul>
    )
  }

  newForm = () => {
    return(
      <form id="newFamilyMember" onSubmit={this.addMemberNumber}>
        <br />
        <div class="number_input">
          <label for="number"><Phone class="phone"/>{NUMBER_CODE}</label>
          <input
            id="number" class="number__input" title={9 + i18n.session.digits}
            name="phoneNumber" pattern="[0-9]*"
            maxlength="9" minlength="9"
            placeholder="__  ___  __ __" type="tel"
            autocomplete="off" required autoFocus
            onChange={this.handleChange}
            ref={ref => this.memberNumber = ref}
          />
        </div>
        <button class="button green add_fav_address" type="submit" disabled={this.state.disabled}>OK</button>
      </form>
    )
  }

  onAddClick = () => {
    setTimeout(() => { this.memberNumber.focus() }, 10)
    this.setState({ showing: !this.state.showing })
  }

  handleChange = (e) => {
    this.setState({ phoneNumber: NUMBER_CODE + e.target.value })
  }

  newAddButton = () => {
    return(
      <div>
        <br />
        <button class='button green absolut' type='button' onClick={this.onAddClick}>{'+ ' + i18n.family_trip.add_member}</button>
      </div>
    )
  }

  removePhoneNumber = (i) => {
    this.state.phoneNumbers.splice(i, 1)
    this.setState({ phoneNumbers: this.state.phoneNumbers })
    this.update()
  }

  addMemberNumber = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    this.update()
  }

  update = () => {
    this.setState({ disabled: true }, () => {
      axios.patch('/business', {
        business: {
          email: localStorage.email,
          name: localStorage.email.split('@')[0],
          employees: compact([...this.state.phoneNumbers, this.state.phoneNumber]),
          card_id: this.state.card_id ? this.state.card_id : this.props.cards[0].id
        }
      })
      .then( response => {
        this.setState({
          showing: false,
          phoneNumber: '',
          disabled: false,
          phoneNumbers: response.data.users.map(u => u.phone_number),
          card: response.data.card
        })
      })
      .catch( error => {
        this.setState({ disabled: false })
        if (error.response) alert(error.response.data.errors)
      })
    })
  }
}