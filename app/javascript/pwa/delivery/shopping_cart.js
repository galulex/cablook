
import { h, render, Component } from 'preact'
import { route } from 'preact-router'
import axios from 'axios'
import i18n from '../i18n.js'
import CartItem from './cart_item.js'
import TimeSelect from '../time_select.js'
import '../css/cart.css'
import Back from '../images/arrow-left.svg'
import AddressInput from '../trips/address-input.js'
import Widget from '../widget.js'
import Loader from '../loader.js'
import Wheel from '../images/wheel.svg'
import Dollar from '../images/dollar.svg'
import Entrance from '../images/entrance.svg'
import Card from '../images/credit-cards-payment.js'
import Comment from '../images/contacts.svg'
import UAH from '../images/ukraine-hryvna.svg'
import Cart from './cart.js'

const ENTRANCES = Array.from({ length: 15 }, (v, k) => (k + 1))

export default class ShoppingCart extends Component {
  constructor(props) {
    super(props);
    const timeNow = new Date()
    const orderHour = timeNow.getHours() === 23 ? 0 : timeNow.getHours() + 1
    const time = `${orderHour.toString().padStart(2, '0')}:${timeNow.getMinutes().toString().padStart(2, '0')}`

    this.state = {
      submitDisabled: false,
      entrance: '',
      total_price: null,
      destination: null,
      destination_address: '',
      entrance_list: Array.from({ length: 15 }, (v, k) => (k + 1)),
      trip_cost: null,
      trip_time: time,
      trip_comment: '',
      comment: '',
      cards: this.props.cards(),
      card_id: null,
      minTime: time,
      showWidget: false,
      showLoader: true,
      vendor_closed: false,
      deliveryTrip: null,
      cart: new Cart(),
      quantity: 0,
      isLoaded: false
    }
    this.calculateTotalPrice()
  }

  componentDidMount() {
    this.props.showBurger(false)
    this.getCards()
    this.getVendorInfo()
  }

  componentWillReceiveProps() {
    this.getCards()
  }

  componentDidUpdate() {
    if (this.props.delivery_trip?.id) route('/delivery', true)
  }

  getCards = () => {
    this.setState({ cards: this.props.cards(), card_id: this.props.cards().length > 0 ? this.props.cards()[0].id : null })
  }

  getVendorInfo = () => {
    axios.get(`vendors/${this.state.cart.vendorId}`).then((res) => {
      this.setState({ vendor: res.data, vendor_closed: res.data.status !== 'open', showLoader: false, isLoaded: true })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
      if (error.response.status === 418) route('/delivery', true)
    });
  }

  vibrate = () => {
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
  }

  renderCard = (card) => {
    return <option value={card.id} key={card.id}>{card.pan} - {card.type}</option>
  }

  calculateTotalPrice = () => {
    let prices = []
    let { cart } = this.state

    Object.keys(cart.items).map((item) => {
      const current_item = cart.items[item]
      prices.push(current_item.total_price)
    })

    this.setState({ total_price: prices.reduce((a, b) => { return a + b; }, 0) })
  }

  setAddress = (destination_address, destination) => {
    this.setState({ destination_address, destination, showLoader: true }, this.goDeliveryTrip)
  }

  goDeliveryTrip = () => {
    const { destination, destination_address, cart } = this.state
    let params = {
      destination: destination,
      destination_address: destination_address,
      vendor_id: cart.vendorId
    }

    axios.get('delivery/new', { params }).then((res) => {
      let deliveryTrip = res.data
      deliveryTrip.delivery = true
      this.setState({ showLoader: false, trip_cost: res.data.cost, deliveryTrip })
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  updateStateValue = (e) => {
    this.setState({ [e.target.dataset.state]: e.target.value })
  }

  createOrder = (e) => {
    const { cart, card_id, trip_time } = this.state

    if (!e.target.form.checkValidity()) return e.target.form.reportValidity()
    this.comment.disabled = true
    this.setState({ submitDisabled: true, showLoader: true })
    const params = {
      items: cart.items,
      vendor_id: cart.vendorId,
      card_id: card_id,
      trip_time: trip_time,
      trip: this.tripParams()
    }
    this.sendOrderRequest(params)
  }

  tripParams = () => {
    const { deliveryTrip, trip_time, entrance, trip_comment } = this.state
    return (
      {
        departure: deliveryTrip.departure.join(','),
        departure_address: deliveryTrip.departure_address,
        destination: deliveryTrip.destination.join(','),
        destination_address: deliveryTrip.destination_address,
        waypoints: [deliveryTrip.departure, deliveryTrip.destination],
        time: trip_time,
        entrance: entrance,
        comment: trip_comment
      }
    )
  }

  sendOrderRequest = (order) => {
    axios.post('delivery', { order }).then((res) => {
      if (res.statusText == 'Created' && res.data.valid) {
        this.setState({ showLoader: false })
        localStorage.removeItem('cart')
        this.vibrate()
        this.comment.disabled = false
        this.props.showBurger()
        route('/delivery', true)
      } else {
        this.comment.disabled = false
        this.setState({ showLoader: false })
        alert(i18n.cart.no_money)
      }
    }).catch((error) => {
      if (!error.response) return
      this.setState({ showLoader: false })
      switch (error.response.status) {
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
    axios.post('payments/retry_pendings', { card_id: this.state.card_id }).then((res) => {
      if (res.data.length === 0) {
        this.create()
      } else {
        this.setState({ showLoader: false })
        setTimeout(() => { alert(i18n.confirm_trip.payment_error) }, 500)
      }
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }

  handleBack = () => {
    this.props.showBurger()
    route('/delivery', true)
  }

  addToCart = (item) => {
    this.state.cart.addItem(item, this.state.vendor.id, this.updateCart)
    this.setState({ items: Cart.items }, () => this.calculateTotalPrice())
  }

  removeFromCart = (item) => {
    const { cart } = this.state

    this.setState({ quantity: item.quantity > 1 ? cart.removeItem(item, this.updateCart) : cart.clearItem(item.id) }, () => this.calculateTotalPrice())
  }

  updateCart = () => {
    this.setState({ cart: new Cart() })
  }


  render() {
    let { total_price, trip_cost, cards, showWidget, showLoader, vendor_closed, vendor, cart, isLoaded } = this.state

    return (
      <div class='general__holder'>
        <button type='button' class='button burger white-opacity' onClick={() => window.ios ? this.handleBack() : window.history.back()}><Back fill='#132d50' /></button>
        <header>{i18n.cart.header}</header>
        <section class='cart'>
          {showLoader && <Loader />}
          {isLoaded && cart.isEmpty() ? ([
            <div class='tab-content__container'>
              {Object.keys(cart.items).map((item, index) => {
                return <CartItem key={index} item={cart.items[item]} itemId={item} addToCart={this.addToCart} removeFromCart={this.removeFromCart} />
              })}
            </div>,
            <div class='order-price'>
              <b>{i18n.cart.order_price}</b>
              <b class='price'>{total_price}</b>
              <UAH fill='#19a160' height='16px' width='16px' />
            </div>,
            <br />,
            vendor.active &&
            (cards.length < 1) &&
            <button class='button' type='button' disabled={showWidget} onClick={() => this.setState({ showWidget: true })}>+ {i18n.cards.add}</button>,
            vendor.active &&
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
                  <Card width='24' />
                  <select id='card' onChange={(e) => this.setState({ card_id: parseInt(e.target.value) })}>
                    {cards.map(card => <option value={card.id}>{card.pan}</option>)}
                  </select>
                </label>}
                <label for='entrance'>
                  <Entrance height='27' />
                  <select id='entrance' data-state='entrance' onChange={this.updateStateValue}>
                    <option value=''>{i18n.current_trip.select_entrance}</option>
                    {ENTRANCES.map((el) => { return <option value={el}>{el} {i18n.current_trip.entrance}</option> })}
                  </select>
                </label>
                <TimeSelect
                  minTime={this.state.minTime}
                  allDay={vendor.all_day}
                  open_at={vendor.open_at}
                  close_at={vendor.close_at}
                  setTime={this.updateStateValue}
                  time={this.state.trip_time} />
              </div>
              <label for='comment'>
                <Comment width='24' />
                <input
                  id='comment'
                  data-state='trip_comment'
                  ref={(el) => this.comment = el}
                  type='text'
                  class='comment'
                  value={this.state.trip_comment}
                  placeholder={i18n.current_trip.comment}
                  onChange={this.updateStateValue} />
              </label>
              <br />
              {trip_cost &&
                <div class='prices'>
                  <div class='mb-1'>
                    <Wheel class='align-middle' fill='#19a160' width='20' />{' '}
                    <span class='align-middle'>
                      <b>{i18n.cart.trip_price} </b>
                      <b class='price'>{trip_cost}<UAH fill='#19a160' height='14' width='14' /></b>
                    </span>
                  </div>
                  <div>
                    <Dollar class='align-middle' fill='#19a160' height='20' width='20' />{' '}
                    <span class='align-middle'>
                      <b>{i18n.cart.total_price} </b>
                      <b class='price'>{trip_cost + total_price}<UAH fill='#19a160' height='14' width='14' /></b>
                    </span>
                  </div>
                </div>}
              <br />
              {(cards.length !== 0) && <input type='submit' class={`button green ${vendor.name_slug}`} onClick={this.createOrder} value={i18n.cart.create_order} />}
            </form>,
            !vendor_closed && showWidget && <Widget updateCards={this.props.updateCards} showWidget={() => this.setState({ showWidget: false })} />,
            vendor_closed && <p>{i18n.cart.vendor_closed}</p>]
          ) : (<p>{i18n.cart.empty_cart}</p>)}
        </section>
      </div>
    )
  }
}
