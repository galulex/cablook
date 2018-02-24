UI = {
  set number(val) {
    document.getElementById('account').innerHTML = val
  },

  get fieldsets() {
    return document.querySelectorAll('fieldset')
  },

  get inputs() {
    return document.querySelectorAll('input')
  },

  get departure() {
    return document.getElementById('departure')
  },

  get destination() {
    return document.getElementById('destination')
  },

  get nissan() {
    return document.getElementById('nissan')
  },

  step(index = 0) {
    this.fieldsets.forEach(e => e.disabled = true)
    this.inputs.forEach(e => e.value = '')
    this.fieldsets[index].disabled = false
    var input = this.fieldsets[index].querySelector('input')
    if (input) input.focus()
  },

  disableCurrentLink() {
    let a = document.querySelectorAll('[href="'+ window.location.pathname +'"]')[0]
    if (a) a.className += ' current'
  },

  showTrip(trip) {
    document.getElementById('state').innerHTML = `
      Вартість: <b>${trip.cost}грн</b></br>
      Відстань: <b>${(trip.distance/1000).toFixed(1)}КМ</b></br>
      Відправлення: <b>${trip.start_time}</b></br>
      Прибуття: <b>${trip.finish_time}</b>
    `
    document.getElementById('cancel').remove()
    if (this.nissan) this.nissan.className.baseVal = 'nissan gone'
  }
}
