import { h, render, Component } from 'preact'
import { route } from 'preact-router'
import axios from 'axios'
import i18n from './i18n.js'
import CartItem from './cart_item.js'
import TimeSelect from './time_select.js'
import './css/cart.css'
import Back from './images/arrow-left.svg'
import AddressInput from '../pwa/trips/address-input.js'
import GenerateArrayTimes from './generate-array-times.js'
import Widget from './widget.js'
import Loader from './loader.js'
import Wheel from './images/wheel.svg'
import Dollar from './images/dollar.svg'
import Entrance from './images/entrance.svg'
import Card from './images/credit-cards-payment.js'
import Comment from './images/contacts.svg'
import UAH from './images/ukraine-hryvna.svg'

const ENTRANCES = Array.from({length: 15}, (v, k) => (k+1))

export default class Cart extends Component {
  constructor(props) {
    super(props);
    const cart = JSON.parse(localStorage.getItem('cart')) || {}
    const time = `${(new Date().getHours() + 1).toString().padStart(2, '0')}:${new Date().getMinutes().toString().padStart(2, '0')}`

    this.state = {
      submitDisabled: false,
      entrance: '',
      total_price: null,
      departure: cart.vendor_location,
      departure_address: cart.vendor_address,
      destination: null,
      destination_address: '',
      entrance_list: Array.from({length: 15}, (v, k) => (k+1)),
      trip_cost: null,
      trip_time: time,
      trip_comment: '',
      comment: '',
      cards: this.props.cards(),
      card_id: null,
      minTime: time,
      showWidget: false,
      showLoader: false,
      vendor_closed: cart.vendor_status === 'close'
    }
    this.calculateTotalPrice()
  }

  componentDidMount() {
    this.props.showBurger(false)
    this.checkCurrentDeliveryTrip()
    this.getCards()
  }

  componentWillReceiveProps() {
    this.getCards()
  }

  checkCurrentDeliveryTrip = () => {
    const delivery_trip = JSON.parse(localStorage.getItem('delivery_trip'))

    if (delivery_trip && delivery_trip.id) route('/delivery', true)
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  getCards = () => {
    this.setState({cards: this.props.cards(), card_id: (this.props.cards().length >= 1) ? this.props.cards()[0].id : null})
  }

  selectCard = (event) => {
    this.setState({card_id: parseInt(event.target.value)})
  }

  renderCard = (card) => {
    return(<option value={card.id} key={card.id}>{card.pan} - {card.type}</option>)
  }

  calculateTotalPrice = () => {
    const items = localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')).items : {}
    let prices = []

    Object.keys(items).map((item, index) => {
      const current_item = JSON.parse(localStorage.getItem('cart')).items[item]
      prices.push(current_item.total_price)
    })

    this.setState({total_price: prices.reduce((a, b) => { return a + b; }, 0)})
  }

  setAddress = (destination_address, destination) => {
    this.setState({ destination_address, destination, showLoader: true }, this.goDeliveryTrip)
  }

  goDeliveryTrip = (e) => {
    const { departure, destination, departure_address, destination_address, entrance, trip_comment } = this.state
    const cart = JSON.parse(localStorage.cart)
    const phone_number = cart.vendor_phone_number
    const vendor = cart.vendor
    const comment_text = this.state.trip_comment.length < 1 ? '' : `Коментар користувача: ${this.state.trip_comment}`
    const comment = `Доставка їжі з закладу: ${vendor}. Номер телефону закладу: ${phone_number}. ${comment_text}`
    const params = {
      waypoints: [],
      stops: [],
      entrance: entrance,
      departure: departure,
      destination: destination,
      departure_address: departure_address,
      destination_address: destination_address,
      no_call: false,
      osrm: true,
      comment
    }
    this.setState({comment})


    axios.post('trips/new', {trip: params}).then((res) => {
      let trip = res.data
      trip.delivery = true
      localStorage.setItem('delivery_trip', JSON.stringify(trip))
      this.setState({ trip_cost: trip.cost, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  setComment = (e) => {
    this.setState({trip_comment: e.target.value})
  }

  updateTripTime = (e) => {
    this.setState({trip_time: e.target.value})
  }

  setTripTime = (trip_time) => {
    if (trip_time) {
      this.setState({ trip_time })
    } else {
      this.setState({ vendor_closed: true })
    }
  }

  updateEntrance = (e) => {
    this.setState({entrance: e.target.value})
  }

  submitDisabled = val => {
    this.setState({ submitDisabled: val })
  }

  create = () => {
    this.submitDisabled(true)
    this.setState({ showLoader: true })
    const cart = JSON.parse(localStorage.getItem('cart'))
    let items = cart.items;
    Object.keys(items).forEach((id) => {
      items[id] = { quantity: cart.items[id].quantity, category: cart.items[id].category, name: cart.items[id].item_name }
    })

    let params = {
      items: items,
      vendor: cart.vendor,
      card_id: this.state.card_id,
      trip_time: this.state.trip_time
    }
    this.sendOrderRequest(params)
  }

  createOrder = (e) => {
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity()
    this.comment.disabled = true
    this.create()
  }

  createTrip = (order_id) => {
    let comment_text = this.state.trip_comment.length < 1 ? '' : `Коментар користувача: ${this.state.trip_comment}`
    let params = JSON.parse(localStorage.getItem('delivery_trip'))
    params.departure = params.departure.join(',')
    params.destination = params.destination.join(',')
    params.waypoints = [params.departure, params.destination]
    params.stops = [params.departure_address, params.destination_address]
    params.card_id = this.state.card_id
    params.order_id = order_id
    params.time = this.state.trip_time
    params.entrance = this.state.entrance
    params.comment = `${this.state.comment} ${comment_text}`
    this.sendTripRequest(params)
  }

  sendTripRequest = (params) => {
    axios({
      method: params.id ? 'put' : 'post',
      url: params.id ? `trips/${params.id}` : 'trips',
      data: { trip: params }
    }).then((res) => {
      this.updateDeliveryTrip(res.data)
      this.setState({ showLoader: false })
      localStorage.setItem('delivery_items', localStorage.getItem('cart'))
      localStorage.setItem('delivery_time', this.state.trip_time)
      localStorage.removeItem('cart')
      this.vibrate()
      this.comment.disabled = false
      this.props.showBurger()
      route('/delivery', true)
    }).catch((error) => {
      if (!error.response) return
      this.setState({ showLoader: false })
      this.comment.disabled = false
      switch(error.response.status) {
        case 418:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
            this.retryPendingPayment()
          }
          break
        default:
          alert(error.response.data.errors)
          break
      }
    })
  }

  sendOrderRequest = (params) => {
    axios({
      method: 'post',
      url: 'orders',
      data: { order: params }
    }).then((res) => {
      if (res.data.valid) {
        this.createTrip(res.data.order_id)
      } else {
        this.comment.disabled = false
        this.setState({ showLoader: false })
        alert(i18n.cart.no_money)
      }
    }).catch((error) => {
      if (!error.response) return
      this.setState({ showLoader: false })
      switch(error.response.status) {
        case 418:
          if (confirm(`${error.response.data.errors} ${i18n.confirm_trip.retry_payment}`)) {
            this.retryPendingPayment()
          }
          break
        default:
          alert(error.response.data.errors)
          break
      }
    })
  }

  retryPendingPayment = () => {
    this.setState({ showLoader: true })
    axios.post('payments/retry_pendings', {card_id: this.state.card_id}).then((res) => {
      if (res.data.length === 0) {
        this.create()
      } else {
        this.setState({ showLoader: false })
        setTimeout(() => {alert(i18n.confirm_trip.payment_error)}, 500)
      }
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateDeliveryTrip = (delivery_trip) => {
    localStorage.setItem('delivery_trip', JSON.stringify(delivery_trip))
  }

  handleBack = () => {
    this.props.showBurger()
    route('/delivery', true)
  }

  render() {
    let cart = localStorage.getItem('cart')
    let vendor, items, open_at, close_at, vendor_name_slug, weekends
    if (cart) {
      cart = JSON.parse(cart)
      vendor = cart.vendor
      vendor_name_slug = cart.vendor_name_slug
      items = cart.items
      open_at = cart.vendor_open_at
      close_at = cart.vendor_close_at
      weekends = cart.vendor_weekends
    }
    const { total_price, trip_cost, cards, card_id, showWidget, showLoader, vendor_closed } = this.state

    return (
      <div class='general__holder'>
        <button type='button' class='button burger white-opacity' onClick={(event) => window.ios ? this.handleBack() : window.history.back()}><Back fill='#132d50'/></button>
        <header>{i18n.cart.header}</header>
        <section class='cart'>
          {showLoader && <Loader/>}
          { items ? ([
            <div class='tab-content__container'>
              { Object.keys(items).map((item, index) => {
                return(
                  <CartItem key={index} id={item} item={items[item]} vendor={vendor} calculateTotalPrice={this.calculateTotalPrice}/>
                )
              })
            }
            </div>,
            <div class='order-price'>
              <b>{i18n.cart.order_price}</b>
              <b class='price'>{total_price}</b>
              <UAH fill='#19a160' height='16px' width='16px'/>
            </div>,
            <br/>,
            !vendor_closed &&
            (cards.length < 1) &&
            <button class='button' type='button' disabled={showWidget} onClick={() => this.setState({showWidget: true}) }>+ {i18n.cards.add}</button>,
            !vendor_closed &&
            <form action='#' onSubmit={(e) => e.preventDefault()}>
              <AddressInput
                setAddress={this.setAddress}
                placeholder={i18n.cart.where}
                favorite_addresses={() => this.props.favorite_addresses()}
                isGeocoding={this.props.isGeocoding}
                setGeocoding={this.props.setGeocoding}
              />
              <div class='additions'>
                {(cards.length > 1) && <label class='select' for='card'>
                  <Card width='24'/>
                  <select id='card' onChange={(e) => this.selectCard(e)}>
                    {cards.map(card => <option value={card.id}>{card.pan}</option>)}
                  </select>
                </label>}
                <label for='entrance'>
                  <Entrance height='27'/>
                  <select id='entrance' onChange={this.updateEntrance}>
                    <option value=''>{i18n.current_trip.select_entrance}</option>
                    {ENTRANCES.map((el) => {
                      return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
                    })}
                  </select>
                </label>
                <TimeSelect open_at={open_at} close_at={close_at} setTime={this.updateTripTime} time={this.state.trip_time}/>
              </div>
              <label for='comment'>
                <Comment width='24'/>
                <input id='comment' ref={(el) => this.comment = el} type='text' class='comment' value={this.state.trip_comment} placeholder={i18n.current_trip.comment} onChange={this.setComment}/>
              </label>
              <br/>
              {trip_cost &&
                  <div class='prices'>
                    <div class='mb-1'>
                      <Wheel class='align-middle' fill='#19a160' width='20'/>{' '}
                      <span class='align-middle'>
                        <b>{i18n.cart.trip_price} </b>
                        <b class='price'>{trip_cost}<UAH fill='#19a160' height='14' width='14'/></b>
                      </span>
                    </div>
                    <div>
                      <Dollar class='align-middle' fill='#19a160' height='20' width='20'/>{' '}
                      <span class='align-middle'>
                        <b>{i18n.cart.total_price} </b>
                        <b class='price'>{trip_cost + total_price}<UAH fill='#19a160' height='14' width='14'/></b>
                      </span>
                    </div>
                  </div>}
                  <br/>
                  {(cards.length !== 0) &&
                      <input type='submit' class={`button green ${vendor_name_slug}`} onClick={this.createOrder} value={i18n.cart.create_order}/>}
                    </form>,
            !vendor_closed &&
            showWidget && <Widget updateCards={this.props.updateCards} showWidget={() => this.setState({showWidget: false}) }/>,
            vendor_closed &&
            <p>{i18n.cart.vendor_closed}</p>]
          ) : (
            <p>{i18n.cart.empty_cart}</p>
          )}
        </section>
      </div>
    )
  }
}
