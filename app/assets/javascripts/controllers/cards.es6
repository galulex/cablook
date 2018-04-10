let Cards = {
  create: attrs => {
    data = new FormData()
    data.append('cardPan', attrs.cardPan)
    data.append('cardType', attrs.cardType)
    data.append('recToken', attrs.recToken)
    data.append('currency', attrs.currency)
    data.append('email', attrs.email)
    ajax('cards', 'POST', data, data => {
      localStorage.ready = true
      Trips.create()
    })
  }
}
