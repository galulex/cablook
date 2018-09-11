class WFP {
  constructor() {
    let date = Date.now()
    let orderReference = md5(date, localStorage.number)
    this.straightWidget = true
    this.merchantAccount = window._MERCHANT
    this.merchantDomainName = 'cablook.taxi'
    this.authorizationType = 'SimpleSignature'
    this.orderReference = orderReference
    this.serviceUrl = `https://${window.location.hostname}/api/cards/update`
    this.orderDate = date
    this.amount = '1'
    this.currency = 'UAH'
    this.productName = 'Удержание за добавление карты'
    this.productPrice = '1'
    this.transactionType = 'VERIFY'
    this.clientPhone = localStorage.number
    this.productCount = '1'
    this.paymentSystem = 'card'
    this.merchantSignature = md5(`${this.merchantAccount};${this.merchantDomainName};${orderReference};${date};${this.amount};${this.currency};${this.productName};1;1`, window._TOKEN)
  }
}
