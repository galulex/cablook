Sessions = {
  create: () => {
    data = new FormData(UI.form)
    let phone = '+380' + data.get('phone_number')
    data.append('phone_number', phone)
    ajax('session', 'POST', data, () => {
      app.phone = phone
      UI.number = phone
      app.step = 1
    })
  },

  update: () => {
    data = new FormData(UI.form)
    data.append('phone_number', app.phone)
    ajax('session', 'PATCH', data, data => {
      localStorage.token = data['auth_token']
      localStorage.number = data['phone_number']
      if (data['has_cards']) localStorage.ready = data['ready']
      app.step = 2
    })
  },

  destroy: () => {
    localStorage.removeItem('token')
    localStorage.removeItem('number')
    localStorage.removeItem('ready')
    UI.number = ''
    app.step = 0
  }
}
