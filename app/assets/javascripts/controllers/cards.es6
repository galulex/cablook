let Cards = {
  create: attrs => {
    ajax('cards', 'POST', attrs, data => {
      localStorage.ready = true
      Trips.create()
    })
  }
}
