Sessions = {
  create: event => {
    if (!isValid(event)) return false
    let input = event.target
    let val = "+380" + input.value
    ajax('session', 'POST', {phone_number: val}, data => {
      app.phone = val
      UI.number = val
      UI.step(1)
    })
  },

  update: event => {
    if (!isValid(event)) return false
    let input = event.target
    ajax('session', 'PATCH', {phone_number: app.phone, token: input.value}, data => {
      localStorage.token = data['auth_token']
      localStorage.number = data['phone_number']
      if (data['has_cards']) localStorage.ready = data['ready']
      UI.step(2)
    })
  },

  destroy: () => {
    localStorage.removeItem('token')
    localStorage.removeItem('number')
    localStorage.removeItem('ready')
    UI.number = ''
    UI.step(0)
  }
}
