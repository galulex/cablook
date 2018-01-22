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
    this.inputs.forEach(e => e.value = '')
    this.fieldsets[index].disabled = false
    this.fieldsets[index].querySelector('input').focus()
  },

  validate(input) {
    input.disabled = false
    input.focus()
    input.setCustomValidity(input.dataset.message)
    input.checkValidity()
    input.reportValidity()
  }
}
