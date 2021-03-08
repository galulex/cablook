import { h, Component } from 'preact';
import axios from 'axios';
import Close from './images/close.js'
import i18n from './i18n.js';
import Phone from './images/green_phone.js';

const NUMBER_CODE = '+380'

export default class Family extends Component {
  constructor(props) {
    super(props)
    this.state = {
      showing: false,
      phoneNumbers: [],
      disabled: false,
      card: {}
    }
  }

  componentDidMount() {
    axios.get('/business').then((res) => {
      this.setState({ 
        phoneNumbers: res.data.users.map(u => u.phone_number),
        card: res.data.card
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
                  <div class="tab-content__header">{ i18n.family_trip.members_list }</div>
                  <div class="tab-content__container-items">
                    { this.familyMembersList() }
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
    this.setState({ card: this.props.cards.find((card) => card.id == e.target.value)}, () => {
      if (this.state.phoneNumbers.length > 0) this.update()
    })
  }

  familyMembersList = () => {
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

  newAddButton = () => {
    let pickerSuport = ('contacts' in navigator && 'ContactsManager' in window);

    return(
      <div>
        <br />
        <button class='button green absolut' type='button' onClick={pickerSuport ? this.contactPicker : this.onAddClick}>{'+ ' + i18n.family_trip.add_member}</button>
      </div>
    )
  }

  contactPicker = async () => {
    let contacts = await navigator.contacts.select(['tel']);

    if (contacts.length > 0) {
      let phoneNumber = contacts[0].tel[0].replace(/\s/g, '')
      this.update([...this.state.phoneNumbers, NUMBER_CODE + phoneNumber.slice(-9)])
    }
  }

  removePhoneNumber = (i) => {
    this.state.phoneNumbers.splice(i, 1)
    this.setState({ phoneNumbers: this.state.phoneNumbers })
    this.update()
  }

  addMemberNumber = (e) => {
    e.preventDefault()
    if (!e.target.checkValidity) return;
    this.update([...this.state.phoneNumbers, NUMBER_CODE + e.target[0].value])
  }

  update = (phoneNumbers = this.state.phoneNumbers) => {
    this.setState({ disabled: true }, () => {
      axios.patch('/business', {
        business: {
          email: localStorage.email,
          name: localStorage.email.split('@')[0],
          employees: phoneNumbers,
          card_id: this.state.card.id
        }
      })
      .then( response => {
        this.setState({
          showing: false,
          disabled: false,
          phoneNumbers: response.data.users.map(u => u.phone_number),
          card: response.data.card
        })
      })
    })
  }
}
