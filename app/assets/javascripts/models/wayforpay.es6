class WFP {
  constructor() {
    let date = Date.now()
    let orderReference = md5(date, localStorage.number)
    this.straightWidget = true
    this.merchantAccount = 'cablook_taxt'
    this.merchantDomainName = 'cablook.taxi'
    this.authorizationType = 'SimpleSignature'
    this.orderReference = orderReference
    this.orderDate = date
    this.amount = '1'
    this.currency = 'UAH'
    this.productName = 'Удержание за добавление карты'
    this.productPrice = '1'
    this.transactionType = 'VERIFY'
    this.clientPhone = localStorage.number
    this.productCount = '1'
    this.paymentSystem = 'card'
    this.merchantSignature = md5(`${this.merchantAccount};${this.merchantDomainName};${orderReference};${date};${this.amount};${this.currency};${this.productName};1;1`, 'f624df99f3bd2db35c0951b2cf4461b9f39ec534')
  }
}
