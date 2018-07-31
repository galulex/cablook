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
      Cards.fetch()
    })
  },

  fetch: () => {
    localStorage.removeItem('ready')
    ajax('cards', 'GET', {}, data => {
      if (data['cards'].length > 0) localStorage.ready = true
      UI.addCards(data['cards'])
      Bonus.fetch()
    })
  }
}
