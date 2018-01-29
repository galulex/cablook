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

  step(index = 0) {
    this.fieldsets.forEach(e => e.disabled = true)
    // this.inputs.forEach(e => e.value = '')
    this.fieldsets[index].disabled = false
    var input = this.fieldsets[index].querySelector('input')
    if (input) input.focus()
  },

  showTrip(trip) {
    document.getElementById('state').innerHTML = `
      Вартість: <b>${trip.cost}грн</b></br>
      Відстань: <b>${trip.distance}km</b></br>
      Віправлення: <b>${trip.start_at}</b></br>
      Прибуття: <b>${trip.finish_at}</b>
    `
    document.getElementById('cancel').remove()
  },

  validate(input) {
    input.disabled = false
    input.focus()
    input.setCustomValidity(input.dataset.message)
    input.checkValidity()
    input.reportValidity()
  }
}
