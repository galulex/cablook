import { h, render, Component } from 'preact'
import { route } from 'preact-router'
import axios from 'axios'
import i18n from './i18n.js'
import CartItem from './cart_item.js'
import './css/cart.css'
import Back from './images/arrow-left.svg'
import AddressInput from '../pwa/trips/address-input.js'
import GenerateArrayTimes from './generate-array-times.js'
import Widget from './widget.js'
import Loader from './loader.js'
import Wheel from './images/wheel.svg'
import Dollar from './images/dollar.svg'

export default class Cart extends Component {
  constructor(props) {
    super(props);
    const cart = JSON.parse(localStorage.getItem('cart')) || {}

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
      trip_time: '',
      cards: this.props.cards(),
      card_id: null,
      showWidget: false,
      showLoader: false,
      vendor_closed: false
    }
    this.calculateTotalPrice()
  }

  componentDidMount() {
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
    this.setState({ destination_address, destination, showLoader: true })
    this.goDeliveryTrip()
  }

  goDeliveryTrip = (e) => {
    const { departure, destination, departure_address, destination_address, trip_time, entrance } = this.state
    const params = {
      waypoints: [],
      stops: [],
      entrance: entrance,
      departure: departure,
      destination: destination,
      departure_address: departure_address,
      destination_address: destination_address,
      no_call: false,
      time: trip_time,
      osrm: true,
      vip: true,
      comment: ''
    }

    axios.post('trips/new', {trip: params}).then((res) => {
      let trip = res.data
      trip.delivery = true
      localStorage.setItem('delivery_trip', JSON.stringify(trip))
      this.setState({ trip_cost: trip.cost, showLoader: false })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
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

    let delivery_trip = JSON.parse(localStorage.getItem('delivery_trip'))

    if (delivery_trip) {
      delivery_trip.comment = ` ${e.target.value} подъезд`
      localStorage.setItem('delivery_trip', JSON.stringify(delivery_trip))
    }
  }

  submitDisabled = val => {
    this.setState({ submitDisabled: val })
  }

  createOrder = (e) => {
    if (!e.target.form.checkValidity()) return e.target.form.reportValidity();
    this.submitDisabled(true)
    this.setState({ showLoader: true })
    const cart = JSON.parse(localStorage.getItem('cart'))

    let params = {
      items: cart.items,
      vendor: cart.vendor,
      card_id: this.state.card_id,
      trip_time: this.state.trip_time
    }
    this.sendOrderRequest(params)
  }

  createTrip = (order_id) => {
    let params = JSON.parse(localStorage.getItem('delivery_trip'))
    params.departure = params.departure.join(',')
    params.destination = params.destination.join(',')
    params.card_id = this.state.card_id
    params.order_id = order_id
    params.time = this.state.trip_time
    params.vip = true
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
      localStorage.removeItem('cart')
      this.vibrate()
      route('/delivery', true)
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

  sendOrderRequest = (params) => {
    axios({
      method: 'post',
      url: 'orders',
      data: { order: params }
    }).then((res) => {
      if (res.data.valid) {
        this.createTrip(res.data.order_id)
      } else {
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
        this.createOrder()
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

  createCard = (data) => {
    this.props.createCard(data)
    this.setState({showWidget: false})
  }

  render() {
    let cart = localStorage.getItem('cart')
    let vendor, items, open_at, close_at
    if (cart) {
      cart = JSON.parse(cart)
      vendor = cart.vendor
      items = cart.items
      open_at = cart.vendor_open_at
      close_at = cart.vendor_close_at
    }
    const { total_price, trip_cost, cards, card_id, showWidget, showLoader, vendor_closed } = this.state

    return (
      <section class='cart'>
        {showLoader && <Loader/>}
        <button type='button' class='burger' onClick={(event) => window.history.back()}><Back fill='#132d50'/></button>
        <header>
          {i18n.cart.header}
        </header>
        { items ? ([
          Object.keys(items).map((item, index) => {
            return(
              <CartItem key={index} item_name={item} item={items[item]} vendor={vendor} calculateTotalPrice={this.calculateTotalPrice}/>
            )
          }),
          <div class='order-price'>
            <b>{i18n.cart.order_price}</b>
            <b class='price'>{total_price} {i18n.cart.uah}</b>
          </div>,
          !vendor_closed &&
            (cards.length > 0) &&
              <div class='select-section'>
                <label for='card'>{i18n.confirm_trip.card}</label>
                <div class='select'>
                  <select id='card' onChange={(e) => this.selectCard(e)}>
                    {cards.map((el) => this.renderCard(el))}
                  </select>
                </div>
              </div>,
          !vendor_closed &&
            (cards.length < 1) &&
              <button class='button fixed' type='button' disabled={showWidget} onClick={() => this.setState({showWidget: true}) }>+ {i18n.cards.add}</button>,
          !vendor_closed &&
            <form action='#' onSubmit={(e) => e.preventDefault()}>
              <AddressInput
                  setAddress={this.setAddress}
                  placeholder={i18n.cart.where}
                  favorite_addresses={() => this.props.favorite_addresses()}/>
              <label for='entrance'>
                <span>{i18n.current_trip.where_to_pick}</span>
                <select id='entrance' onChange={this.updateEntrance}>
                  <option value=''>{i18n.current_trip.select_entrance}</option>
                  {this.state.entrance_list.map((el) => {
                    return(<option value={el}>{el} {i18n.current_trip.entrance}</option>)
                  })}
                </select>
              </label>
              <GenerateArrayTimes
                  start_time={parseInt(open_at.split(':')[0])}
                  finish_time={parseInt(close_at.split(':')[0])}
                  updateTripTime={this.updateTripTime}
                  setTripTime={this.setTripTime}/>
              {trip_cost &&
                <div class='prices'>
                  <div class='mb-1'>
                    <Wheel class='align-middle'/><span class='align-middle'><b>{i18n.cart.trip_price}</b> <b class='price'>{trip_cost} {i18n.cart.uah}</b></span>
                  </div>
                  <div>
                    <Dollar class='align-middle'/><span class='align-middle'><b>{i18n.cart.total_price}</b> <b class='price'>{trip_cost + total_price} {i18n.cart.uah}</b></span>
                  </div>
                </div>}
              {(cards.length !== 0) &&
                <input type='submit' class='button' onClick={this.createOrder} value={i18n.cart.create_order}/>}
            </form>,
          !vendor_closed &&
            showWidget && <Widget createCard={this.createCard}/>,
          vendor_closed &&
            <p>{i18n.cart.vendor_closed}</p>]
        ) : (
          <p>{i18n.cart.empty_cart}</p>
        )}
      </section>
    )
  }
}
