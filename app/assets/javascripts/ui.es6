UI = {
  set number(val) {
    document.getElementById('account').innerHTML = val
  },

  set destination(location) {
    document.getElementById('destination_lat').value = location.lat()
    document.getElementById('destination_lng').value = location.lng()
  },

  set departure(location) {
    document.getElementById('departure_lat').value = location.lat()
    document.getElementById('departure_lng').value = location.lng()
  },

  get fieldsets() {
    return document.querySelectorAll('fieldset')
  },

  get inputs() {
    return document.querySelectorAll('input')
  },

  get buttons() {
    return document.querySelectorAll('button')
  },

  get departureAddress() {
    return document.getElementById('departure_address')
  },

  get destinationAddress() {
    return document.getElementById('destination_address')
  },

  set path(val) {
    document.getElementById('trip_path').setAttribute('src', val)
  },

  get waypoints() {
    return document.querySelectorAll("[name='waypoints']")
  },

  get form() {
    return document.getElementById('form')
  },

  get nissan() {
    return document.getElementById('nissan')
  },

  step(index = 0, resetInput = true) {
    this.fieldsets.forEach(e => e.disabled = true)
    if (resetInput) this.inputs.forEach(e => e.value = '')
    this.fieldsets[index].disabled = false
    var input = this.fieldsets[index].querySelector('input')
    if (input) input.focus()
  },

  disableCurrentLink() {
    let a = document.querySelectorAll('[href="'+ window.location.pathname +'"]')[0]
    if (a) a.className += ' current'
  },

  disableButtons(val = true) {
    this.buttons.forEach(b => {
      b.disabled = val
    })
  },

  removePoint(btn) {
    btn.parentElement.remove()
  },

  addPoint(button) {
    let point = this.destinationAddress.parentElement.cloneNode(true)
    point.id = Date.now().toString()
    point.querySelector('input').value = ''
    point.querySelector('input').removeAttribute('data-point')
    button.parentElement.insertBefore(point, button)
  },

  showTrip(data) {
    let html = `
      <img scr='https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:${trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0'></br>
      Вартість: <b>${data.trip.cost}грн</b></br>
      Відстань: <b>${(data.trip.distance/1000).toFixed(1)}КМ</b></br>
      Відправлення: <b>${data.trip.start_time}</b></br>
      Прибуття: <b>${data.trip.finish_time}</b></br>
    `
    if (data.driver) {
      html += `${data.driver.name}: <b><a href='tel:${data.driver.car.phone_number}'>${data.driver.car.phone_number}</a></b></br>`
    }
    document.getElementById('loader').classList.add('hidden')
    document.getElementById('state').innerHTML = html
    if (this.nissan) this.nissan.className.baseVal = 'nissan gone'
  },

  destroyTrip() {
    document.getElementById('loader').classList.remove('hidden')
    document.getElementById('state').innerHTML = ''
  }
}
