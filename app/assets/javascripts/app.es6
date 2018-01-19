class App {
  constructor() {
    if (!localStorage.token) return false
    this.fieldsets[0].disabled = true
    this.fieldsets[2].disabled = false
    document.getElementById('account').innerHTML = localStorage.number
  }

  get fieldsets() {
    return document.querySelectorAll('fieldset')
  }

  signIn(event) {
    if (!this.isValid(event)) return false
    let input = event.target
    let val = "+380" + input.value
    ajax('session', 'POST', {phone_number: val}).then(res => {
      if (res.ok) {
        localStorage.number = val
        this.nextStep(input)
      } else {
        this.validate(input)
      }
    })
  }

  verify(event) {
    if (!this.isValid(event)) return false
    let input = event.target
    ajax('session', 'PATCH', {phone_number: localStorage.number, token: input.value}).then(res => {
      if (res.ok) {
        res.json().then(data => {
          localStorage.token = data['auth_token']
          document.getElementById('account').innerHTML = localStorage.number
        })
        this.nextStep(input)
      } else {
        this.validate(input)
      }
    })
  }

  signOut() {
    localStorage.removeItem('token')
    this.fieldsets[0].disabled = false
    this.fieldsets[1].disabled = true
    this.fieldsets[2].disabled = true
  }

  nextStep(input) {
    input.disabled = false
    input.value = ''
    input.parentElement.disabled = true
    input.parentElement.nextSibling.disabled = false
    input.parentElement.nextSibling.querySelector('input').focus()
  }

  validate(input) {
    input.disabled = false
    input.focus()
    input.setCustomValidity(input.dataset.message)
    input.checkValidity()
    input.reportValidity()
  }

  isValid(event) {
    if (event.keyCode != 13) return false
    input = event.target
    input.setCustomValidity('')
    input.reportValidity()
    return input.checkValidity()
  }

}

let ajax = (path, method, attrs) => {
  return fetch(path, { method: method, headers: { 'Content-Type': 'application/json'}, body: JSON.stringify(attrs) })
}

var app = new App
