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
    for (var i = 0; i < this.fieldsets.length; i++) { this.fieldsets[i].disabled = true }
    if (resetInput) for (var i = 0; i < this.inputs.length; i++) {
      this.inputs[i].value = ''
    }
    this.fieldsets[index].disabled = false
    var input = this.fieldsets[index].querySelector('input')
    if (input) input.focus()
  },

  disableCurrentLink() {
    let a = document.querySelectorAll('[href="'+ window.location.pathname +'"]')[0]
    if (a) a.className += ' current'
  },

  disableButtons(val = true) {
    for (var i = 0; i < this.buttons.length; i++) {
      this.buttons.disabled = val
    }
  },

  removePoint(btn) {
    btn.parentElement.parentNode.removeChild(btn.parentElement)
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
      <img class='map-img' src='https://maps.googleapis.com/maps/api/staticmap?size=400x400&path=enc:${data.trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0'></br>
      Вартість: <b>${data.trip.cost}грн</b></br>
      Відстань: <b>${(data.trip.distance/1000).toFixed(1)}КМ</b></br>
      Відправлення: <b>${data.trip.start_time}</b></br>
      Прибуття: <b>${data.trip.finish_time}</b></br>
      ${data.trip.driver_name}: <b><a href='tel:${data.trip.car_phone_number}'>${data.trip.car_phone_number}</a></b></br>
    `
    document.getElementById('loader').classList.add('hidden')
    document.getElementById('state').innerHTML = html
    if (this.nissan) this.nissan.className.baseVal = 'nissan gone'
  },

  destroyTrip() {
    document.getElementById('loader').classList.remove('hidden')
    document.getElementById('nissan').classList.remove('gone')
    document.getElementById('state').innerHTML = ''
  },

  addCards(cards) {
    let select = document.getElementById('card')
    select.innerHTML = '';
    for (var i = 0; i < cards.length; i++) {
      select.parentNode.parentNode.hidden = false
      var option = document.createElement('option')
      option.value = cards[i].id
      option.text = `${(['Персональна', 'Бізнес'])[cards[i].property]} (${cards[i].pan}) - ${cards[i].type}`
      select.add(option)
    }
    select.innerHTML += "<option value=''>Додати картку</option>";
  }
}
